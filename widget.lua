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

-- Configuration variables
local width         = 40        -- width in pixels of progressbar
local margin_right  = 0         -- right margin in pixels of progressbar
local margin_left   = 0         -- left margin in pixels of progressbar
local margin_top    = 0         -- top margin in pixels of progressbar
local margin_bottom = 0         -- bottom margin in pixels of progressbar
local step          = 5      -- stepsize for volume change (ranges from 0 to 100)
local color         = '#698f1e' -- foreground color of progessbar
local color_bg      = '#33450f' -- background color
local color_mute    = '#be2a15' -- foreground color when muted
local color_bg_mute = '#532a15' -- background color when muted
local mixer         = 'pavucontrol' -- mixer command
local show_text     = false     -- show percentages on progressbar
local text_color    = '#fff' -- color of text

-- End of configuration

local awful = require("awful")
local spawn_with_shell = awful.spawn.with_shell
local wibox = require("wibox")
local beautiful = require("beautiful")
local pulseaudio = require("apw.pulseaudio")
local math = require("math")
-- default colors overridden by Beautiful theme
color = beautiful.apw_fg_color or color
color_bg = beautiful.apw_bg_color or color_bg
color_mute = beautiful.apw_mute_fg_color or color_mute
color_bg_mute = beautiful.apw_mute_bg_color or color_bg_mute
show_text = beautiful.apw_show_text or show_text
text_color = beautiful.apw_text_colot or text_color

local p = pulseaudio:Create()

local pulseBar = wibox.widget.progressbar()

pulseBar.forced_width = width
pulseBar.step = step / 100

local pulseWidget
local pulseText
if show_text then
    pulseText = wibox.widget.textbox()
    pulseText:set_align("center")
    pulseWidget = wibox.container.margin(wibox.widget {
                                              pulseBar,
                                              pulseText,
                                              layout = wibox.layout.stack
                                            },
                                            margin_right, margin_left,
                                            margin_top, margin_bottom)
else
    pulseWidget = wibox.container.margin(pulseBar,
                                            margin_right, margin_left,
                                            margin_top, margin_bottom)
end

function pulseWidget.setColor(mute)
	if mute then
		pulseBar:set_color(color_mute)
		pulseBar:set_background_color(color_bg_mute)
	else
		pulseBar:set_color(color)
		pulseBar:set_background_color(color_bg)
	end
end

local function _update()
	pulseBar:set_value(p.Volume / 100)
	pulseWidget.setColor(p.Mute)
    if show_text then
        pulseText:set_markup('<span color="'..text_color..'">'..p.Volume..'%</span>')

    end
end

function pulseWidget.SetMixer(command)
	mixer = command
end

function pulseWidget.Up()
	p:SetVolume(p.Volume + step)
	_update()
end

function pulseWidget.Down()
	p:SetVolume(p.Volume - step)
	_update()
end


function pulseWidget.ToggleMute()
	p:ToggleMute()
	_update()
end

function pulseWidget.Update()
	p:UpdateState()
	 _update()
end

function pulseWidget.LaunchMixer()
	spawn_with_shell( mixer )
end


-- register mouse button actions
pulseWidget:buttons(awful.util.table.join(
		awful.button({ }, 1, pulseWidget.ToggleMute),
		awful.button({ }, 3, pulseWidget.LaunchMixer),
		awful.button({ }, 4, pulseWidget.Up),
		awful.button({ }, 5, pulseWidget.Down)
	)
)

pulseWidget.pulse = p
pulseWidget.pulseBar = pulseBar


-- initialize
_update()

return pulseWidget
