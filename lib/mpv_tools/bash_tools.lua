-- mpv_tools - tools for Lua scripting in mpv
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

-- version: 0

local msg = require('mp.msg')

local bash_tools = {}

bash_tools.quot = function(a, opts)

  opts = opts or {}
  if opts.quote_sparingly == nil then opts.quote_sparingly = false end

  if type(a) == 'string' then a = { a } end

  for k, v in ipairs(a) do
    if opts.quote_sparingly == false or v:match('[%s%c!"#$&\'()*;<>?%[\\%]^`{|}~]') then
      a[k] = "'" .. v:gsub("'", "'\\''") .. "'"
    end
  end

  return table.concat(a, ' ')

end

bash_tools.run = function(cmd, opts)

  opts = opts or {}
  if opts.quiet == nil then opts.quiet = false end
  if opts.quote_sparingly == nil then opts.quote_sparingly = true end
  if opts.dry_run == nil then opts.dry_run = false end
  if opts.msg_level == nil then opts.msg_level = 'debug' end
  opts.msg_prefix = opts.msg_prefix or '$ '
  opts.msg_prefix_dry_run = opts.msg_prefix_dry_run or '(dry run) $ '

  if opts.dry_run == true and opts.msg_level ~= false then opts.msg_level = 'warn' end

  local bash_c

  if type(cmd) == 'string' then
    bash_c = cmd
  elseif type(cmd) == 'table' then
    local function is_all_strings(t) for _, v in ipairs(t) do if type(v) ~= 'string' then return false end end; return true end
    if is_all_strings(cmd) == true then
      bash_c = bash_tools.quot(cmd, { quote_sparingly = opts.quote_sparingly })
    else
      bash_c = ''
      local i = 1
      while i <= #cmd do
        if type(cmd[i]) == 'table' then
          if #cmd[i] > 0 then
            bash_c = bash_c .. bash_tools.quot(cmd[i], { quote_sparingly = opts.quote_sparingly })
            if i < #cmd and type(cmd[i + 1]) == 'table' then bash_c = bash_c .. '; ' end
          end
        elseif type(cmd[i]) == 'string' then
          bash_c = bash_c .. ' ' .. cmd[i] .. ' '
        end
        i = i + 1
      end
    end
  end

  if opts.quiet == true then bash_c = '{ ' .. bash_c .. '; } > /dev/null' end

  if opts.dry_run == true then
    if opts.msg_level ~= false then msg[opts.msg_level](opts.msg_prefix_dry_run .. bash_c) end
  else
    if opts.msg_level ~= false then msg[opts.msg_level](opts.msg_prefix .. bash_c) end
    mp.commandv('run', '/usr/bin/env', 'bash', '-c', bash_c)
  end

end

return bash_tools
