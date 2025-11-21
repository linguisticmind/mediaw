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

local msg_tools = {}

msg_tools.osd_and_debug = function(text, opts)

  opts = opts or {}
  if opts.osd == nil then opts.osd = true end
  opts.osd_duration = opts.osd_duration or nil
  if opts.debug == nil then opts.debug = false end
  opts.debug_msg_prefix = opts.debug_msg_prefix or '(osd) '

  if opts.osd == true then mp.osd_message(text, opts.osd_duration) end
  if opts.debug == true then msg.debug(opts.debug_msg_prefix .. text) end

end

return msg_tools
