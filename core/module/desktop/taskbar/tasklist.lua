-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                         TASKLIST
-- =========================================================>
----> AwesomeWM Taskbar Tasklist Widget
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
-- =========================================================>
--  [Imports] Signal:
-- =========================================================>
local signal = require("module.signal")
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local sfx = require("util.sfx")
local mysc = require("util.mysc")
local link = require("util.link")
local event = require("util.event")
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local rubato = require("lib.rubato")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {tasklists = {}}
-- =========================================================>
--  [Functions] Tasklist:
-- =========================================================>
--> Initializes the tasklist for screen (s):
-- =========================================================>
function this:init(s)
    -->> Tasklist guard
    if (not self.tasklists[s.index]) then
        --> Current screen-specific object reference
        self.tasklists[s.index] = {widget = {}, func = {}}
        local current = self.tasklists[s.index]

        --> Code shortening declarations
        local config = beautiful.tasklist
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        --local taskbar_height = dpi(beautiful.taskbar.height, s)

        -->> Disabled guard
        --if (not config.enabled) then
            --self.tasklists[s.index] = nil
            --return nil
        --end

        -->> Current object widget
        return link_to( 
            {
                awful.widget.tasklist({
                    screen = s,
                    opacity = 0.8,
                    filter = awful.widget.tasklist.filter.minimizedcurrenttags,
                    buttons = {
                        awful.button({
                            modifiers = {},
                            group = "tasklist",
                            button = awful.button.names.LEFT,
                            description = "Unminimize client",
                            on_release = function(c)
                                return c:activate({context = "tasklist", action = "toggle_minimization"}) --> Proper tail call
                            end
                        }),
                        awful.button({
                            modifiers = {},
                            group = "tasklist",
                            button = awful.button.names.SCROLL_UP,
                            description = "Focus next client",
                            on_release = function(c)
                                return awful.client.focus.byidx( 1) --> Proper tail call
                            end
                        }),
                        awful.button({
                            modifiers = {},
                            group = "tasklist",
                            button = awful.button.names.SCROLL_DOWN,
                            description = "Focus previous client",
                            on_release = function(c)
                                return awful.client.focus.byidx(-1) --> Proper tail call
                            end
                        })
                    },
                    update_callback = function(self)
                        current.widget.main.visible = (self.count > 0)
                    end,
                    base_layout = {
                        spacing = dpi(5, s),
                        layout = wibox.layout.fixed.horizontal
                    },
                    widget_template = {
                        id = "icon_role",
                        widget = wibox.widget.imagebox
                    }
                }),
                margins = mysc.margins(5, 5, s),
                widget = wibox.container.margin
            }, "main"
        ) --> Proper tail call
    end
    -->> Always return what must be returned
    return self.tasklists[s.index].widget.main
end
-- =========================================================>
--> Resets the tasklist for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.tasklists[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.tasklists[s.index] = nil
        --> Restarts the widget if needed
        if (restart) then
            --> Initialize the new object
            self:init(s)
        end
        --> Remove references to the object on awesome's end
        current.widget.main.visible = false
    end
end
-- =========================================================>
return this
