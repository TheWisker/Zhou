-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          NAUGHT
-- =========================================================>
----> AwesomeWM Taskbar Naught Sidebar Widget
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
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
--  [Imports] Libraries:
-- =========================================================>
local rubato = require("lib.rubato")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {naughts = {}, signal = false}
-- =========================================================>
--  [Functions] Naught:
-- =========================================================>
--> Initializes the naught for screen (s):
-- =========================================================>
function this:init(s)
    -->> Naught guard
    if (not self.naughts[s.index]) then
        -->> Current screen-specific object reference
        self.naughts[s.index] = {widget = {}, tail = {}, index = 2}
        local current = self.naughts[s.index]

        -->> Code shortening declarations
        local spacing = dpi(beautiful.spacing, s)
        local config = beautiful.get_config("naught", s)
        local taskbar = beautiful.get_config("taskbar", s)
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        taskbar = { --> Reuses the stack level previously used by taskbar
            is_top = taskbar.position == "top",
            margin = dpi(mysc.index(taskbar.margins, "right") or 0, s),
            height = {
                normal = dpi(taskbar.height, s),
                padded = dpi(taskbar.height + 2 * taskbar.padding, s)
            }
        }
        local size = {
            width = dpi(config.width, s),
            height = s.geometry.height - (taskbar.height.normal + (spacing * 2))
        }

        -->> Current object state
        current.state = (config.state == nil) and config.visible or config.state

        -->> Current object actions
        current.actions = {
            -->> Switch between open and closed states
            switch = function()
                if current.state then
                    return current.actions.close() --> Proper tail call
                else
                    return current.actions.open() --> Proper tail call
                end
            end,
            -->> Open the object throught its animation
            open = function()
                current.state = true
                current.widget.main.visible = true
                current.animations.opacity.target = config.opacity
            end,
            -->> Close the object throught its animation
            close = function()
                current.state = false
                current.animations.opacity.target = 0
            end,
            -->> Add a naughtification to the list
            add = function(n)


                -- MAKE naught constructor and only keep record of n not widgets
                -- max n number in btful
                return current.widget.list:insert(current.index, n) --> Proper tail call
            end,
            -->> Scroll up trough the list
            scroll_up = function()
                local layout = current.widget.list
                layout:insert(((#(layout.children)) + 1), layout.children[1])
                layout:remove(1)
                if ((current.index - 1) <= 0) then
                    current.index = #(layout.children)
                else
                    current.index = current.index - 1
                end
            end,
            -->> Scroll down trough the list
            scroll_down = function()
                local layout = current.widget.list
                layout:insert(1, layout.children[#(layout.children)])
                layout:remove(#(layout.children))
                if ((current.index + 1) > (#(layout.children))) then
                    current.index = 1
                else
                    current.index = current.index + 1
                end
            end
        }

        -->> Current object animations
        current.animations = {
            -->> Object opacity in-and-out animation
            opacity = rubato.timed({
                rate = beautiful.animation.fps,
                --> Opacity must be jumpstarted
                --> according to current object state
                pos = current.state and config.opacity or 0,
                easing = beautiful.animation.widget.raven.easing,
                duration = beautiful.animation.widget.raven.duration,
                subscribed = function(pos)
                    --> Change the bg's opacity instead of widgets opacity
                    --> as the latter does not have any effect on the widget
                    current.widget.main.bg = gears.color.change_opacity(
                        table.get_dynamic(config.color.background),
                        pos
                    )
                    --> Object child widget opacity must also be animated
                    --> in order to also affect all the object's children
                    --> This division always ensures opacity will reach 1
                    current.widget.margin.opacity = pos / config.opacity
                end,
                end_callback = function(pos)
                    --> On 'out' completion make the widget not visible
                    if pos == 0 then
                        current.widget.main.visible = false
                    end
                end
            })
        }

        -->> Current object timer
        current.timer = gears.timer({
            call_now = false,
            single_shot = true,
            timeout = config.timeout,
            autostart = config.timer,
            -->> Timer on-timeout callback
            callback = function()
                --> Only close if opened
                if current.state then
                    current.actions.close()
                end
            end
        })

        -->> Signal single-time guarded connection
        if not self.signal then
            -->> When a notification is destroyed
            naughty.connect_signal(
                "destroyed",
                function(n)

                    local config = config.notification
                    local background = gears.color.change_opacity(
                        table.get_dynamic(config.background),
                        config.opacity
                    )

                    local notification = {
                        {
                            {
                                {
                                    {
                                        {
                                            font = beautiful.fonts.main(config.text.app.font_size),
                                            markup = text.bold(
                                                text.color(
                                                    text.capitalize(n.app_name),
                                                    table.get_dynamic(config.text.app.foreground)
                                                )
                                            ),
                                            widget = wibox.widget.textbox
                                        }, nil, nil,
                                        layout = wibox.layout.align.horizontal
                                    },
                                    margins = mysc.margins(8, 12, s),
                                    widget = wibox.container.margin
                                },
                                bg = background,
                                widget = wibox.container.background
                            },
                            {
                                {
                                    {
                                        {
                                            {
                                                {
                                                    {
                                                        {
                                                            auto_dpi = true,
                                                            halign = "center",
                                                            scaling_quality = "best",
                                                            forced_width = dpi(config.icon.size, s),
                                                            forced_height = dpi(config.icon.size, s),
                                                            image = (n.icon or beautiful.icon.image.notification),
                                                            widget = wibox.widget.imagebox
                                                        },
                                                        border_color = background,
                                                        shape = config.icon.shape,
                                                        bg = (config.icon.hollow and
                                                            "#00000000" or
                                                            background),
                                                        border_width = dpi(config.icon.thickness, s),
                                                        widget = wibox.container.background
                                                    },
                                                    strategy = "exact",
                                                    width = dpi(config.icon.size, s),
                                                    height = dpi(config.icon.size, s),
                                                    widget = wibox.container.constraint
                                                },
                                                {
                                                    nil, nil,
                                                    {
                                                        nil, nil,
                                                        {
                                                            {
                                                                halign = "center",
                                                                font = beautiful.fonts.icon(
                                                                    dpi(config.icon.size * 0.2, s),
                                                                    "Round"
                                                                ),
                                                                markup = text.color(
                                                                    "", --WIP
                                                                    table.get_dynamic(config.icon.foreground)
                                                                ),
                                                                widget = wibox.widget.textbox
                                                            },
                                                            bg = background,
                                                            shape = config.icon.shape,
                                                            forced_width = dpi(config.icon.size * 0.4, s),
                                                            forced_height = dpi(config.icon.size * 0.4, s),
                                                            widget = wibox.container.background
                                                        },
                                                        expand = "none",
                                                        layout = wibox.layout.align.horizontal
                                                    },
                                                    expand = "none",
                                                    layout = wibox.layout.align.vertical
                                                },
                                                layout = wibox.layout.stack
                                            },
                                            {
                                                {
                                                    {
                                                        markup = text.color(
                                                            text.bold(n.title),
                                                            table.get_dynamic(config.text.title.foreground)
                                                        ),
                                                        font = beautiful.fonts.main(config.text.title.font_size),
                                                        widget = wibox.widget.textbox
                                                    },
                                                    fps = config.text.scroll.fps,
                                                    speed = config.text.scroll.speed,
                                                    step_function = config.text.scroll.step_function,
                                                    widget = wibox.container.scroll.horizontal
                                                },
                                                {
                                                    {
                                                        markup = text.color(
                                                            n.message,
                                                            table.get_dynamic(config.text.message.foreground)
                                                        ),
                                                        font = beautiful.fonts.main(config.text.message.font_size),
                                                        widget = wibox.widget.textbox
                                                    },
                                                    fps = config.text.scroll.fps,
                                                    speed = config.text.scroll.speed,
                                                    step_function = config.text.scroll.step_function,
                                                    widget = wibox.container.scroll.horizontal
                                                },
                                                layout = wibox.layout.fixed.vertical
                                            },
                                            spacing = dpi(10, s),
                                            layout = wibox.layout.fixed.horizontal
                                        },
                                        {
                                            {
                                                --> Set notification of the actions
                                                notification = n,
                                                --> Change default styling
                                                style = {
                                                    underline_normal = false,
                                                    underline_selected = false
                                                },
                                                widget_template = {
                                                    {
                                                        {
                                                            {
                                                                --> Tells Awesome to set the action's text in this widget
                                                                id = "text_role",
                                                                --> Boldness must be set in the font as we do not manage this
                                                                --> widget's text and thus cannot format it every time it changes
                                                                font = beautiful.fonts.main(config.actions.font_size, "Bold"),
                                                                widget = wibox.widget.textbox
                                                            },
                                                            margins = mysc.dpi(config.actions.margins, s),
                                                            widget = wibox.container.margin
                                                        },
                                                        widget = wibox.container.place
                                                    },
                                                    bg = background,
                                                    forced_width = dpi(config.actions.size.width, s),
                                                    forced_height = dpi(config.actions.size.height, s),
                                                    fg = table.get_dynamic(config.actions.foreground),
                                                    widget = wibox.container.background
                                                },
                                                --> Must be wibox widget because of internal workings
                                                base_layout = link_to( -- remove ??
                                                    {
                                                        spacing = dpi(config.actions.spacing, s),
                                                        layout = wibox.layout.flex.horizontal
                                                    }, "actions"
                                                ),
                                                widget = naughty.list.actions
                                            },
                                            visible = (#(n.actions) >= 1),
                                            shape = mysc.shape("rounded_rect", config.actions.radius, s),
                                            widget = wibox.container.background
                                        },
                                        spacing = dpi(((#(n.actions) >= 1) and 10 or 0), s),
                                        layout = wibox.layout.fixed.vertical
                                    },
                                    margins = mysc.margins(15, 18, s),
                                    widget = wibox.container.margin
                                },
                                --> Set opacity in bg
                                bg = color.solid_gradient(
                                    n.bg,
                                    {
                                        from = {0, 0},
                                        type = "linear",
                                        --> Same as notification size
                                        to = mysc.dpi({
                                            config.size.width,
                                            config.size.height
                                        })
                                    },
                                    config.opacity
                                ),
                                widget = wibox.container.background
                            },
                            layout = wibox.layout.fixed.vertical
                        },
                        opacity = 0.6, --btfl
                        shape = mysc.shape("rounded_rect", config.radius, s),
                        widget = wibox.container.background
                    }

                    current.actions.add(wibox.widget(notification))
                end
            )
            -->> Lock guard
            self.signal = true
        end

        -->> Current object widget
        link_to(
            event.connect(
                event.connect(
                    awful.popup({
                        screen = s,
                        ontop = true,
                        type = "popup_menu",
                        cursor = config.cursor,
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
                            current.state and config.opacity or 0
                        ),
                        shape = mysc.shape("rounded_rect", size.height/config.radius, s),
                        placement = mysc.placement("right", {
                            margins = {
                                top = spacing + (taskbar.is_top and taskbar.height.padded or 0),
                                bottom = spacing + (taskbar.is_top and 0 or taskbar.height.padded),
                                right = spacing + taskbar.margin
                            }
                        }),
                        widget = link_to(
                            {
                                {
                                    {
                                        halign = "center",
                                        markup = text.color(
                                            text.italic(text.bold("&lt;/NAUGHT&gt;")),
                                            table.get_dynamic(config.notification.text.title.foreground)
                                        ),
                                        font = beautiful.fonts.main(65),
                                        widget = wibox.widget.textbox
                                    },
                                    link_to(
                                        {
                                            {
                                                forced_height = dpi(10, s),
                                                shape = gears.shape.rounded_bar,
                                                bg = gears.color.change_opacity(
                                                    table.get_dynamic(beautiful.color.dynamic.foreground),
                                                    config.notification.opacity - 0.2
                                                ),
                                                widget = wibox.container.background
                                            },
                                            spacing = dpi(15, s),
                                            buttons = {
                                                awful.button({
                                                    modifiers = {},
                                                    group = "naught",
                                                    button = awful.button.names.LEFT,
                                                    description = "Scroll up the naughtifications",
                                                    on_release = current.actions.scroll_up
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "naught",
                                                    button = awful.button.names.RIGHT,
                                                    description = "Scroll down the naughtifications",
                                                    on_release = current.actions.scroll_down
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "naught",
                                                    button = awful.button.names.SCROLL_UP,
                                                    description = "Scroll up the naughtifications",
                                                    on_release = current.actions.scroll_up
                                                }),
                                                awful.button({
                                                    modifiers = {},
                                                    group = "naught",
                                                    button = awful.button.names.SCROLL_DOWN,
                                                    description = "Scroll down the naughtifications",
                                                    on_release = current.actions.scroll_down
                                                })
                                            },
                                            layout = wibox.layout.fixed.vertical
                                        }, "list"
                                    ),
                                    spacing = size.width/20,
                                    layout = wibox.layout.fixed.vertical
                                },
                                margins = size.width/10,
                                --> Opacity must be jumpstarted
                                --> according to current object state
                                opacity = current.state and 1 or 0,
                                widget = wibox.container.margin
                            }, "margin"
                        )
                    }), function() current.timer:start() end, "mouse::leave"
                ), function() current.timer:stop() end, "mouse::enter"
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
                                beautiful.icon.naught,
                                table.get_dynamic(config.color.icon)
                            ),
                            widget = wibox.widget.imagebox
                        },
                        forced_width = taskbar.height.normal,
                        forced_height = taskbar.height.normal,
                        bg = "#00000000",
                        shape = mysc.shape("rounded_rect", taskbar.height.normal/2, s),
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
    return self.naughts[s.index].widget.evoker
end
-- =========================================================>
--> Resets the naught for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.naughts[s.index]
    -->> If there is an object then reset it
    if current then
        --> Remove references to the object on our end
        self.naughts[s.index] = nil
        --> Restarts the widget if needed
        if restart then
            --> Current screen-specific configuration
            local config = beautiful.get_config("naught", s)
            --> Ensure the object's state
            --> remains the same trough restarts
            config.state = current.state
            --> Ensure the object's timer
            --> remains the same trough restarts
            config.timer = current.timer.started
            --> Initialize the new object
            self:init(s)
        end
        --> Stop the timer if needed and allow it to be garbage-collected
        if current.timer then current.timer:stop() end
        --> Remove references to the object on awesome's end
        current.widget.main.visible = false
    end
end
-- =========================================================>
return this
