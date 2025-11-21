-- lua_func_config - set custom default options for a Lua function
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

local func_config = function(func, opts)

  opts = opts or {}
  opts.i = opts.i or 2
  opts.table = opts.table or {}

  local mt = {
    __call = function(t, ...)
      local arg, i = {...}, opts.i
      arg[i] = arg[i] or {}
      for k, v in pairs(t) do
        if arg[i][k] == nil then arg[i][k] = v end
      end
      func(table.unpack(arg))
    end
  }

  local t = {}
  for k, v in pairs(opts.table) do t[k] = v end

  return setmetatable(t, mt)

end

return func_config
