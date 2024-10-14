-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                       NOTIFICATIONS
-- =========================================================>
----> AwesomeWM Notifications
-- =========================================================>
--  [TODO] Notifications:
-- =========================================================>
-- Fix on hover close button cursor
-- Finish the sub-icons list for applications (l390)
-- Add hover effects on notification actions
---> Does not work as they get stuck, and I do not know why
-- Finish persistent notification color change respones (l660)
-- Make in-out animation toggable as to enable using picom's
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local menubar = require("menubar")
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
--  [Imports] Optimization:
-- =========================================================>
local next = next
local floor = math.floor
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {func = {}, dnd = false}
-- =========================================================>
--  [Config] Notifications:
-- =========================================================>
naughty.config = {
    --> Spacing between notifications
    spacing = dpi(20),
    --> Space between notifications and edge of the workarea
    padding = dpi(15),
    --> List of directories that will be checked by getIcon()
    icon_dirs = {"/usr/share/pixmaps/"},
    --> List of formats that will be checked by getIcon()
    icon_formats = {"svg", "png"},
    --> Default values for the params to naughty.notification{}
    defaults = {
        timeout = 8,
        ontop = true,
        screen = awful.screen.primary
    }
}
-- =========================================================>
--  [Functions] Notifications:
-- =========================================================>
--> Initialization of the notification handler:
-- =========================================================>
function this:init()
    -->> Code shortening declarations
    local link_fn = function(func, key)
        return link.to(self.func, func, key) --> Proper tail call
    end
    -->> Signal guard
    if (not self.func.icon) then
        -->> Connects the signal for notification (n) 'app_icon' lookup
        naughty.connect_signal(
            "request::icon",
            link_fn(
                function(n, context, hints)
                    --> Only handle app_icon context
                    if (context ~= "app_icon") then
                        return
                    end
                    --> Perform XDG lookup
                    local path = menubar.utils.lookup_icon(hints.app_icon) or
                        menubar.utils.lookup_icon(hints.app_icon:lower())
                    --> If an icon was found set it
                    if (path) then
                        n.icon = path
                    end
                end, "icon"
            )
        )
    end
    -->> Signal guard
    if (not self.func.display) then
        -->> Connects the signal for notification (n) creation
        naughty.connect_signal(
            "request::display",
            link_fn(
                function(n, _, args)
                    -->> Do not disturb guard
                    if (self.dnd and (n.urgency ~= "critical")) then
                        --> Destroy the notification before it even appears
                        return n:destroy(naughty.notification_closed_reason.silent) --> Proper tail call
                    end

                    -->> Current notification-specific object reference
                    local current = {widget = {}, func = {}}

                    -->> Code shortening declarations
                    local s = n.screen
                    local config = beautiful.notification
                    local background = gears.color.change_opacity(
                        table.get_dynamic(config.background),
                        config.opacity
                    )

                    -->> Code shortening functions
                    local link_fn = function(func, key)
                        return link.to(current.func, func, key) --> Proper tail call
                    end
                    local link_to = function(widget, key)
                        return link.to(current.widget, widget, key) --> Proper tail call
                    end

                    -->> Current object actions
                    current.actions = {
                        -->> Reset the notification timeout
                        reset = function()
                            current.animations.arcbar.target = 0
                        end,
                        -->> Destroy the notification with reason
                        destroy = function(reason)
                            current.animations.arcbar.pause = true
                            --> Destroy the notification
                            return n:destroy(reason) --> Proper tail call
                        end
                    }

                    -->> Current object animations
                    current.animations = {
                        -->> Object arcbar loadbar expiring animation
                        arcbar = rubato.timed({
                            pos = 0,
                            rate = beautiful.animation.fps,
                            --> Timeout must be jumpstarted
                            --> according to its real value
                            duration = (n.timeout_value or n.timeout),
                            easing = beautiful.animation.widget.notification.easing,
                            subscribed = function(pos)
                                --> If notification is permanent there wont be a arcbar
                                if (current.widget.arcbar) then
                                    current.widget.arcbar.value = pos
                                end
                            end,
                            end_callback = function(pos)
                                if (pos == 100) then
                                    --> On arcbar expire destroy notification
                                    return current.actions.destroy(naughty.notification_closed_reason.expired) --> Proper tail call
                                elseif (pos == 0) then
                                    --> Reset animation gracefully
                                    current.animations.arcbar.target = 100
                                end
                            end
                        })
                    }

                    -->> Current notification object crush override
                    gears.table.crush(
                        n,
                        {
                            --> Save original arguments
                            args = args,
                            --> We remove the residency as
                            --> we are managing it ourselves
                            resident = true,
                            --> Save interface and
                            --> bind lifetime with n's
                            current = current,
                            --> We remove the timeout as
                            --> we are managing it ourselves
                            timeout = 4294967, --> As 0 does not work as intended we use this ugly workaround
                            opacity = config.opacity,
                            position = config.position,
                            --> Ensure table exists even if empty
                            actions = (n.actions or mysc.null),
                            --> Save real timeout, even between restarts
                            timeout_value = (n.timeout_value or n.timeout),
                            --> Save real residency, even between restarts
                            resident_value = (n.resident_value or n.resident)
                        }
                    )

                    -->> Current notification object
                    gears.table.crush(
                        naughty.layout.box({
                            screen = s,
                            ontop = true,
                            --> Removes the thin border
                            --> that apperars otherwise
                            border_width = 0,
                            notification = n,
                            type = "notification",
                            cursor = config.cursor,
                            opacity = config.opacity,
                            bg = beautiful.color.static.transparent,
                            --> Add both right and left margins to the total width
                            maximum_width = dpi(config.size.width + (2 * s.selected_tag.gap), s),
                            --> Add only the top margin to the total width
                            maximum_height = dpi(config.size.height + s.selected_tag.gap, s),
                            widget_template = {
                                event.connect(
                                    event.connect(
                                        link_to(
                                            {
                                                {
                                                    {
                                                        {
                                                            {
                                                                link_to(
                                                                    {
                                                                        font = beautiful.fonts.main(config.text.app.font_size),
                                                                        markup = text.bold(
                                                                            text.color(
                                                                                text.capitalize(n.app_name),
                                                                                table.get_dynamic(config.text.app.foreground)
                                                                            )
                                                                        ),
                                                                        widget = wibox.widget.textbox
                                                                    }, "app"
                                                                ),
                                                                { --> Spacing
                                                                    forced_width = dpi(10, s),
                                                                    widget = wibox.container.background
                                                                },
                                                                --> Constructs one of both widgets (arcbar with close button or only close button)
                                                                mysc.choose(
                                                                    (current.animations.arcbar.duration ~= 0),
                                                                    function()
                                                                        return link_to(
                                                                            {
                                                                                value = 0,
                                                                                min_value = 0,
                                                                                max_value = 100,
                                                                                rounded_edge = true,
                                                                                opacity = config.arcbar.opacity,
                                                                                forced_width = dpi(config.arcbar.size, s),
                                                                                forced_height = dpi(config.arcbar.size, s),
                                                                                thickness = dpi(config.arcbar.thickness, s),
                                                                                colors = {
                                                                                    color.solid_gradient(
                                                                                        n.bg,
                                                                                        {
                                                                                            from = {0, 0},
                                                                                            type = "linear",
                                                                                            to = mysc.dpi({
                                                                                                config.arcbar.size,
                                                                                                config.arcbar.size
                                                                                            })
                                                                                        }
                                                                                    )
                                                                                },
                                                                                { --> Center widget
                                                                                    sfx.on_hover(
                                                                                        {
                                                                                            halign = "center",
                                                                                            markup = text.color(
                                                                                                text.bold(beautiful.icon.text.close),
                                                                                                table.get_dynamic(config.arcbar.icon.foreground)
                                                                                            ),
                                                                                            font = beautiful.fonts.icon(config.arcbar.icon.font_size, "Round"),
                                                                                            buttons = awful.button({
                                                                                                modifiers = {},
                                                                                                group = "notification",
                                                                                                button = awful.button.names.LEFT,
                                                                                                description = "Close and destroy the notification",
                                                                                                on_release = function()
                                                                                                    return current.actions.destroy(naughty.notification_closed_reason.dismissed_by_user) --> Proper tail call
                                                                                                end
                                                                                            }),
                                                                                            widget = wibox.widget.textbox
                                                                                        }, {cursor = beautiful.cursor.button}
                                                                                    ),
                                                                                    --> Margin needed to truly center the text icon
                                                                                    right = dpi(2, s),
                                                                                    widget = wibox.container.margin
                                                                                },
                                                                                widget = wibox.container.arcchart
                                                                            }, "arcbar"
                                                                        ) --> Proper tail call
                                                                    end,
                                                                    function()
                                                                        return sfx.on_hover(
                                                                            {
                                                                                halign = "center",
                                                                                markup = text.color(
                                                                                    text.bold(beautiful.icon.text.close),
                                                                                    table.get_dynamic(config.arcbar.icon.foreground)
                                                                                ),
                                                                                font = beautiful.fonts.icon(config.arcbar.icon.font_size, "Round"),
                                                                                buttons = awful.button({
                                                                                    modifiers = {},
                                                                                    group = "notification",
                                                                                    button = awful.button.names.LEFT,
                                                                                    description = "Close and destroy the notification",
                                                                                    on_release = function()
                                                                                        return current.actions.destroy(naughty.notification_closed_reason.dismissed_by_user) --> Proper tail call
                                                                                    end
                                                                                }),
                                                                                widget = wibox.widget.textbox
                                                                            }, {cursor = beautiful.cursor.button} -- does not work properly
                                                                        ) --> Proper tail call
                                                                    end
                                                                ),
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
                                                            link_to(
                                                                {
                                                                    {
                                                                        {
                                                                            {
                                                                                {
                                                                                    link_to(
                                                                                        {
                                                                                            auto_dpi = true,
                                                                                            halign = "center",
                                                                                            scaling_quality = "best",
                                                                                            forced_width = dpi(config.icon.size, s),
                                                                                            forced_height = dpi(config.icon.size, s),
                                                                                            image = (n.icon or beautiful.icon.image.notification),
                                                                                            widget = wibox.widget.imagebox
                                                                                        }, "icon"
                                                                                    ),
                                                                                    border_color = background,
                                                                                    shape = config.icon.shape,
                                                                                    bg = (config.icon.hollow and
                                                                                        beautiful.color(s).static.transparent or
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
                                                                                                dpi((config.icon.size * 0.2), s),
                                                                                                "Round"
                                                                                            ),
                                                                                            markup = text.color(
                                                                                                "",
                                                                                                table.get_dynamic(config.icon.foreground)
                                                                                            ),
                                                                                            widget = wibox.widget.textbox
                                                                                        },
                                                                                        bg = background,
                                                                                        shape = config.icon.shape,
                                                                                        forced_width = dpi((config.icon.size * 0.4), s),
                                                                                        forced_height = dpi((config.icon.size * 0.4), s),
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
                                                                                link_to(
                                                                                    {
                                                                                        markup = text.color(
                                                                                            text.bold(n.title),
                                                                                            table.get_dynamic(config.text.title.foreground)
                                                                                        ),
                                                                                        font = beautiful.fonts.main(config.text.title.font_size),
                                                                                        widget = wibox.widget.textbox
                                                                                    }, "title"
                                                                                ),
                                                                                fps = config.text.scroll.fps,
                                                                                speed = config.text.scroll.speed,
                                                                                step_function = config.text.scroll.step_function,
                                                                                widget = wibox.container.scroll.horizontal
                                                                            },
                                                                            {
                                                                                link_to(
                                                                                    {
                                                                                        markup = text.color(
                                                                                            n.message,
                                                                                            table.get_dynamic(config.text.message.foreground)
                                                                                        ),
                                                                                        font = beautiful.fonts.main(config.text.message.font_size),
                                                                                        widget = wibox.widget.textbox
                                                                                    }, "message"
                                                                                ),
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
                                                                    link_to(
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
                                                                                            margins = mysc.dpi(config.actions.space.margins, s),
                                                                                            widget = wibox.container.margin
                                                                                        },
                                                                                        --> We set the buttons here and not in its parent because
                                                                                        --> of 'naughty.list.actions' inner workings, as it seems to
                                                                                        --> remove or override our buttons of the top 'widget_template' widget
                                                                                        buttons = awful.button({
                                                                                            modifiers = {},
                                                                                            group = "action",
                                                                                            button = awful.button.names.LEFT,
                                                                                            description = "Close and destroy the notification if it is not resident",
                                                                                            on_release = function()
                                                                                                if (not n.resident_value) then
                                                                                                    return current.actions.destroy(naughty.notification_closed_reason.dismissed_by_user) --> Proper tail call
                                                                                                else
                                                                                                    return current.actions.reset() --> Proper tail call
                                                                                                end
                                                                                            end
                                                                                        }),
                                                                                        widget = wibox.container.place
                                                                                    },
                                                                                    bg = background,
                                                                                    forced_width = dpi(config.actions.size.width, s),
                                                                                    forced_height = dpi(config.actions.size.height, s),
                                                                                    fg = table.get_dynamic(config.actions.foreground),
                                                                                    widget = wibox.container.background
                                                                                },
                                                                                --> Must be wibox widget because of internal workings
                                                                                base_layout = wibox.widget({
                                                                                    spacing = dpi(config.actions.space.spacing, s),
                                                                                    layout = wibox.layout.flex.horizontal
                                                                                }),
                                                                                widget = naughty.list.actions
                                                                            },
                                                                            visible = (#(n.actions) >= 1),
                                                                            shape = mysc.shape("rounded_rect", config.actions.radius, s),
                                                                            widget = wibox.container.background
                                                                        }, "actions_bg"
                                                                    ),
                                                                    spacing = dpi(((#(n.actions) >= 1) and 10 or 0), s),
                                                                    layout = wibox.layout.fixed.vertical
                                                                }, "inbody"
                                                            ),
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
                                                shape = mysc.shape("rounded_rect", config.radius, s),
                                                widget = wibox.container.background
                                            }, "body"
                                        ), function() current.animations.arcbar.pause = false end, "mouse::leave"
                                    ), function() current.animations.arcbar.pause = true end, "mouse::enter"
                                ),
                                margins = mysc.dpi({top = s.selected_tag.gap, right = s.selected_tag.gap, left = s.selected_tag.gap}, s),
                                widget = wibox.container.margin
                            }
                        }),
                        --> Disables default on-click actions
                        {buttons = {}}
                    )

                    -->> Why use 'weak_connect_signal'?
                    --> We use 'weak_connect_signal' instead of 'connect_signal' as
                    --> to allow the signals to be disconnected when the functions are
                    --> garbage-collected. Having bound each function lifetime to 'current'
                    --> which has in turn its lifetime bound to 'n', at least until it is destroyed,
                    --> we ensure the signals disconnect automatically at some point after 'n' is destroyed.

                    -->> Signal for updating app_name
                    n:weak_connect_signal(
                        "property::app_name",
                        link_fn(
                            function(_, app)
                                current.widget.app.markup = text.bold(
                                    text.color(
                                        text.capitalize(app),
                                        table.get_dynamic(config.text.app.foreground)
                                    )
                                )
                                if (n.auto_reset_timeout) then
                                    return current.actions.reset() --> Proper tail call
                                end
                            end, "app"
                        )
                    )
                    -->> Signal for updating icon
                    n:weak_connect_signal(
                        "property::icon",
                        link_fn(
                            function(_, icon)
                                if (icon) then
                                    current.widget.icon.image = icon
                                    if (n.auto_reset_timeout) then
                                        return current.actions.reset() --> Proper tail call
                                    end
                                end
                            end, "icon"
                        )
                    )
                    -->> Signal for updating title
                    n:weak_connect_signal(
                        "property::title",
                        link_fn(
                            function(_, title)
                                current.widget.title.markup = text.color(
                                    text.bold(title),
                                    table.get_dynamic(config.text.title.foreground)
                                )
                                if (n.auto_reset_timeout) then
                                    return current.actions.reset() --> Proper tail call
                                end
                            end, "title"
                        )
                    )
                    -->> Signal for updating message
                    n:weak_connect_signal(
                        "property::message",
                        link_fn(
                            function(_, message)
                                current.widget.message.markup = text.color(
                                    message,
                                    table.get_dynamic(config.text.message.foreground)
                                )
                                if (n.auto_reset_timeout) then
                                    return current.actions.reset() --> Proper tail call
                                end
                            end, "message"
                        )
                    )
                    -->> Signal for updating actions
                    n:weak_connect_signal(
                        "property::actions",
                        link_fn(
                            function(_, actions)
                                current.widget.actions_bg.spacing = ((#actions) >= 1)
                                current.widget.inbody.spacing = dpi((((#actions) >= 1) and 10 or 0), s)
                                if (n.auto_reset_timeout) then
                                    return current.actions.reset() --> Proper tail call
                                end
                            end, "actions"
                        )
                    )

                    -->> Manages too many notifications on screen
                    for i=1,((#(naughty.active)) - floor(s.workarea.height / dpi((config.size.height + s.selected_tag.gap), s))) do
                        --> This must be done after setting current.animations.opacity.target to 1
                        n = naughty.active[i]
                        if (n and (n.current) and (n.current.animations.opacity.target ~= 0)) then
                            n.current.actions.destroy(naughty.notification_closed_reason.too_many_on_screen)
                        end
                    end

                    -->> Start arcbar animation
                    current.animations.arcbar.target = 100
                end, "display"
            )
        )
    end
end
-- =========================================================>
--> Resets the notifications with (restart):
-- =========================================================>
function this:reset(restart)
    --> Restarts the object if needed
    if (restart) then
        --> Loop trough all active notifications
        for _,n in next, naughty.active do
            --> If the norification is persistent
            if ((n.timeout_value == 0) and n.current) then
                --Change notification properties
            end
        end
    else
        -->> Clean last icon signal, if any
        if (self.func.icon) then
            naughty.disconnect_signal("request::icon", self.func.icon)
            self.func.icon = nil
        end
        -->> Clean last display signal, if any
        if (self.func.display) then
            naughty.disconnect_signal("request::display", self.func.display)
            self.func.display = nil
        end
        -->> Remove attached current from active notifications
        for _,n in next, naughty.active do
            n.current = nil
        end
    end
end
-- =========================================================>
--> Creates custom notification with arguments (args):
-- =========================================================>
function this.notify(args)
    -->> Configuration crushed:
    ----> Priority Order: args -> ...style[args.style] -> ...style.default
    args = gears.table.crush(
        gears.table.crush(
            gears.table.crush(
                {
                    app_name = "AwesomeWM Event"
                }, --> Make new table to not modify 'style.default'
                beautiful.notification.style.default
            ),
            beautiful.notification.style[args.style]
        ),
        args
    )
    -->> Process action objects
    if (args.actions) then
        local action = nil
        --> We asume that if there are any actions they are ours
        for i=1,(#(args.actions)) do
            action = args.actions[i]
            --> Create action
            args.actions[i] = naughty.action({
                position = i,
                name = action.name,
                selected = action.selected
            })
            --> Connect action callback
            args.actions[i]:connect_signal("invoked", action.func)
        end
    end
    -->> Notification object
    return naughty.notification(args) --> Proper tail call
end
-- =========================================================>
--> Usual lua assert that sends error notification on error
-- =========================================================>
function this:assert(value, message, actions)
    -->> If value is not false proceed as usual
    if (value) then return value end
    -->> If value is false create custom error notification
    return nil, self:notify({
        style = "error",
        message = message,
        actions = actions,
        title = "Assertion Failure"
    }) --> Proper tail call
end
-- =========================================================>
return this
