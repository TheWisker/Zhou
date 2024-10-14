-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          CLOCK
-- =========================================================>
----> AwesomeWM Taskbar Clock Widget
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
local event = require("util.event")
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local rubato = require("lib.rubato")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {clocks = {}}
-- =========================================================>
--  [Functions] Clock:
-- =========================================================>
--> Initializes the clock for screen (s):
-- =========================================================>
function this:init(s)
    -->> Clock guard
    if (not self.clocks[s.index]) then
        -->> Current screen-specific object reference
        self.clocks[s.index] = {widget = {}, index = 1}
        local current = self.clocks[s.index]

        -->> Code shortening declarations
        local config = beautiful.clock
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        local taskbar_height = dpi(beautiful.taskbar.height, s)

        -->> Current object index
        current.index = (config.index or 1)

        -->> Current object actions
        current.actions = {
            home = function()
                --> If index is already 1 do nothing
                if (current.index ~= 1) then
                    current.index = 1
                    return current.actions.update() --> Proper tail call
                end
            end,
            -->> Switch to the next timezone
            next = function()
                current.index = ((current.index < #(config.timezones)) and (current.index + 1) or 1)
                return current.actions.update() --> Proper tail call
            end,
            -->> Switch to the previous timezone
            prev = function()
                current.index = ((current.index > 1) and (current.index - 1) or #(config.timezones))
                return current.actions.update() --> Proper tail call
            end,
            -->> Update the object for current timezone
            update = function()
                current.widget.clock.timezone = config.timezones[current.index]
                current.widget.tooltip.markup = config.tooltip.format(config.timezones[current.index])
                current.widget.tooltip.visible = true
                return current.timers.tooltip:again() --> Proper tail call
            end
        }

        -->> Timer guard
        if (config.timeout and (config.timeout ~= 0)) then
            -->> Current object timers
            current.timers = {
                home = mysc.choose(
                    (config.timeout and (config.timeout ~= 0)),
                    function()
                        return gears.timer({
                            call_now = false,
                            single_shot = true,
                            timeout = config.timeout,
                            autostart = config.timer,
                            -->> Timer on-timeout callback
                            callback = current.actions.home
                        })
                    end,
                    mysc.empty
                ),
                tooltip = gears.timer({
                    call_now = false,
                    autostart = false,
                    single_shot = true,
                    timeout = config.tooltip.timeout,
                    -->> Timer on-timeout callback
                    callback = function()
                        current.widget.tooltip.visible = false
                    end
                })
            }
        end

        -->> Current object widget
        return event.connect(
            event.connect(
                sfx.on_hover(
                    sfx.on_press(
                        link.tooltip(
                            link_to(
                                awful.tooltip({
                                    screen = s,
                                    ontop = true,
                                    mode = "outside",
                                    type = "tooltip",
                                    visible = config.state,
                                    input_passthrough = true,
                                    shape = config.tooltip.shape,
                                    opacity = config.tooltip.opacity,
                                    delay_show = config.tooltip.delay,
                                    gaps = mysc.dpi(config.tooltip.gaps, s),
                                    --> Needed as tooltip.opacity does not
                                    --> seem to have any effect on the bg
                                    bg = gears.color.change_opacity(
                                        table.get_dynamic(config.color.bg),
                                        config.tooltip.opacity
                                    ),
                                    fg = table.get_dynamic(config.color.fg),
                                    margins = mysc.dpi(config.tooltip.margins, s),
                                    preferred_alignments = {"middle", "back", "front"},
                                    font = beautiful.fonts.main(config.tooltip.font_size),
                                    --> Timezone must be jumpstarted according to current object index
                                    markup = config.tooltip.format(config.timezones[current.index])
                                }), "tooltip"
                            ), link_to(
                                {
                                    {
                                        {
                                            link_to(
                                                {
                                                    halign = "center",
                                                    refresh = config.refresh,
                                                    format = config.time.format,
                                                    --> Timezone must be jumpstarted
                                                    --> according to current object index
                                                    timezone = config.timezones[current.index],
                                                    font = beautiful.fonts.main(config.time.font_size),
                                                    widget = wibox.widget.textclock
                                                }, "clock"
                                            ),
                                            fg = table.get_dynamic(config.time.fg),
                                            widget = wibox.container.background
                                        },
                                        margins = mysc.dpi(config.margins, s),
                                        widget = wibox.container.margin
                                    },
                                    bg = beautiful.color.static.transparent,
                                    shape = mysc.shape("rounded_rect", (taskbar_height/2), s),
                                    buttons = {
                                        awful.button({
                                            modifiers = {},
                                            group = "clock",
                                            button = awful.button.names.RIGHT,
                                            description = "Switch to the next timezone",
                                            on_release = current.actions.next
                                        }),
                                        awful.button({
                                            modifiers = {},
                                            group = "clock",
                                            button = awful.button.names.SCROLL_UP,
                                            description = "Switch to the next timezone",
                                            on_release = current.actions.next
                                        }),
                                        awful.button({
                                            modifiers = {},
                                            group = "clock",
                                            button = awful.button.names.MIDDLE,
                                            description = "Switch to the first timezone",
                                            on_release = current.actions.home
                                        }),
                                        awful.button({
                                            modifiers = {},
                                            group = "clock",
                                            button = awful.button.names.LEFT,
                                            description = "Switch to the previous timezone",
                                            on_release = current.actions.prev
                                        }),
                                        awful.button({
                                            modifiers = {},
                                            group = "clock",
                                            button = awful.button.names.SCROLL_DOWN,
                                            description = "Switch to the previous timezone",
                                            on_release = current.actions.prev
                                        })
                                    },
                                    widget = wibox.container.background
                                }, "main"
                            )
                        ), {bg = beautiful.color.static.click}
                    ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}
                ), function() return current.timers.home:start() end, "mouse::leave", (not current.timers.home)
            ), function() return current.timers.home:stop() end, "mouse::enter", (not current.timers.home)
        ) --> Proper tail call
    end
    -->> Always return what must be returned
    return self.clocks[s.index].widget.main
end
-- =========================================================>
--> Resets the clock for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.clocks[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.clocks[s.index] = nil
        --> Restarts the widget if needed
        if (restart) then
            --> Current screen-specific configuration
            local config = beautiful.clock
            --> Ensure the object's state
            --> remains the same trough restarts
            config.state = current.widget.tooltip.visible
            --> Ensure the object's timer
            --> remains the same trough restarts
            config.timer = current.timers.home and current.timers.home.started
            --> Ensure the object's index
            --> remains the same trough restarts
            config.index = current.index
            --> Initialize the new object
            self:init(s)
        end
        --> Stop the home timer if needed and
        --> allow it to be garbage-collected
        if (current.timers.home) then
            current.timers.home:stop()
        end
        --> Stop the tooltip timer if needed and
        --> allow it to be garbage-collected
        if (current.timers.tooltip) then
            current.timers.tooltip:stop()
        end
        --> Remove tooltip from main widget to ensure garbage-collection
        current.widget.tooltip:remove_from_object(current.widget.main)
        --> Hide the tooltip
        current.widget.tooltip.visible = false
        --> Turning the tooltip's internal wibox invisible is
        --> necessary as to really turn the tooltip invisible
        current.widget.tooltip.wibox.visible = false
        --> Remove references to the objects on awesome's end
        current.widget.main.visible = false
    end
end
-- =========================================================>
return this
