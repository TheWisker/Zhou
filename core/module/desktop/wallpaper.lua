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
--  [TODO] Wallpaper:
-- =========================================================>
--> Allow for concurrent use of extended and normal wallpaper
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
local screen = screen --> Awesome Global
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {wallpaper = false}
-- =========================================================>
--  [Functions] Wallpaper:
-- =========================================================>
--> Initializes the wallpaper for the desktop:
-- =========================================================>
function this:init()
    -->> Wallpapers guard
    if (not self.wallpaper) then
        -->> Current object reference
        self.wallpaper = {widget = {}}
        local current = self.wallpaper

        -->> Code shortening declarations
        local config = beautiful.wallpaper

        -->> Code shortening function
        local link_to = function(widget, key, s)
            --> If adding for screen and table is not initialized
            if (s and (not current.widget[s.index])) then
                --> Initialize empty
                current.widget[s.index] = {}
            end
            --> Link the widget with key and return
            return link.to((s and current.widget[s.index]) or current.widget, widget, key) --> Proper tail call
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
            set = function(wall, init)
                -->> Set wallpaper
                current.wallpaper = wall
                -->> Update colors
                if (config.pywall) then
                    --> Blocking execution as to refresh colors after pywall
                    os.execute(beautiful.exec.pywall .. current.wallpaper)
                    beautiful:colors_refresh()
                    if (not init) then
                        signal.awesome.reset(true)
                    end
                    collectgarbage() --> While the leakage persists
                end
                -->> Code shortening function
                local wallpaper = function(s)
                    return link_to(
                        awful.wallpaper({
                            screen = s,
                            bg = beautiful.color.static.background,
                            honor_padding = (config.honor and config.honor.padding),
                            honor_workarea = (config.honor and config.honor.workarea),
                            widget = link_to(
                                {
                                    auto_dpi = true,
                                    halign = "center",
                                    scaling_quality = "best",
                                    image = current.wallpaper,
                                    widget = wibox.widget.imagebox
                                }, "wallpaper", s
                            )
                        }), "main", s
                    ) --> Proper tail call
                end
                -->> Set wallpaper with or without expansion
                if (config.extend) then
                    --> Screen-specific guard
                    if (not (current.widget.main and current.widget.wallpaper)) then
                        --> Create one wallpaper for all screens
                        wallpaper()
                        --> Loop trough all screens adding the wallpaper
                        for s in screen do
                            current.widget.main:add_screen(s)
                        end
                    else
                        current.widget.wallpaper.image = current.wallpaper
                        --> Repain the wallpaper to show the update
                        return current.widget.main:repaint() --> Proper tail call
                    end
                else
                    --> Loop trough all screens adding the wallpapers
                    for s in screen do
                        --> Screen-specific guard
                        if (not current.widget[s.index]) then
                            --> Create a wallpaper for a screen
                            wallpaper(s)
                        else
                            current.widget[s.index].wallpaper.image = current.wallpaper
                            --> Repain the wallpaper to show the update
                            current.widget[s.index].main:repaint()
                        end
                    end
                end
            end
        }

        -->> Current object timer
        if (config.timeout and (config.timeout ~= 0)) then
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

        -->> Set the wallpaper initially
        return current.actions.set(
            current.actions.get(), true
        ) --> Proper tail call
    end
end
-- =========================================================>
--> Resets the wallpaper for the desktop with (restart):
-- =========================================================>
function this:reset(restart)
    -->> Current object reference
    local current = self.wallpaper
    -->> If there is a wallpaper object reset it
    if (current) then
        --> Remove the reference to allow it to be garbage-collected
        self.wallpaper = nil
        --> If there is a timer stop it and allow it to be garbage-collected
        if (current.timer) then
            current.timer:stop()
        end
        --> Remove the wallpaper or wallpapers
        if (beautiful.wallpaper.extend) then
            --> Detaches the wallpaper from screens but does not clear its buffer
            current.widget.main:detach()
        else
            --> Loop trough all screens
            for s in screen do
                --> Detaches the wallpaper from screen but does not clear its buffer
                current.widget[s.index].main:detach()
            end
        end
        --> Restarts the wallpaper if needed
        if (restart) then
             --> Restart the wallpaper
            return self:init() --> Proper tail call
        else
            --> If we do not restart then we set the background to a solid color
            --> This is automatically detached by awesome on new wallpaper set
            return awful.wallpaper({
                screens = screen, --> Set for all screens
                bg = beautiful.color.static.background
            }) --> Proper tail call
        end
    end
end
-- =========================================================>
return this

