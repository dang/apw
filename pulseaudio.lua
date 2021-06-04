-- Copyright 2013 mokasin
-- This file is part of the Awesome Pulseaudio Widget (APW).
--
-- APW is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- APW is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with APW. If not, see <http://www.gnu.org/licenses/>.


-- Simple pulseaudio command bindings for Lua.

local pulseaudio = {}


local cmd = "/home/dang/.config/awesome/apw/pactl-volume"
local default_sink = ""

function pulseaudio:Create()
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.Volume = 0     -- volume of default sink
	o.Mute = false   -- state of the mute flag of the default sink

	-- retrieve current state from pulseaudio
	pulseaudio.UpdateState(o)

	return o
end

function pulseaudio:UpdateState()
	local f = io.popen(cmd .. " get-sink")

	-- if the cmd cannot be found
	if f == nil then
		return false
	end

	local out = f:read("*a")
	f:close()

	-- find default sink
	default_sink = string.gsub(out, "\n\r", "")

	if default_sink == nil then
		default_sink = ""
		return false
	end

	-- retrieve volume of default sink
	f = io.popen(cmd .. " get-volume")
	out = f:read("*a")
	f:close()
	print(out)
	self.Volume = tonumber(out)

	-- retrieve mute state of default sink
	local m
	f = io.popen(cmd .. " get-mute")
	out = f:read("*a")
	f:close()
	m = string.gsub(out, "\n", "")

	self.Mute = m == "yes"

end

-- Run process and wait for it to end
local function run(command)
	local p = io.popen(command)
	p:read("*a")
	p:close()
end

-- Sets the volume of the default sink to vol from 0 to 1.
function pulseaudio:SetVolume(vol)
	if vol > 100 then
		vol = 100
	end

	if vol < 0 then
		vol = 0
	end

	-- set…
	run(cmd .. " set-volume " .. vol)

	-- …and update values
	self:UpdateState()
end


-- Toggles the mute flag of the default default_sink.
function pulseaudio:ToggleMute()
		run(cmd .. " set-mute -t")

	-- …and updates values.
	self:UpdateState()
end


return pulseaudio

