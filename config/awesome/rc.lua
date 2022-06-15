pcall(require, "luarocks.loader")

-- 🎨 Themes
themes = {
	"day", -- [1] 🌕 Beautiful Light Colorscheme
	"night", -- [2] 🌑 Aesthetic Dark Colorscheme
}
theme = themes[2]
-- ============================================
-- 🌊 Default Applications
terminal = "kitty"
editor = terminal .. " -e " .. "nvim"
vscode = "code"
firefox = "firejail firefox"
web_search_cmd = "xdg-open https://duckduckgo.com/?q="
file_manager = "nautilus"
theme = themes[2]

-- 🌏 Weather API
openweathermap_key = "bd239dddfad84d69d5dc37b53f625e42" -- API Key
openweathermap_city_id = "3686262" -- City ID
weather_units = "metric"
-- ============================================
-- 📚 Library
local gfs = require("gears.filesystem")
local awful = require("awful")
local beautiful = require("beautiful")
dpi = beautiful.xresources.apply_dpi
-- ============================================
-- 🌟 Load theme
local theme_dir = gfs.get_configuration_dir() .. "themes/" .. theme .. "/"
beautiful.init(theme_dir .. "theme.lua")
-- ============================================
-- 🖥 Get screen geometry
screen_width = awful.screen.focused().geometry.width
screen_height = awful.screen.focused().geometry.height
-- ============================================
-- 🚀 Launch Autostart
awful.spawn.with_shell(gfs.get_configuration_dir() .. "configuration/autostart")
-- ============================================
-- 🤖 Import Configuration & module
require("configuration")
require("module")
-- ============================================
-- ✨ Import Daemons, UI & Widgets
require("signal")
require("ui")
-- ============================================
-- 🗑 Garbage Collector Settings
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)

-- ============================================
-- Custom applications
notion = "/home/diegot/Downloads/./Notion-2.0.18-1.AppImage" 
remNote = "/home/diegot/Downloads/./RemNote-1.7.6.AppImage" 
brave = "firejail brave"
planner = "planner" 
flameshot = "flameshot gui"

-- ===========================================

os.execute("blueman-applet &")
os.execute("flameshot &")
