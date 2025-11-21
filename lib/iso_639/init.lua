-- lua_iso_639 - a Lua module for working with ISO 639 language codes
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

local mt_entry = {
  __index = function(t, k)
    if k == 'alpha_2' then
      return rawget(t, 'iso_639_1')
    elseif k == 'alpha_3' then
      return rawget(t, 'iso_639_2')
    elseif k == 'name' then
      return rawget(t, 'exonym')
    else
      return rawget(t, k)
    end
  end,
}

local mt_iso_639_2 = {
  __index = function(t, k)
    if k == 't' then
      return rawget(t, 'b')
    else
      return rawget(t, k)
    end
  end,
  __default = function(t, override)
    local k = 'b'
    if override ~= nil then k = override end
    return t[k]
  end,
}

local data = setmetatable({}, {

  __index = function(_, k)

    local data = require('iso_639.data')

    local entry

    if type(data[k]) == 'string' then
      entry = data[data[k]]
    else
      entry = data[k]
    end

    if entry ~= nil then

      if getmetatable(entry) == nil then
        setmetatable(entry, mt_entry)
      end

      if getmetatable(entry.iso_639_2) == nil then
        setmetatable(entry.iso_639_2, mt_iso_639_2)
      end

      if getmetatable(entry.exonym) == nil then
        local exonym = entry.exonym
        entry.exonym = setmetatable({}, {
          __index = function(_, k)
            if exonym[k] == nil then
              k = data[k]
            end
            return exonym[k]
          end,
          __default = function(t, override)
            local k = 'eng'
            if override ~= nil then k = override end
            return t[k]
          end,
        })
      end

    end

    return entry

  end,
})

local iso_639 = function(code, opts)

  opts = opts or {}
  opts.key = opts.key or 'iso_639_2'
  if opts.alpha_3_fallback == nil then opts.alpha_3_fallback = false end

  if not opts.key:match('^[%w_.]+$') then return nil end 
  
  if code == nil then return nil end

  local entry = data[code]

  local function get_value(key)
    local value = load('if entry == nil then return nil end; return entry.' .. key, nil, nil, { entry = entry })()
    if type(value) == 'table' then
      local mt_value = getmetatable(value)
      local default = mt_value and mt_value.__default
      if type(default) == 'function' then
        value = default(value)
      end
    end
    return value
  end

  local result = get_value(opts.key)

  if opts.key == 'iso_639_1' and result == nil and opts.alpha_3_fallback == true then
    result = get_value('iso_639_2')
  end

  if type(result) == 'table' then
    return table.unpack(result)
  else
    return result
  end

end

return iso_639
