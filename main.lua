-- mediaw - a Timewarrior-based time tracker for mpv
-- copyright (c) 2025  Alex Rogers <https://github.com/linguisticmind>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- version: 0.1.0

package.path = mp.get_script_directory() .. '/lib/?.lua;' .. mp.get_script_directory() .. '/lib/?/init.lua;' .. package.path

require('mp.options')

local msg = require('mp.msg')

local iso_639 = require('iso_639')
local split_str = require('str_tools.split_str')
local bash_tools = require('mpv_tools.bash_tools')
local msg_tools = require('mpv_tools.msg_tools')

local func_config = require('func_config')

bash_tools.run = func_config(bash_tools.run)
bash_tools.run.quiet = true
bash_tools.run.msg_prefix = '(bash) '
bash_tools.run.msg_prefix_dry_run = '(dry run) '

msg_tools.osd_and_debug = func_config(msg_tools.osd_and_debug)

local script_opts = {
  tag = 'mediaw',
  language_tag = true,
  language_tag_format = 'alpha_2',
  language_props_check = 'current-tracks/sub/lang,slang,current-tracks/audio/lang,alang',
  language = '',
  osd = true,
  debug = false,
  dry_run = false,
}

read_options(script_opts, 'mediaw')

if script_opts.language == '' then script_opts.language = nil end

msg_tools.osd_and_debug.osd = script_opts.osd
msg_tools.osd_and_debug.debug = script_opts.debug

bash_tools.run.dry_run = script_opts.dry_run

if script_opts.debug == true then

  local msg_level = mp.get_property_native('msg-level')

  local msg_level_mediaw_old = msg_level.mediaw

  msg_level.mediaw = 'debug'
  mp.set_property_native('msg-level', msg_level)

  mp.register_event('shutdown', function()
    local msg_level = mp.get_property_native('msg-level')
    msg_level.mediaw = msg_level_mediaw_old
    mp.set_property_native('msg-level', msg_level)
  end)

end

if script_opts.dry_run == true then msg.warn('Dry run.') end

local retro = {}

retro.date = nil
retro.set = function(self) self.date = os.date('!*t') end
retro.get = function(self) return os.date('!%Y-%m-%dT%H:%M:%SZ', os.time(self.date)) end
retro.diff = function(self)
  local t = os.difftime(os.time(os.date('!*t')), os.time(self.date))
  local s = t % 60; local r = t - s
  local h = math.floor(r / 3600); r = r - (h * 3600)
  local m = r / 60
  local f = {}
  if h > 0 then table.insert(f, string.format('%02d', h)) end
  table.insert(f, string.format('%02d', m))
  table.insert(f, string.format('%02d', s))
  f[1] = f[1]:gsub('^0+(%d)', '%1')
  return table.concat(f, ':')
end

local timew = {}

timew.state = {}

timew.state.started = false

timew.start = function(opts)

  opts = opts or {}
  if opts.retro == nil then opts.retro = false end

  if timew.state.started == false then

    local timew_data = {}

    timew_data.file = mp.get_property('path'):gsub('^.*/([^/]*)$', '%1')

    if script_opts.language_tag == true then

      timew_data.language = script_opts.language

      if timew_data.language == nil then

        local props = split_str(script_opts.language_props_check)

        while #props > 0 do
          local value = mp.get_property(props[1])
          if value == '' then value = nil end
          timew_data.language = value
          if timew_data.language ~= nil then break end
          table.remove(props, 1)
        end

      end

      timew_data.language = iso_639(timew_data.language, { key = script_opts.language_tag_format, alpha_3_fallback = true })

      if timew_data.language == nil then msg.warn('Language unknown.') end

    end

    local cmd = {}

    table.insert(cmd, { 'timew', 'start', script_opts.tag, timew_data.language })
    table.insert(cmd, '&&')
    if opts.retro == true then
      table.insert(cmd, { 'timew', 'modify', 'start', '@1', retro:get() })
      table.insert(cmd, '&&')
    end
    table.insert(cmd, { 'timew', 'annotate', timew_data.file })

    bash_tools.run(cmd)

    timew.state.started = true

  end

end

timew.stop = function()
  if timew.state.started == true then
    bash_tools.run({ 'timew', 'stop' })
    timew.state.started = false
  end
end

timew.delete = function()
  bash_tools.run({ 'timew', 'delete', '@1' })
end

local mediaw = {}

mediaw.state = {}

mediaw.state.started = nil
mediaw.state.armed = false
mediaw.state.paused = false
mediaw.state.canceled = nil
mediaw.state.on_next = 'restart'

mediaw.start_when_unpaused = {}

mediaw.start_when_unpaused.retro = false

setmetatable(mediaw.start_when_unpaused, {
  __call = function(t, name, value)
    if value == false then
      if t.msg ~= nil then
        if type(t.msg) == 'function' then t.msg = t.msg(t) end
        msg_tools.osd_and_debug(t.msg)
      end
      mediaw.state.started = true
      mediaw.state.armed = false
      mediaw.state.paused = false
      timew.start({ retro = t.retro })
      mp.unobserve_property(t)
      for k in pairs(t) do t[k] = nil end
    end
  end
})

mediaw.start = function(opts)

  opts = opts or {}
  if opts.retro == nil then opts.retro = false end

  if not mediaw.state.started then

    mediaw.state.canceled = false

    if mp.get_property_native('pause') == false then

      mediaw.state.started = true

      if opts.retro == false then
        msg_tools.osd_and_debug('mediaw: start')
      else
        msg_tools.osd_and_debug('mediaw: start (-' .. retro:diff() .. ')')
      end

      timew.start({ retro = opts.retro })

    else

      if opts.retro == false then
        msg_tools.osd_and_debug('mediaw: arm')
      else
        msg_tools.osd_and_debug('mediaw: arm (-' .. retro:diff() .. ')')
      end

      mediaw.state.armed = true

      mediaw.start_when_unpaused.retro = opts.retro
      mediaw.start_when_unpaused.msg = function(t)
        if t.retro == false then
          return 'mediaw: start'
        else
          return 'mediaw: start (-' .. retro:diff() .. ')'
        end
      end
      mp.observe_property('pause', 'native', mediaw.start_when_unpaused)

    end

  else
    msg_tools.osd_and_debug('mediaw: already started')
  end

end

mediaw.disarm = function()
  mp.unobserve_property(mediaw.start_when_unpaused)
  mediaw.state.armed = false
  mediaw.state.canceled = true
end

mediaw.stop = function()

  if mediaw.state.started == true then

    msg_tools.osd_and_debug('mediaw: stop')
    timew.stop()
    mediaw.state.started = false

    if mediaw.state.paused == true then
      mp.unobserve_property(mediaw.start_when_unpaused)
      mediaw.state.paused = false
    end

  elseif mediaw.state.armed == true then

    msg_tools.osd_and_debug('mediaw: disarm')
    mediaw.disarm()

  elseif mediaw.state.started == false then
    msg_tools.osd_and_debug('mediaw: already stopped')
  elseif mediaw.state.started == nil then
    msg_tools.osd_and_debug('mediaw: never started')
  end

end

mediaw.cancel = function()

  if mediaw.state.started == true and mediaw.state.canceled == false then

    msg_tools.osd_and_debug('mediaw: cancel')

    timew.stop()
    mediaw.state.started = false

    timew.delete()
    mediaw.state.canceled = true

  else

    if mediaw.state.canceled == false then

      if mediaw.state.armed == false then
        msg_tools.osd_and_debug('mediaw: delete')
        timew.delete()
        mediaw.state.canceled = true
      else
        msg_tools.osd_and_debug('mediaw: disarm')
        mediaw.disarm()
      end

    elseif mediaw.state.canceled == nil then
      msg_tools.osd_and_debug('mediaw: nothing to cancel')
    elseif mediaw.state.canceled == true then
      msg_tools.osd_and_debug('mediaw: already canceled')
    end

  end

end

mediaw.pause = function()

  if mp.get_property_native('pause') == true and not mediaw.state.started then

    msg_tools.osd_and_debug('mediaw: start')

    mediaw.state.started = true
    mediaw.state.canceled = false

    timew.start()

    mp.set_property_native('pause', false)

  else

    if mp.get_property_native('pause') == false then

      if mediaw.state.started == true then

        mediaw.state.paused = true

        msg_tools.osd_and_debug('mediaw: pause')
        timew.stop()

      end

      mp.set_property_native('pause', true)

      if mediaw.state.started == true then

        mp.add_timeout(0.1, function()
          mediaw.start_when_unpaused.msg = 'mediaw: resume'
          mp.observe_property('pause', 'native', mediaw.start_when_unpaused)
        end)

      end

    else
      mp.set_property_native('pause', false)
    end

  end

end

mediaw.pause_on_next = function()

  if mediaw.state.started == true then 

    if mediaw.state.on_next == 'restart' then
      mediaw.state.on_next = 'pause'
    elseif mediaw.state.on_next == 'pause' then
      mediaw.state.on_next = 'restart'
    end

    msg_tools.osd_and_debug('mediaw: ' .. mediaw.state.on_next .. ' on next')

  elseif mediaw.state.started == false then
    msg_tools.osd_and_debug('mediaw: not started')
  elseif mediaw.state.started == nil then
    msg_tools.osd_and_debug('mediaw: never started')
  end

end

mediaw.do_when_file_loaded = function()

  retro:set()

  if mediaw.state.started == true then 

    if mediaw.state.on_next == 'restart' then
      timew.start()
    elseif mediaw.state.on_next == 'pause' then
      mediaw.pause()
      mediaw.state.on_next = 'restart'
    end

  end

end

mp.register_event('file-loaded', mediaw.do_when_file_loaded)

mp.register_event('end-file', timew.stop)

mp.add_key_binding('Ctrl+t', 'mediaw-start', mediaw.start)
mp.add_key_binding('Ctrl+Alt+t', 'mediaw-start-retro', function()
  mediaw.start({ retro = true })
end)

mp.add_key_binding('Ctrl+T', 'mediaw-stop', mediaw.stop)
mp.add_key_binding('Ctrl+Alt+T', 'mediaw-cancel', mediaw.cancel)

mp.add_key_binding('Ctrl+SPACE', 'mediaw-pause', mediaw.pause)

mp.add_key_binding('Ctrl+Alt+SPACE', 'mediaw-pause-on-next', mediaw.pause_on_next)
