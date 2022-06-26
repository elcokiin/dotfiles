local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = require("gears.filesystem")
local beautiful = require("beautiful")
local theme_assets = beautiful.theme_assets
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")

local return_button = function()
	-- Generate Awesome icon
	local logo = gfs.get_configuration_dir() .. "icons/awesome_logo.svg"

	local widget = wibox.widget({
		{
			id = "icon",
			image = logo,
			widget = wibox.widget.imagebox,
			resize = true,
		},
		margins = dpi(8),
		layout = wibox.layout.align.horizontal,
	})

	local widget_button = wibox.widget({
		{
			widget,
			margins = dpi(8),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	})

	widget_button:buttons(gears.table.join(awful.button({}, 1, nil, function()
		control_center:toggle()
	end)))

	return widget_button
end

return return_button
