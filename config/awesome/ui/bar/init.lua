local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local clickable_container = require("ui.widgets.clickable-container")

awful.screen.connect_for_each_screen(function(s)
	-- Clock
	local clock = wibox.widget({
		{
			{
				font = beautiful.font_name .. "Bold 12",
				format = "%I:%M %p",
				align = "center",
				valign = "center",
				widget = wibox.widget.textclock,
			},
			margins = dpi(8),
			widget = wibox.container.margin,
		},
		widget = clickable_container,
	})

	clock:buttons(gears.table.join(
		awful.button({ }, 1, function()
			info_center:toggle()
		end)
	))

	-- Systray
	s.systray = wibox.widget({
		visible = false,
		base_size = dpi(20),
		horizontal = true,
		screen = "primary",
		widget = wibox.widget.systray,
	})

	-- Widgets
	s.mytaglist = require("ui.widgets.pacman-taglist")(s)
	s.tray_toggler = require("ui.widgets.tray-toggle")
	s.battery = require("ui.widgets.battery")()
	s.network = require("ui.widgets.network")()
	s.dashboard_toggle = require("ui.widgets.dashboard-toggle")()
	s.apple = require("ui.widgets.apple")()
	s.all_apps = require("ui.widgets.apps")()

	local taglist = wibox.widget{
        shape = beautiful.taglist_shape_focus,
        -- bg = beautiful.xcolor0,
        -- widget = wibox.container.background,
		{
			s.mytaglist,
			margins = { top = dpi(2), bottom = dpi(2), left = dpi(3), right = dpi(3) },
			widget = wibox.container.margin,
		},
		widget = clickable_container,
    }
	-- s.control_center_toggle = require("ui.widgets.hamburger")(awful.button({}, 1, function()
	-- 	dashboard:toggle()
	-- end))

	-- local control_center_toggle = wibox.widget({
	-- 	{
	-- 		s.control_center_toggle,
	-- 		margins = { top = dpi(2), bottom = dpi(2), left = dpi(3), right = dpi(3) },
	-- 		widget = wibox.container.margin,
	-- 	},
	-- 	widget = clickable_container,
	-- })

	-- Create the wibar
	----------------------
	s.mywibar = awful.wibar({
		type = "dock",
		ontop = true,
		stretch = false,
		visible = true,
		height = dpi(40),
		width = s.geometry.width - dpi(30),
		screen = s,
		bg = beautiful.transparent,
	})

	awful.placement.top(s.mywibar, { margins = beautiful.useless_gap * 2 })

	s.mywibar:struts({
		top = dpi(45),
	})

	-- Remove wibar on full screen
	local function remove_wibar(c)
		if c.fullscreen or c.maximized then
			c.screen.mywibar.visible = false
		else
			c.screen.mywibar.visible = true
		end
	end

	-- Remove wibar on full screen
	local function add_wibar(c)
		if c.fullscreen or c.maximized then
			c.screen.mywibar.visible = true
		end
	end

	-- Hide bar when a splash widget is visible
	awesome.connect_signal("widgets::splash::visibility", function(vis)
		screen.primary.mywibar.visible = not vis
	end)

	client.connect_signal("property::fullscreen", remove_wibar)

	client.connect_signal("request::unmanage", add_wibar)

	-- Add widgets to the wibox
	s.mywibar:setup({
		{
			{
				layout = wibox.layout.align.horizontal,
				expand = "none",
				{
					s.apple,
					s.all_apps,
					spacing = dpi(12),
					-- control_center_toggle,
					-- s.mytaglist,
					layout = wibox.layout.fixed.horizontal,
				},
				taglist,
				{
					{
						s.systray,
						widget = wibox.container.margin,
					},
					s.tray_toggler,
					clock,
					s.battery,
					s.dashboard_toggle,
					layout = wibox.layout.fixed.horizontal,
				},
			},
			left = dpi(10),
			right = dpi(10),
			widget = wibox.container.margin,
		},
		bg = beautiful.wibar_bg,
		shape = helpers.rrect(beautiful.border_radius),
		widget = wibox.container.background,
	})
end)
