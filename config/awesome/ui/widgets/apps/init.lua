local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = require("gears.filesystem")
local beautiful = require("beautiful")
local theme_assets = beautiful.theme_assets
local dpi = beautiful.xresources.apply_dpi
local clickable_container = require("ui.widgets.clickable-container")

local return_button = function(path, callback)
	local logo = gfs.get_configuration_dir() .. path

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

	widget_button:buttons(gears.table.join(awful.button({}, 1, nil, callback)))

	return widget_button
end

local all_apps = function()
	local apps = {
		{
			name = "Brave",
			icon = "brave.svg",
			cmd = "firejail brave",
		},
		{
			name = "Spotify",
			icon = "spotify.svg",
			cmd = "snap run spotify",
		},
		{
			name = "Visual Studio Code",
			icon = "visual-studio-code-logo.svg",
			cmd = "code",
		},
		{
			name = "Foliate",
			icon = "foliate.svg",
			cmd = "foliate",
		},
		{
			name = "RemNote",
			icon = "remnote.png",
			cmd = "/home/diegot/Downloads/./RemNote-1.7.6.AppImage",
		},
	}

	local action_name = wibox.widget({
		text = "Apps",
		font = beautiful.font_name .. "Bold 10",
		align = "left",
		widget = wibox.widget.textbox,
	})

	local apps_widget = wibox.widget({
		layout = wibox.layout.fixed.horizontal,
	})

	for _, app in ipairs(apps) do
		local button = return_button("theme/assets/apps/" .. app.icon, function()
			awful.spawn.with_shell(app.cmd)
		end)
		apps_widget:add(button)
	end
	local github_activity = require("ui.widgets.github-activity")
	apps_widget:add(github_activity)

	local widget = wibox.widget{{
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(5),
		action_name,
		apps_widget,
	}}

	return apps_widget
end

return all_apps
