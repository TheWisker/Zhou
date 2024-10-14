-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          DESKTOP
-- =========================================================>
----> AwesomeWM Per-Screen Desktop
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local root = root --> Awesome Global
local screen = screen --> Awesome Global
-- =========================================================>
--  [Imports] Desktop:
-- =========================================================>
local shadow = require("module.desktop.shadow")
--local volume = require("module.desktop.volume")
local taskbar = require("module.desktop.taskbar")
local session = require("module.desktop.session")
local wallpaper = require("module.desktop.wallpaper")
local cheatsheet = require("module.desktop.cheatsheet")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Functions] Desktop:
-- =========================================================>
--> Initializes the desktop:
-- =========================================================>
function this.init()
    --> Declare variable outside the loop
    local tags = nil
    -->> If the wallpaper is enabled initialize it
    if (not beautiful.wallpaper.disabled) then
        wallpaper:init() --> Initialize first for pywall
    end
    --> Loop trough all screens
    for s in screen do
        -->> Tag object creation loop
        tags = beautiful.tag(s)
        --> Loop trough all tags
        for i=1,(#tags) do
            --> Add tag
            awful.tag.add(
                tags[i].name,
                --> Force to use current object screen
                gears.table.crush(tags[i], {screen = s})
            ) --> Create tag as configured but crushing the current screen
        end
        -->> If the taskbar is enabled for screen (s) initialize it
        if (not beautiful.taskbar.disabled) then
            taskbar:init(s)
        end
    end
    -->> If the shadow is enabled initialize it
    if (not beautiful.shadow.disabled) then
        shadow:init()
    end
    -->> If the volume is enabled initialize it
    --if (not beautiful.volume.disabled) then
        --volume:init()
    --end
    -->> If the session is enabled initialize it
    if (not beautiful.session.disabled) then
        session:init()
    end
    -->> Always initialize the cheatsheet
    cheatsheet:init()
    -->> Set the root cursor
    return root.cursor(beautiful.wallpaper.cursor) --> Proper tail call
end
-- =========================================================>
--> Resets the desktop with (restart) and/or reset the (wp):
-- =========================================================>
function this.reset(restart, wp)
    -->> If the wallpaper is enabled reset it
    if (wp and (not beautiful.wallpaper.disabled)) then
        wallpaper:reset(restart) --> Initialize first for pywall
    end
    -->> If the taskbar is enabled reset it
    if (not beautiful.taskbar.disabled) then
        --> Loop trough all screens
        for s in screen do
            taskbar:reset(s, restart)
        end
    end
    -->> If the shadow is enabled reset it
    if (not beautiful.shadow.disabled) then
        shadow:reset(restart)
    end
    -->> If the volume is enabled reset it
    --if (not beautiful.volume.disabled) then
        --volume:reset(restart)
    --end
    -->> If the session is enabled reset it
    if (not beautiful.session.disabled) then
        session:reset(restart)
    end
    -->> Always reset cheatsheet
    return cheatsheet:reset(restart) --> Proper tail call
end
-- =========================================================>
return this
