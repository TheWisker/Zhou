-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                         WALLPAPER
-- =========================================================>
----> AwesomeWM Wallpaper
-- =========================================================>
--  [TODO] Notifications:
-- =========================================================>
--
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
-- =========================================================>
--  [Imports] Signal:
-- =========================================================>
local signal = require("module.signal")
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local io = require("util.io")
local link = require("util.link")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local type = type
local screen = screen --> Awesome Global
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {wallpapers = {}}
-- =========================================================>
--  [Functions] Wallpaper:
-- =========================================================>
--> Initializes the wallpaper for screen (s):
-- =========================================================>
function this:init(s)
    -->> Wallpapers guard
    if (not self.wallpapers[s.index]) then
        -->> Current screen-specific object reference
        self.wallpapers[s.index] = {widget = {}}
        local current = self.wallpapers[s.index]

        -->> Code shortening declarations
        local config = beautiful.wallpaper(s)

        -->> Pointer override for multiscreen wallpapers
        if (type(config) == "number") then
            -->> If it points to a nil wallpaper object then initialize it
            if (not self.wallpapers[config]) then
                self:init(screen[config])
            end

            -->> Then add current screen to pointer object
            return self.wallpapers[config].widget.main:add_screen(s) --> Proper tail call
        end

        -->> Code shortening declarations
        config = gears.table.crush(beautiful.wallpaper.mode[config.mode], config)
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end

        -->> Current object actions
        current.actions = {
            -->> Get the wallpaper file for the current config
            get = function()
                --> Static file gets priority
                if (config.file) then
                    return config.file
                end
                --> Declare the variable but do not initialize it
                local file = nil
                --> Get random or sequential file from folder otherwise
                if (config.random) then
                    --> If the user has infinite bad luck this could be an infinite loop
                    repeat
                        file = gears.filesystem.get_random_file_from_dir(
                            config.folder,
                            config.extensions,
                            true --> Returns absolute path
                        )
                    until (config.reuse or (current.wallpaper ~= file))
                else
                    --> Loop sequentially trough every entry in folder
                    for entry in io.ils(config.folder) do
                        --> Ignore uninteresting entries
                        if ((entry ~= "") and (entry ~= ".") and (entry ~= "..")) then
                            --> Interlock first match to only search sequentially after it
                            file = (file or (current.wallpaper == entry)) -- fix this failing first time
                            if (file) then
                                --> Check if file ends in any allowed extension
                                for i=1,#(config.extensions) do
                                    --> Pattern matches a string-ending extension
                                    if (entry:find("%." .. config.extensions[i] .. "$")) then
                                        --> As entry is not absolute path append folder path
                                        return config.folder .. entry
                                    end
                                end
                            end
                        end
                    end
                end
                --> Return file, if any, or default file
                return (file or beautiful.wallpaper.file)
            end,
            -->> Set (wall) as the wallpaper
            set = function(wall)
                if (config.pywall) then
                    beautiful:colors_refresh(s)
                    signal.awesome.reset(s, true)
                    collectgarbage() --> While the leakage persists
                    print(require("util.table").get_dynamic(beautiful.client[1].border.color.urgent))
                end
                current.wallpaper = wall
                current.widget.wallpaper.image = wall
                --> Must repaint the wallpaper so the change takes effect
                return current.widget.main:repaint() --> Proper tail call
            end
        }

        -->> Current object timer
        if ((config.timeout) and (config.timeout ~= 0)) then
            current.timer = gears.timer({
                autostart = true,
                single_shot = false,
                timeout = config.timeout,
                callback = function()
                    return current.actions.set(
                        current.actions.get()
                    ) --> Proper tail call
                end
            })
        end

        -->> Current wallpaper file
        current.wallpaper = current.actions.get()

        -->> Current object widget
        return link_to(
            awful.wallpaper({
                screen = s,
                bg = beautiful.color(s).static.background,
                honor_padding = (config.honor and config.honor.padding),
                honor_workarea = (config.honor and config.honor.workarea),
                widget = link_to(
                    {
                        auto_dpi = true,
                        halign = "center",
                        scaling_quality = "best",
                        image = current.wallpaper,
                        widget = wibox.widget.imagebox
                    }, "wallpaper"
                )
            }), "main"
        ) --> Proper tail call
    end
end
-- =========================================================>
--> Resets the wallpaper for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    --> Current screen-specific object reference
    local current = self.wallpapers[s.index]
    --> If there is a wallpaper object reset it
    if (current) then
        --> Remove the reference to allow it to be garbage-collected
        self.wallpapers[s.index] = nil
        --> If there is a timer stop it and allow it to be garbage-collected
        if (current.timer) then
            current.timer:stop()
        end
        --> Detaches the wallpaper from screen but does not clear its buffer
        current.widget.main:detach()
        --> Restarts the wallpaper if needed
        if (restart) then
            return self:init(s) --> Proper tail call
        else
            --> If it does not restart set the background to a solid color
            --> This is automatically detached by awesome on new wallpaper set
            return awful.wallpaper({
                screen = s,
                bg = beautiful.color.static.background
            }) --> Proper tail call
        end
    end
end
-- =========================================================>
return this

