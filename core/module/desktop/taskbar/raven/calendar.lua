
-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                         CALENDAR
-- =========================================================>
----> AwesomeWM Taskbar Raven Sidebar Calendar Widget:
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
local link = require("util.link")
local mysc = require("util.mysc")
local text = require("util.text")
local event = require("util.event")
local table = require("util.table")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
local time = os.time
local date = os.date
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {calendars = {}}
-- =========================================================>
--  [Functions] Calendar:
-- =========================================================>
--> Initializes the calendar for screen (s):
-- =========================================================>
function this:init(s)
    -->> Current screen-specific object reference
    self.calendars[s.index] = {widget = {}}
    local current = self.calendars[s.index]

    -->> Code shortening declarations
    local config = beautiful.calendar
    local link_to = function(widget, key)
        return link.to(current.widget, widget, key) --> Proper tail call
    end

    -->> Current object offset
    current.offset = (config.offset or 0)

    -->> Current object actions
    current.actions = { -- event on day change for updating calendar
        home = function()
            current.offset = 0
            return current.actions.update() --> Proper tail call
        end,
        next = function(offset)
            current.offset = current.offset + (offset or 1)
            return current.actions.update() --> Proper tail call
        end,
        prev = function(offset)
            current.offset = current.offset - (offset or 1)
            return current.actions.update() --> Proper tail call
        end,
        update = function()
            -->> Code shortening declarations
            local now = date("*t")
            local offdate = function(offset, day)
                local offdt = date("*t", time({
                    year = now.year,
                    month = (now.month + current.offset + (offset or 0)),
                    day = (day or now.day)
                }))
                offdt.wday = ((offdt.wday ~= 1) and offdt.wday - 1 or 7)
                offdt.wday = ((offdt.wday ~= 1) and offdt.wday - 1 or 7)
                return offdt
            end

            -->> Previous, current and next month ranges to add to the calendar
            local sections = {
                {
                    from = (1 + offdate(0, 0).day - offdate(0, 1).wday),
                    to = offdate(0, 0).day, --> Prev month, last day
                    date = offdate(-1, 1) --> Prev month, first day
                },
                {
                    from = 1,
                    to = offdate(1, 0).day, --> This month, last day
                    today = ((current.offset == 0) and offdate().day or true),
                    date = offdate(0, 1) --> This month, first day
                },
                {
                    from = 1,
                    to = (42 - (offdate(0, 1).wday + offdate(1, 0).day)),
                    date = offdate(1, 1) --> Next month, first day
                }
            }

            -->> Sets the corresponding (month year) header text
            current.widget.header.markup = text.bold(
                text.capitalize(
                    date("%B %Y",  time(
                        offdate()
                    ))
                )
            )

            -->> Removes all cells from the grid
            current.widget.grid:reset()

            -->> Inserts the weekdays to the grid
            for i=1,7 do
                current.widget.grid:add(
                    current.widget.wdays[i]
                )
            end

            -->> Inserts the three sections days to the grid
            for i=1,3 do
                local section = sections[i]
                for day=section.from, section.to do
                    current.widget.grid:add(
                        sfx.on_hover(
                            sfx.on_press(
                                {
                                    {
                                        {
                                            markup = day,
                                            halign = "center",
                                            opacity = (section.today and 1 or 0.6),
                                            font = beautiful.fonts.main(config.daycell.font_size),
                                            widget = wibox.widget.textbox
                                        },
                                        forced_width = dpi(config.daycell.size, s),
                                        forced_height = dpi(config.daycell.size, s),
                                        widget = wibox.container.place
                                    },
                                    shape = gears.shape.circle,
                                    forced_width = dpi(config.daycell.size, s),
                                    forced_height = dpi(config.daycell.size, s),
                                    bg = (((section.today == day) and table.get_dynamic(config.daycell.background)) or beautiful.color.static.transparent),
                                    widget = wibox.container.background
                                }, {bg = beautiful.color.static.click}, (section.today == day)
                            ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}, (section.today == day)
                        )
                    )
                end
            end
            --> Return current object
            return current.widget.main
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
            callback = current.actions.home
        })
    end

    -->> Calendar object weekdays widgets
    current.widget.wdays = {}
    for i,wday in next, config.weekcell.names do
        current.widget.wdays[i] = wibox.widget({
            {
                halign = "center",
                markup = text.bold(wday),
                font = beautiful.fonts.main(config.weekcell.font_size),
                widget = wibox.widget.textbox
            },
            shape = gears.shape.circle,
            bg = beautiful.color.static.transparent,
            forced_width = dpi(config.daycell.size * 1.2, s),
            forced_height = dpi(config.daycell.size * 1.2, s),
            fg = table.get_dynamic(config.weekcell.foreground),
            widget = wibox.container.background
        })
    end

    -->> Current object widget
    event.connect(
        event.connect(
            link_to(
                {
                    {
                        {
                            {
                                sfx.on_hover(
                                    sfx.on_press(
                                        {
                                            {
                                                {
                                                    auto_dpi = true,
                                                    halign = "center",
                                                    scaling_quality = "best",
                                                    image = gears.color.recolor_image(
                                                        beautiful.icon.image.dart.left,
                                                        table.get_dynamic(config.buttons.color)
                                                    ),
                                                    forced_width = dpi(config.buttons.size * 0.6, s),
                                                    forced_height = dpi(config.buttons.size * 0.6, s),
                                                    widget = wibox.widget.imagebox
                                                },
                                                forced_width = dpi(config.buttons.size, s),
                                                forced_height = dpi(config.buttons.size, s),
                                                widget = wibox.container.place
                                            },
                                            shape = gears.shape.circle,
                                            bg = beautiful.color.static.transparent,
                                            forced_width = dpi(config.buttons.size, s),
                                            forced_height = dpi(config.buttons.size, s),
                                            buttons = {
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.LEFT,
                                                    description = "Change view to previous month",
                                                    on_release = function() 
                                                        return current.actions.prev() --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.MIDDLE,
                                                    description = "Change view to previous year",
                                                    on_release = function()
                                                        return current.actions.prev(12) --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.RIGHT,
                                                    description = "Change view to next month",
                                                    on_release = function() 
                                                        return current.actions.next() --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.SCROLL_UP,
                                                    description = "Change view to previous month",
                                                    on_release = function()
                                                        return current.actions.prev() --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.SCROLL_DOWN,
                                                    description = "Change view to next month",
                                                    on_release = function()
                                                        return current.actions.next() --> Proper tail call
                                                    end
                                                })
                                            },
                                            widget = wibox.container.background
                                        }, {bg = beautiful.color.static.click}
                                    ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}
                                ),
                                sfx.on_hover(
                                    sfx.on_press(
                                        {
                                            {
                                                link_to({
                                                    halign = "center",
                                                    font = beautiful.fonts.main("M"),
                                                    markup = text.bold("Month Year"),
                                                    widget = wibox.widget.textbox
                                                }, "header"),
                                                widget = wibox.container.place
                                            },
                                            bg = beautiful.color.static.transparent,
                                            fg = table.get_dynamic(config.buttons.color),
                                            shape = mysc.shape("rounded_rect", dpi(config.buttons.size, s), s),
                                            buttons = {
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.LEFT,
                                                    description = "Change view to current month",
                                                    on_release = function()
                                                        return current.actions.home() --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.SCROLL_UP,
                                                    description = "Change view to next year",
                                                    on_release = function()
                                                        return current.actions.next(12) --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.SCROLL_DOWN,
                                                    description = "Change view to previous year",
                                                    on_release = function()
                                                        return current.actions.prev(12) --> Proper tail call
                                                    end
                                                })
                                            },
                                            widget = wibox.container.background
                                        }, {bg = beautiful.color.static.click}
                                    ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}
                                ),
                                sfx.on_hover(
                                    sfx.on_press(
                                        {
                                            {
                                                {
                                                    auto_dpi = true,
                                                    halign = "center",
                                                    scaling_quality = "best",
                                                    image = gears.color.recolor_image(
                                                        beautiful.icon.image.dart.right,
                                                        table.get_dynamic(config.buttons.color)
                                                    ),
                                                    forced_width = dpi(config.buttons.size * 0.6, s),
                                                    forced_height = dpi(config.buttons.size * 0.6, s),
                                                    widget = wibox.widget.imagebox
                                                },
                                                forced_width = dpi(config.buttons.size, s),
                                                forced_height = dpi(config.buttons.size, s),
                                                widget = wibox.container.place
                                            },
                                            shape = gears.shape.circle,
                                            bg = beautiful.color.static.transparent,
                                            forced_width = dpi(config.buttons.size, s),
                                            forced_height = dpi(config.buttons.size, s),
                                            buttons = {
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.LEFT,
                                                    description = "Change view to next month",
                                                    on_release = function()
                                                        return current.actions.next() --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.MIDDLE,
                                                    description = "Change view to next year",
                                                    on_release = function()
                                                        return current.actions.next(12) --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.RIGHT,
                                                    description = "Change view to previous month",
                                                    on_release = function()
                                                        return current.actions.prev() --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.SCROLL_UP,
                                                    description = "Change view to next month",
                                                    on_release = function() 
                                                        return current.actions.next() --> Proper tail call
                                                    end
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "calendar",
                                                    button = awful.button.names.SCROLL_DOWN,
                                                    description = "Change view to previous month",
                                                    on_release = function() 
                                                        return current.actions.prev() --> Proper tail call
                                                    end
                                                })
                                            },
                                            widget = wibox.container.background
                                        }, {bg = beautiful.color.static.click}
                                    ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}
                                ),
                                layout = wibox.layout.align.horizontal
                            },
                            link_to(
                                {
                                    expand = true,
                                    homogeneous = true,
                                    spacing = dpi(4, s),
                                    forced_num_rows = 7,
                                    forced_num_cols = 7,
                                    layout = wibox.layout.grid
                                }, "grid"
                            ),
                            spacing = dpi(5, s),
                            layout = wibox.layout.fixed.vertical
                        },
                        margins = dpi(15, s),
                        widget = wibox.container.margin
                    },
                    bg = beautiful.color.static.widget,
                    shape = mysc.shape("rounded_rect", 20, s),
                    shape_border_width = dpi(config.thickness, s),
                    shape_border_color = table.get_dynamic(config.color),
                    widget = wibox.container.background
                }, "main"
            ), function() return current.timer:start() end, "mouse::leave", (not current.timer)
        ), function() return current.timer:stop() end, "mouse::enter", (not current.timer)
    )

    return current.actions.update() --> Proper tail call
end
-- =========================================================>
--> Resets the taskbar for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.calendars[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.calendars[s.index] = nil
        --> Restarts the widget if needed
        if (restart) then
            --> Current screen-specific configuration
            local config = beautiful.calendar
            --> Save offset state in config
            config.offset = current.offset
            --> Ensure the object's timer
            --> remains the same trough restarts
            config.timer = (current.timer and current.timer.started)
            --> Initialize the new object
            self:init(s)
            --> Update calendar according to its offset
            self.calendars[s.index].actions.update()
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
