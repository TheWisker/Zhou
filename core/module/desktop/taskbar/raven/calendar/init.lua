
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
--  [TODO] Calendar:
-- =========================================================>

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
local text = require("util.text")
local event = require("util.event")
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
function this:init(s)
    -->> Current screen-specific object reference
    self.calendars[s.index] = {widget = {}, offset = 0}
    local current = self.calendars[s.index]

    -->> Code shortening declarations
    local notes = notes:init(s, this)
    local config = beautiful.get_config("calendar", s)
    local link_to = function(widget, key)
        return link.to(current.widget, widget, key)
    end
    local taskbar_height = dpi(beautiful.get_config("taskbar", s).height, s)

    -->> Current object actions
    current.actions = { -- event on day change for updating calendar
        home = function()
            current.offset = 0
            current.actions.update()
        end,
        next = function(offset)
            current.offset = current.offset + (offset or 1)
            current.actions.update()
        end,
        prev = function(offset)
            current.offset = current.offset - (offset or 1)
            current.actions.update()
        end,
        update = function()
            -->> Code shortening declarations
            local now = date("*t")
            local offdate = function(offset, day)
                local offdt = date("*t", time({
                    year = now.year,
                    month = now.month + current.offset + (offset or 0),
                    day = day or now.day
                }))
                offdt.wday = (offdt.wday ~= 1) and offdt.wday - 1 or 7
                offdt.wday = (offdt.wday ~= 1) and offdt.wday - 1 or 7
                return offdt
            end

            -->> Previous, current and next month ranges to add to the calendar
            local sections = {
                {
                    from = 1 + offdate(0, 0).day - offdate(0, 1).wday,
                    to = offdate(0, 0).day, --> Prev month, last day
                    date = offdate(-1, 1) --> Prev month, first day
                },
                {
                    from = 1,
                    to = offdate(1, 0).day, --> This month, last day
                    today = (current.offset == 0) and offdate().day or true,
                    date = offdate(0, 1) --> This month, first day
                },
                {
                    from = 1,
                    to = 42 - (offdate(0, 1).wday + offdate(1, 0).day),
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
                    local has_note = notes.exists(
                        gears.table.crush(section.date, {day = day})
                    )
                    local has_deleted = notes.exists(
                        gears.table.crush(section.date, {day = day}),
                        ".del"
                    )
                    current.widget.grid:add(
                        sfx.on_hover(
                            sfx.on_press(
                                {
                                    {
                                        markup = day,
                                        halign = "center",
                                        font = beautiful.fonts("medium"),
                                        opacity = section.today and 1 or 0.6,
                                        widget = wibox.widget.textbox
                                    },
                                    shape = gears.shape.circle,
                                    forced_width = taskbar_height,
                                    forced_height = taskbar_height,
                                    buttons = {
                                        awful.button({
                                            modifiers = {},
                                            button = awful.button.names.LEFT,
                                            on_release = function()

                                            end
                                        }),
                                        awful.button({
                                            modifiers = {},
                                            button = awful.button.names.MIDDLE,
                                            on_release = function()

                                            end
                                        }),
                                        awful.button({
                                            modifiers = {},
                                            button = awful.button.names.RIGHT,
                                            on_release = function()

                                            end
                                        })
                                    },
                                    shape_border_color = beautiful.color.color6,
                                    shape_border_width = ((section.today == day) and has_note) and dpi(2) or 0,
                                    bg = ((section.today == day) and beautiful.color.color1) or (has_note and beautiful.color.color6) or "#00000000",
                                    widget = wibox.container.background
                                }, {bg = beautiful.color.click}, not section.today
                            ), {cursor = beautiful.cursor.button, bg = beautiful.color.hover}, not section.today
                        )
                    )
                end
            end
        end
    }

    -->> Current object timer
    current.timer = gears.timer({
        single_shot = true,
        timeout = config.timeout,
        callback = current.actions.home
    })

    current.timer:start() -- hot fix

    -->> Calendar object weekdays widgets
    current.widget.wdays = {}
    for i,wday in next, {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"} do
        current.widget.wdays[i] = wibox.widget({
            {
                halign = "center",
                markup = text.bold(wday),
                font = beautiful.fonts("medium"),
                widget = wibox.widget.textbox
            },
            bg = "#00000000",
            shape = gears.shape.circle,
            forced_width = taskbar_height, --taskbar height?? really??
            forced_height = taskbar_height,
            widget = wibox.container.background
        })
    end

    -->> Current object widget
    return event.connect(
        event.connect(
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
                                                forced_width = taskbar_height * 0.8,
                                                forced_height = taskbar_height * 0.8,
                                                image = gears.color.recolor_image(beautiful.icon.image.dart.left, beautiful.color.accent),
                                                widget = wibox.widget.imagebox
                                            },
                                            forced_width = taskbar_height * 1,
                                            forced_height = taskbar_height * 1,
                                            widget = wibox.container.place
                                        },
                                        bg = "#00000000",
                                        forced_width = taskbar_height,
                                        forced_height = taskbar_height,
                                        shape = function(cr, w, h)
                                            return gears.shape.rounded_rect(cr, w, h, taskbar_height/1.5)
                                        end,
                                        buttons = { -- WIP check actions???
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.LEFT,
                                                on_release = function()
                                                    current.actions.prev()
                                                end
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.MIDDLE,
                                                on_release = function()
                                                    current.actions.prev(12)
                                                end
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.RIGHT,
                                                on_release = function()
                                                    current.actions.next()
                                                end
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.SCROLL_UP,
                                                on_release = function()
                                                    current.actions.prev()
                                                end
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.SCROLL_DOWN,
                                                on_release = function()
                                                    current.actions.next()
                                                end
                                            })
                                        },
                                        widget = wibox.container.background
                                    }, {bg = beautiful.color.click, forced_width = taskbar_height * 0.8}
                                ), {bg = beautiful.color.hover, cursor = beautiful.cursor.button}
                            ),
                            sfx.on_hover(
                                sfx.on_press(
                                    {
                                        --{
                                            link_to({
                                                halign = "center",
                                                font = beautiful.fonts("large"),
                                                markup = text.bold("Month Year"),
                                                widget = wibox.widget.textbox
                                            }, "header"),
                                            --widget = wibox.container.place
                                        --},
                                        bg = "#00000000",
                                        fg = beautiful.color.color1,
                                        shape = function(cr, w, h)
                                            return gears.shape.rounded_rect(cr, w, h, taskbar_height)
                                        end,
                                        buttons = {
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.LEFT,
                                                on_release = function()
                                                    current.actions.home()
                                                end
                                            }),
                                            --awful.button({
                                                --modifiers = {},
                                                --button = awful.button.names.RIGHT,
                                                --on_release = function()
                                                    --current.actions.next(12)
                                                --end --cache
                                            --}),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.SCROLL_UP,
                                                on_release = function()
                                                    current.actions.next(12)
                                                end
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.SCROLL_DOWN,
                                                on_release = function()
                                                    current.actions.prev(12)
                                                end
                                            })
                                        },
                                        widget = wibox.container.background
                                    }, {bg = beautiful.color.click}
                                ), {bg = beautiful.color.hover, cursor = beautiful.cursor.button}
                            ),
                            sfx.on_hover(
                                sfx.on_press(
                                    {
                                        --{
                                            {
                                                auto_dpi = true,
                                                halign = "center",
                                                scaling_quality = "best",
                                                forced_width = taskbar_height * 0.4,
                                                forced_height = taskbar_height * 0.4,
                                                image = gears.color.recolor_image(beautiful.icon.image.dart.right, beautiful.color.accent),
                                                widget = wibox.widget.imagebox
                                            },
                                            --forced_width = dpi(40, s),
                                            --forced_height = dpi(50, s),
                                            --widget = wibox.container.place
                                        --},
                                        bg = "#00000000",
                                        forced_width = taskbar_height,
                                        forced_height = taskbar_height,
                                        shape = function(cr, w, h)
                                            return gears.shape.rounded_rect(cr, w, h, taskbar_height/1.5)
                                        end,
                                        buttons = {
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.LEFT,
                                                on_release = function()
                                                    current.actions.next()
                                                end
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.MIDDLE,
                                                on_release = function()
                                                    current.actions.next(12)
                                                end
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.RIGHT,
                                                on_release = function()
                                                    current.actions.prev()
                                                end
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.SCROLL_UP,
                                                on_release = function()
                                                    current.actions.next()
                                                end
                                            }),
                                            awful.button({
                                                modifiers = {},
                                                button = awful.button.names.SCROLL_DOWN,
                                                on_release = function()
                                                    current.actions.prev()
                                                end
                                            })
                                        },
                                        widget = wibox.container.background
                                    }, {bg = beautiful.color.click}
                                ), {bg = beautiful.color.hover, cursor = beautiful.cursor.button}
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
                bg = beautiful.color.widget,
                shape_border_width = dpi(2, s),
                shape_border_color = beautiful.color.border,
                shape = function(cr, w, h)
                    return gears.shape.rounded_rect(cr, w, h, 20)
                end,
                widget = wibox.container.background
            }, function() return current.timer:start() end, "mouse::leave"
        ), function() return current.timer:stop() end, "mouse::enter"
    )
end
-- =========================================================>
--> Updates the calendar widget for screen (s):
-- =========================================================>
function this:update(s)
    if self.calendars[s.index] then
        self.calendars[s.index].actions.update()
    end
end
-- =========================================================>
return this
