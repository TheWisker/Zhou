-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                           RAVEN
-- =========================================================>
----> AwesomeWM Taskbar Raven Sidebar Widget
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local sfx = require("util.sfx")
local mysc = require("util.mysc")
local link = require("util.link")
local text = require("util.text")
local color = require("util.color")
local event = require("util.event")
local table = require("util.table")
-- =========================================================>
--  [Imports] Raven:
-- =========================================================>
local calendar = require("module.desktop.taskbar.raven.calendar")
--local switches = require("module.desktop.taskbar.raven.switches")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {ravens = {}}
-- =========================================================>
--  [Functions] Raven:
-- =========================================================>
--> Initializes the raven for screen (s):
-- =========================================================>
function this:init(s)
    -->> Raven guard
    if (not self.ravens[s.index]) then
        -->> Current screen-specific object reference
        self.ravens[s.index] = {widget = {}}
        local current = self.ravens[s.index]

        -->> Code shortening declarations
        local config = beautiful.raven
        local taskbar = beautiful.taskbar
        local spacing = dpi(beautiful.spacing, s)
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        --> Reuses the stack level previously used by taskbar
        taskbar = {
            is_top = (taskbar.position == "top"),
            margin = dpi(mysc.index(taskbar.margins, "left", 0), s),
            height = {
                normal = dpi(taskbar.height, s),
                padded = dpi(taskbar.height + (2 * taskbar.padding), s)
            }
        }
        local size = {
            width = dpi(config.width, s),
            height = s.geometry.height - (taskbar.height.normal + (spacing * 2))
        }

        -->> Current object state
        current.state = ((config.state == nil) and config.visible or config.state)

        -->> Current object actions
        current.actions = {
            -->> Switch between open and closed states
            switch = function()
                --> Opens or closes depending on the state
                if (current.state) then
                    return current.actions.close() --> Proper tail call
                else
                    return current.actions.open() --> Proper tail call
                end
            end,
            -->> Open the object throught its animation
            open = function()
                current.state = true
                current.widget.main.visible = true
            end,
            -->> Close the object throught its animation
            close = function()
                current.state = false
                current.widget.main.visible = false
            end
        }

        -->> Timer guard
        if (config.timeout and (config.timeout ~= 0)) then
            -->> Current object timer
            current.timer = gears.timer({
                call_now = false,
                single_shot = true,
                timeout = config.timeout,
                autostart = config.timer,
                -->> Timer on-timeout callback
                callback = function()
                    --> Only close if opened
                    if (current.state) then
                        return current.actions.close() --> Proper tail call
                    end
                end
            })
        end

        -->> Current object widget
        link_to(
            event.connect(
                event.connect(
                    awful.popup({
                        screen = s,
                        ontop = true,
                        cursor = "cross",
                        type = "popup_menu",
                        visible = current.state,
                        minimum_width = size.width,
                        maximum_width = size.width,
                        minimum_height = size.height,
                        maximum_height = size.height,
                        --> Needed as popup.opacity does not
                        --> seem to have any effect on the bg
                        bg = gears.color.change_opacity(
                            table.get_dynamic(config.color.background),
                            --> Opacity must be jumpstarted
                            --> according to visibility state
                            (current.state and config.opacity or 0)
                        ),
                        shape = mysc.shape("rounded_rect", (size.height/config.radius), s),
                        placement = mysc.placement("left", {
                            margins = {
                                top = spacing + (taskbar.is_top and taskbar.height.padded or 0),
                                bottom = spacing + (taskbar.is_top and 0 or taskbar.height.padded),
                                left = spacing + taskbar.margin
                            }
                        }),
                        widget = link_to(
                            {
                                {
                                    {
                                        halign = "center",
                                        markup = text.bold(
                                            text.color(
                                                text.italic("&lt;/RAVEN&gt;"),
                                                table.get_dynamic(config.title.color)
                                            )
                                        ),
                                        font = beautiful.fonts.main(config.title.font_size),
                                        widget = wibox.widget.textbox
                                    },
                                    calendar:init(s),
                                    --toggles:make(),
                                    spacing = dpi(35, s),
                                    layout = wibox.layout.fixed.vertical
                                },
                                margins = (size.width/10),
                                --> Opacity must be jumpstarted
                                --> according to current object state
                                opacity = current.state and 1 or 0,
                                widget = wibox.container.margin
                            }, "margin"
                        )
                    }), function() return current.timer:start() end, "mouse::leave", (not current.timer)
                ), function() return current.timer:stop() end, "mouse::enter", (not current.timer)
            ), "main"
        )

        -->> Current object widget evoker
        return link_to(
            sfx.on_hover(
                sfx.on_press(
                    {
                        {
                            auto_dpi = true,
                            halign = "center",
                            scaling_quality = "best",
                            image = color.image(
                                beautiful.icon.image.raven,
                                table.get_dynamic(config.color.evoker)
                            ),
                            widget = wibox.widget.imagebox
                        },
                        forced_width = taskbar.height.normal,
                        forced_height = taskbar.height.normal,
                        bg = beautiful.color.static.transparent,
                        shape = mysc.shape("rounded_rect", (taskbar.height.normal/2), s),
                        buttons = awful.button({
                            modifiers = {},
                            button = awful.button.names.LEFT,
                            --> Switch object state on evoker left-click event
                            on_release = current.actions.switch
                        }),
                        widget = wibox.container.background
                    }, {bg = beautiful.color.static.click}
                ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}
            ), "evoker"
        ) --> Proper tail call
    end
    -->> Always return what must be returned
    return self.ravens[s.index].widget.evoker
end
-- =========================================================>
--> Resets the raven for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.ravens[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.ravens[s.index] = nil
        --> Reset independent child widgets
        calendar:reset(s, restart) --> Calendar widget
        --> Restarts the widget if needed
        if (restart) then
            --> Current screen-specific configuration
            local config = beautiful.raven
            --> Ensure the object's state
            --> remains the same trough restarts
            config.state = current.state
            --> Ensure the object's timer
            --> remains the same trough restarts
            config.timer = (current.timer and current.timer.started)
            --> Initialize the new object
            self:init(s)
        end
        --> Stop the timer if needed and
        --> allow it to be garbage-collected
        if (current.timer) then
            current.timer:stop()
        end
        --> Remove references to the object on awesome's end
        current.widget.main.visible = false
    end
end
-- =========================================================>
return this
