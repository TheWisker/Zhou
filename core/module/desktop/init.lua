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
local root = root
-- =========================================================>
--  [Imports] Desktop:
-- =========================================================>
--local volume = require("module.desktop.volume")
local shadow = require("module.desktop.shadow")
local taskbar = require("module.desktop.taskbar")
local wallpaper = require("module.desktop.wallpaper")
local session = require("module.desktop.session")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Functions] Desktop:
-- =========================================================>
--> Initializes the desktop for screen (s):
-- =========================================================>
function this.init(s)
    -->> Tag object creation loop
    local tags = beautiful.tag(s)
    for i=1,(#tags) do
        awful.tag.add(
            tags[i].name,
            --> Force to use current object screen
            gears.table.crush(tags[i], {screen = s})
        ) --> Create tag as configured but crushing the current screen
    end
    -->> If the session is enabled for screen (s) initialize it
    if (beautiful.session(s).enabled) then
        session:init(s)
    end
    -->> If the volume is enabled for screen (s) initialize it
    --if (beautiful.volume(s).enabled) then
        --volume:init(s)
    --end
    -->> If the shadow is enabled for screen (s) initialize it
    if (beautiful.shadow(s).enabled) then
        shadow:init(s)
    end
    -->> If the taskbar is enabled for screen (s) initialize it
    if (beautiful.taskbar(s).enabled) then
        taskbar:init(s)
    end
    -->> If the wallpaper is enabled for screen (s) initialize it
    if (beautiful.wallpaper(s).enabled) then --issue with pointers
        wallpaper:init(s)
    end
    -->> Set the root cursor #--btful
    return root.cursor("cross") --> Proper tail call
end
-- =========================================================>
--> Resets the desktop for screen (s), with the boolean
--> options to (restart) and/or reset the (wallpaper):
-- =========================================================>
function this.reset(s, restart, wallpaper)
    session:reset(s, restart)
    --volume:reset(s, restart)
    shadow:reset(s, restart)
    taskbar:reset(s, restart)
    if (wallpaper) then
        return wallpaper:reset(s, restart) --> Proper tail call
    end
end
-- =========================================================>
return this
