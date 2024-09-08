-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          SYSTRAY
-- =========================================================>
----> AwesomeWM Taskbar System Tray Widget
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
--  [Imports] Utils:
-- =========================================================>
local sfx = require("util.sfx")
local mysc = require("util.mysc")
local link = require("util.link")
local color = require("util.color")
local event = require("util.event")
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local rubato = require("lib.rubato")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {systrays = {}}
-- =========================================================>
--  [Functions] Systray:
-- =========================================================>
--> Initializes the systray for screen (s):
-- =========================================================>
function this:init(s)
    -->> Systray guard
    if (not self.systrays[s.index]) then
        -->> Current screen-specific object reference
        self.systrays[s.index] = {widget = {}, pinned = false, state = false}
        local current = self.systrays[s.index]

        -->> Code shortening declarations
        local config = beautiful.systray(s)
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        local size = {
            width = dpi(config.size, s),
            height = dpi(beautiful.taskbar(s).height, s)
        }

        -->> Current object state
        current.state = config.state

        -->> Current object actions
        current.actions = {
            -->> Switch between open and closed states
            switch = function()
                if (current.state) then
                    return current.actions.close() --> Proper tail call
                else
                    return current.actions.open() --> Proper tail call
                end
            end,
            -->> Open the object throught its animation
            open = function()
                current.state = true
                current.animations.open.state = true
                current.animations.open.target = size.width
                current.widget.evoker.image = color.image(
                    beautiful.icon.image.arrow.right,
                    table.get_dynamic(config.icon.color)
                )
            end,
            -->> Close the object throught its animation
            close = function()
                current.state = false
                current.pinned = false
                current.animations.opacity.state = true
                current.animations.opacity.target = 0
                current.widget.evoker.image = color.image(
                    beautiful.icon.image.arrow.left,
                    table.get_dynamic(config.icon.color)
                )
            end
        }

        -->> Current object animations
        current.animations = {
            -->> Object open enlargement animation
            open = rubato.timed({
                state = false,
                rate = beautiful.animation.fps,
                --> Constraint must be jumpstarted
                --> according to current object state
                pos = (current.state and size.width or 0),
                easing = beautiful.animation.widget.systray.easing,
                duration = beautiful.animation.widget.systray.duration,
                subscribed = function(pos)
                    --> Change constraint width
                    current.widget.constraint.width = pos
                    --> If it is opening (less to more) and has achieved 80% or more width
                    if (current.animations.open.state and pos >= (size.width * 0.8)) then
                        --> Avoid running 'if' more than once
                        current.animations.open.state = false
                        --> Set respective sibling animation state and target
                        current.animations.opacity.state = false
                        current.animations.opacity.target = config.icon.opacity
                    end
                end
            }),
            -->> Object opacity in-and-out animation
            opacity = rubato.timed({
                state = false,
                rate = beautiful.animation.fps,
                --> Opacity must be jumpstarted
                --> according to current object state
                pos = (current.state and 1 or 0),
                easing = beautiful.animation.widget.systray.easing,
                duration = (beautiful.animation.widget.systray.duration/2),
                subscribed = function(pos)
                    --> Change tray opacity
                    current.widget.tray.opacity = pos
                    --> If it is fading (more to less) and has achieved 40% or less opacity
                    if (current.animations.opacity.state and (pos <= 0.4)) then
                        --> Avoid running 'if' more than once
                        current.animations.opacity.state = false
                        --> Set respective sibling animation state and target
                        current.animations.open.state = false
                        current.animations.open.target = 0
                    end
                end
            })
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
                    --> If object open close it
                    if (current.state and (not current.pinned)) then
                        return current.actions.close() --> Proper tail call
                    end
                end
            })
        end

        -->> Current object widget
        return event.connect(
            event.connect(
                link_to(
                    {
                        sfx.on_hover(
                            sfx.on_press(
                                link_to(
                                    {
                                        {
                                            link_to(
                                                {
                                                    auto_dpi = true,
                                                    halign = "center",
                                                    scaling_quality = "best",
                                                    forced_width = (size.height * 0.6),
                                                    forced_height = (size.height * 0.6),
                                                    image = color.image(
                                                        --> Arrow direction must be jumpstarted
                                                        --> according to current object state
                                                        beautiful.icon.image.arrow[current.state and "right" or "left"],
                                                        table.get_dynamic(config.icon.color)
                                                    ),
                                                    widget = wibox.widget.imagebox
                                                }, "evoker"
                                            ),
                                            widget = wibox.container.place
                                        },
                                        forced_width = size.height,
                                        forced_height = size.height,
                                        bg = beautiful.color(s).static.transparent,
                                        shape = mysc.shape("rounded_rect", (size.height/2), s),
                                        buttons = {
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.LEFT,
                                                --> Switch object state on evoker left-click event
                                                on_release = current.actions.switch
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.MIDDLE,
                                                --> Switch object state on evoker left-click event
                                                on_release = function()
                                                    current.pinned = true
                                                    current.actions.switch()
                                                end
                                            })
                                        },
                                        widget = wibox.container.background
                                    }, "main"
                                ), {bg = beautiful.color(s).static.click}
                            ), {cursor = beautiful.cursor.button, bg = beautiful.color(s).static.hover}
                        ),
                        link_to(
                            {
                                {
                                    link_to(
                                        wibox.widget.systray({
                                            screen = s,
                                            horizontal = true,
                                            --> Opacity must be jumpstarted
                                            --> according to current object state
                                            opacity = (current.state and config.icon.opacity or 0),
                                            base_size = dpi(config.icon.size, s)
                                        }), "tray"
                                    ),
                                    margins = mysc.margins(0, 10, s),
                                    widget = wibox.container.margin
                                },
                                --> Constraint must be jumpstarted
                                --> according to current object state
                                width = (current.state and size.width or 0),
                                widget = wibox.container.constraint
                            }, "constraint"
                        ),
                        layout = wibox.layout.fixed.horizontal
                    }, "main"
                ), function() return current.timer:start() end, "mouse::leave", (not current.timer)
            ), function() return current.timer:stop() end, "mouse::enter", (not current.timer)
        ) --> Proper tail call
    end
    -->> Always return what must be returned
    return self.systrays[s.index].widget.main
end
-- =========================================================>
--> Resets the systray for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.systrays[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.systrays[s.index] = nil
        --> Restarts the widget if needed
        if (restart) then
            --> Current screen-specific configuration
            local config = beautiful.systray(s)
            --> Ensure the object's state
            --> remains the same trough restarts
            config.state = current.state
            --> Ensure the object's timer
            --> remains the same trough restarts
            config.timer = current.timer.started
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
