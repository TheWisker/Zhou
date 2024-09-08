-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>

--[[                  -- Description --                 --[[

      Awesome slick config providing dynamic per-screen
      configurations that can use pywall to change colors
      with the wallpaper! Everyhting customizable!

]]--                                                    ]]--

-- =========================================================>
--  Important configuration paths:
-- =========================================================>
-- ./theme/*.lua
-- ./module/bind/{keys, mouse, keyboard}.lua
-- ./module/rule/{client, notification}.lua
-- =========================================================>
--> Stop the collector while in startup:
-- =========================================================>
collectgarbage("stop")
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
-- =========================================================>
--  [Imports] Themes:
-- =========================================================>
local theme = require("theme.dynamic") --> Selected theme
local theme_defaults = require("theme.defaults")
-- =========================================================>
--  [Imports] Modules:
-- =========================================================>
local rule = require("module.rule")
local bind = require("module.bind")
local notif = require("module.notif")
local client = require("module.client")
local desktop = require("module.desktop")
-- =========================================================>
--  [Imports] Util:
-- =========================================================>
local table = require("util.table")
-- =========================================================>
--  [Zhou] Configuration:
-- =========================================================>
--  Awful parameters
-- =========================================================>
--> Shell to use when spawning in awesome
-- =========================================================>
awful.util.shell = "fish"
-- =========================================================>
--> Tag layouts and history
-- =========================================================>
awful.tag.layouts = {} --> Set in the theme instead
awful.tag.history.limit = 5
-- =========================================================>
--> Jump mouse cursor to the corner when resizing client
-- =========================================================>
awful.layout.suit.floating.resize_jump_to_corner = true
-- =========================================================>
--> Jump mouse cursor to the corner when resizing client
-- =========================================================>
awful.layout.suit.tile.resize_jump_to_corner = true
-- =========================================================>
--> Specifies based on what to select the focused screen
-- =========================================================>
awful.screen.default_focused_args = {client = true, mouse = false}
-- =========================================================>
--  Theme Initialization
-- =========================================================>
beautiful.init(
    table.crush(theme_defaults, theme)
)
-- =========================================================>
--  Notification Initialization
-- =========================================================>
notif:init()
-- =========================================================>
--  Client Initialization
-- =========================================================>
client:init()
-- =========================================================>
--  Bindings Initialization
-- =========================================================>
bind.bind("global")
-- =========================================================>
--  Desktop Initialization
-- =========================================================>
awful.screen.connect_for_each_screen(
    function(s)
        print("Screen: " .. s.index)
        desktop.init(s)
    end
)
-- =========================================================>
--  Tag Initialization
-- =========================================================>
tag.connect_signal(
    "request::default_layouts",
    function()
        return awful.layout.append_default_layouts(
            beautiful.layout.list
        ) --> Proper tail call
    end
)
-- =========================================================>
--  [Zhou] Events:
-- =========================================================>
--  Startup event
-- =========================================================>
awesome.connect_signal(
    "startup",
    function()
        collectgarbage("incremental", 150, 600, 0)
        --awful.spawn.with_shell(beautiful.exec.compositor.on)
        collectgarbage("collect") --> Collect garbage
        print("Memory in use: " .. (collectgarbage("count") / 1024) .. "Mb")
        return gears.timer({
            timeout = 300, --> 5 minutes
            call_now = true,
            autostart = true,
            single_shot = false,
            -->> Timer on-timeout callback
            callback = function()
                return collectgarbage("collect") --> Proper tail call
            end
        }) --> Proper tail call
    end
)
-- =========================================================>
--  Exit event
-- =========================================================>
awesome.connect_signal(
    "exit",
    function()
        print("Memory in use: " .. (collectgarbage("count") / 1024) .. "Mb")
        return awful.spawn.with_shell(beautiful.exec.compositor.off) --> Proper tail call
    end
)
--[[
awful.spawn.with_shell(
    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
    'xrdb -merge <<< "awesome.started:true";' ..
    'dex --environment Awesome --autostart --search-paths "${XDG_CONFIG_HOME:-$HOME/.config}/autostart:${XDG_CONFIG_DIRS:-/etc/xdg}/autostart";'
)]]--
