-- lua_str_tools - tools for working with Lua strings
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

local split_str = function(str, sep)

  sep = sep or ','

  sep = sep:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', '%%%0')

  local t = {}

  for s in str:gmatch('([^' .. sep .. ']*)' .. sep) do table.insert(t, s) end

  local s = str:match('[^' .. sep .. ']+$')
  if s then
    table.insert(t, s)
  else
    table.insert(t, '')
  end

  return t

end

return split_str
