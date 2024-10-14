-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                         SESSION
-- =========================================================>
----> AwesomeWM Session Popup Widget
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
local table = require("util.table")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local screen = screen --> Awesome Global
-- =========================================================>
--  [Imports] Bind - Keyboard:
-- =========================================================>
local ks = require("module.bind.keys")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {session = nil}
-- =========================================================>
--  [Functions] Session:
-- =========================================================>
--> Initializes the session for the desktop:
-- =========================================================>
function this:init()
    -->> Session guard
    if (not self.session) then
        -->> Current screen-specific object reference
        self.session = {widget = {}}
        local current = self.session

        -->> Code shortening declarations
        local config = beautiful.session
        local link_to = function(widget, key, s)
            --> If screen table is not initialized
            if (not current.widget[s.index]) then
                --> Initialize empty
                current.widget[s.index] = {}
            end
            --> Make the link
            return link.to(current.widget[s.index], widget, key) --> Proper tail call
        end

        -->> Current object actions
        current.actions = {
            -->> Show the session menu
            show = function()
                for s in screen do
                    current.widget[s.index].main.visible = true
                end
                --> Start the keygrabber
                return current.keygrabber:start() --> Proper tail call
            end,
            -->> Hide the session menu
            hide = function()
                for s in screen do
                    current.widget[s.index].main.visible = false
                end
                --> Stop the keygrabber
                return current.keygrabber:stop() --> Proper tail call
            end,
            -->> Session related actions
            session = {
                exit = function()
                    
                end,
                lock = function()
                    return awful.spawn.with_shell(beautiful.exec.session.lock) --> Proper tail call
                end,
                sleep = function()
                    return awful.spawn.with_shell(beautiful.exec.session.sleep) --> Proper tail call
                end,
                restart = function()
                    return awful.spawn.with_shell(beautiful.exec.session.restart) --> Proper tail call
                end,
                suspend = function()
                    return awful.spawn.with_shell(beautiful.exec.session.suspend) --> Proper tail call
                end,
                shutdown = function()
                    return awful.spawn.with_shell(beautiful.exec.session.shutdown) --> Proper tail call
                end,
                hibernate = function()
                    return awful.spawn.with_shell(beautiful.exec.session.hibernate) --> Proper tail call
                end
            }
        }

        -->> Current object keygrabber
        current.keygrabber = awful.keygrabber({
            stop_event = "release",
            keybindings = {
                awful.key({
                    key = ks.E,
                    modifiers = {},
                    description = "Exit Session",
                    on_release = current.actions.session.exit
                }),
                awful.key({
                    key = ks.L,
                    modifiers = {},
                    description = "Lock Session",
                    on_release = current.actions.session.lock
                }),
                awful.key({
                    key = ks.S,
                    modifiers = {},
                    description = "Sleep Session",
                    on_release = current.actions.session.sleep
                }),
                awful.key({
                    key = ks.R,
                    modifiers = {},
                    description = "Restart Session",
                    on_release = current.actions.session.restart
                }),
                awful.key({
                    key = ks.Z,
                    modifiers = {},
                    description = "Suspend Session",
                    on_release = current.actions.session.suspend
                }),
                awful.key({
                    key = ks.P,
                    modifiers = {},
                    description = "Shutdown Session",
                    on_release = current.actions.session.shutdown
                }),
                awful.key({
                    key = ks.H,
                    modifiers = {},
                    description = "Hibernate Session",
                    on_release = current.actions.session.hibernate
                }),
                awful.key({
                    key = ks.Q,
                    modifiers = {},
                    description = "Close Session menu",
                    on_release = current.actions.hide
                }),
                awful.key({
                    key = ks.ESC,
                    modifiers = {},
                    description = "Close Session menu",
                    on_release = current.actions.hide
                })
            }
        })

        -->> Current object widget
        for s in screen do
            link_to(
                awful.popup({
                    screen = s,
                    ontop = true,
                    type = "splash",
                    visible = false,
                    cursor = config.cursor,
                    minimum_width = s.geometry.width,
                    maximum_width = s.geometry.width,
                    placement = awful.placement.center,
                    minimum_height = s.geometry.height,
                    maximum_height = s.geometry.height,
                    bg = gears.color.change_opacity(
                        table.get_dynamic(config.background),
                        config.opacity
                    ),
                    widget = {
                        { --> Use of generator avoided as individual button adjustments were needed (not really elegant)
                            sfx.on_hover(
                                {
                                    {
                                        {
                                            halign = "center",
                                            markup = text.bold(beautiful.icon.text.session.exit),
                                            font = beautiful.fonts.icon(config.buttons.font_size, "Solid"),
                                            widget = wibox.widget.textbox
                                        },
                                        left = dpi(5, s),
                                        widget = wibox.container.margin
                                    },
                                    shape = config.buttons.shape,
                                    forced_width = dpi(config.buttons.size, s),
                                    forced_height = dpi(config.buttons.size, s),
                                    border_width = dpi(config.buttons.thickness, s),
                                    fg = table.get_dynamic(config.buttons.color.foreground),
                                    bg = table.get_dynamic(config.buttons.color.background),
                                    border_color = table.get_dynamic(config.buttons.color.foreground),
                                    buttons = awful.button({
                                        modifiers = {},
                                        group = "session",
                                        description = "Exit Session",
                                        button = awful.button.names.LEFT,
                                        --> Close object on left click
                                        on_release = current.actions.session.exit
                                    }),
                                    widget = wibox.container.background
                                }, {cursor = beautiful.cursor.button, border_color = table.get_dynamic(config.buttons.color.accent), fg = table.get_dynamic(config.buttons.color.accent)}
                            ),
                            sfx.on_hover(
                                {
                                    {
                                        {
                                            halign = "center",
                                            markup = text.bold(beautiful.icon.text.session.lock),
                                            font = beautiful.fonts.icon(config.buttons.font_size - 5, "Solid"),
                                            widget = wibox.widget.textbox
                                        },
                                        right = dpi(2, s),
                                        widget = wibox.container.margin
                                    },
                                    shape = config.buttons.shape,
                                    forced_width = dpi(config.buttons.size, s),
                                    forced_height = dpi(config.buttons.size, s),
                                    border_width = dpi(config.buttons.thickness, s),
                                    fg = table.get_dynamic(config.buttons.color.foreground),
                                    bg = table.get_dynamic(config.buttons.color.background),
                                    border_color = table.get_dynamic(config.buttons.color.foreground),
                                    buttons = awful.button({
                                        modifiers = {},
                                        group = "session",
                                        description = "Lock Session",
                                        button = awful.button.names.LEFT,
                                        --> Close object on left click
                                        on_release = current.actions.session.lock
                                    }),
                                    widget = wibox.container.background
                                }, {cursor = beautiful.cursor.button, border_color = table.get_dynamic(config.buttons.color.accent), fg = table.get_dynamic(config.buttons.color.accent)}
                            ),
                            sfx.on_hover(
                                {
                                    {
                                        {
                                            halign = "center",
                                            markup = text.bold(beautiful.icon.text.session.sleep),
                                            font = beautiful.fonts.icon(config.buttons.font_size, "Solid"),
                                            widget = wibox.widget.textbox
                                        },
                                        right = dpi(2, s),
                                        widget = wibox.container.margin
                                    },
                                    shape = config.buttons.shape,
                                    forced_width = dpi(config.buttons.size, s),
                                    forced_height = dpi(config.buttons.size, s),
                                    border_width = dpi(config.buttons.thickness, s),
                                    fg = table.get_dynamic(config.buttons.color.foreground),
                                    bg = table.get_dynamic(config.buttons.color.background),
                                    border_color = table.get_dynamic(config.buttons.color.foreground),
                                    buttons = awful.button({
                                        modifiers = {},
                                        group = "session",
                                        description = "Sleep session",
                                        button = awful.button.names.LEFT,
                                        --> Close object on left click
                                        on_release = current.actions.session.sleep
                                    }),
                                    widget = wibox.container.background
                                }, {cursor = beautiful.cursor.button, border_color = table.get_dynamic(config.buttons.color.accent), fg = table.get_dynamic(config.buttons.color.accent)}
                            ),
                            sfx.on_hover(
                                {
                                    {
                                        {
                                            halign = "center",
                                            markup = text.bold(beautiful.icon.text.session.restart),
                                            font = beautiful.fonts.icon(config.buttons.font_size - 5, "Solid"),
                                            widget = wibox.widget.textbox
                                        },
                                        bottom = dpi(2, s),
                                        widget = wibox.container.margin
                                    },
                                    shape = config.buttons.shape,
                                    forced_width = dpi(config.buttons.size, s),
                                    forced_height = dpi(config.buttons.size, s),
                                    border_width = dpi(config.buttons.thickness, s),
                                    fg = table.get_dynamic(config.buttons.color.foreground),
                                    bg = table.get_dynamic(config.buttons.color.background),
                                    border_color = table.get_dynamic(config.buttons.color.foreground),
                                    buttons = awful.button({
                                        modifiers = {},
                                        group = "session",
                                        description = "Restart Session",
                                        button = awful.button.names.LEFT,
                                        --> Close object on left click
                                        on_release = current.actions.session.restart
                                    }),
                                    widget = wibox.container.background
                                }, {cursor = beautiful.cursor.button, border_color = table.get_dynamic(config.buttons.color.accent), fg = table.get_dynamic(config.buttons.color.accent)}
                            ),
                            sfx.on_hover(
                                {
                                    {
                                        {
                                            halign = "center",
                                            markup = text.bold(beautiful.icon.text.session.suspend),
                                            font = beautiful.fonts.icon(config.buttons.font_size + 2, "Solid"),
                                            widget = wibox.widget.textbox
                                        },
                                        right = dpi(2, s),
                                        widget = wibox.container.margin
                                    },
                                    shape = config.buttons.shape,
                                    forced_width = dpi(config.buttons.size, s),
                                    forced_height = dpi(config.buttons.size, s),
                                    border_width = dpi(config.buttons.thickness, s),
                                    fg = table.get_dynamic(config.buttons.color.foreground),
                                    bg = table.get_dynamic(config.buttons.color.background),
                                    border_color = table.get_dynamic(config.buttons.color.foreground),
                                    buttons = awful.button({
                                        modifiers = {},
                                        group = "session",
                                        description = "Suspend Session",
                                        button = awful.button.names.LEFT,
                                        --> Close object on left click
                                        on_release = current.actions.session.suspend
                                    }),
                                    widget = wibox.container.background
                                }, {cursor = beautiful.cursor.button, border_color = table.get_dynamic(config.buttons.color.accent), fg = table.get_dynamic(config.buttons.color.accent)}
                            ),
                            sfx.on_hover(
                                {
                                    {
                                        {
                                            halign = "center",
                                            markup = text.bold(beautiful.icon.text.session.shutdown),
                                            font = beautiful.fonts.icon(config.buttons.font_size + 5, "Round"),
                                            widget = wibox.widget.textbox
                                        },
                                        right = dpi(2, s),
                                        widget = wibox.container.margin
                                    },
                                    shape = config.buttons.shape,
                                    forced_width = dpi(config.buttons.size, s),
                                    forced_height = dpi(config.buttons.size, s),
                                    border_width = dpi(config.buttons.thickness, s),
                                    fg = table.get_dynamic(config.buttons.color.foreground),
                                    bg = table.get_dynamic(config.buttons.color.background),
                                    border_color = table.get_dynamic(config.buttons.color.foreground),
                                    buttons = awful.button({
                                        modifiers = {},
                                        group = "session",
                                        description = "Shutdown Session",
                                        button = awful.button.names.LEFT,
                                        --> Close object on left click
                                        on_release = current.actions.session.shutdown
                                    }),
                                    widget = wibox.container.background
                                }, {cursor = beautiful.cursor.button, border_color = table.get_dynamic(config.buttons.color.accent), fg = table.get_dynamic(config.buttons.color.accent)}
                            ),
                            sfx.on_hover(
                                {
                                    {
                                        {
                                            halign = "center",
                                            markup = text.bold(beautiful.icon.text.session.hibernate),
                                            font = beautiful.fonts.icon(config.buttons.font_size, "Solid"),
                                            widget = wibox.widget.textbox
                                        },
                                        right = dpi(2, s),
                                        widget = wibox.container.margin
                                    },
                                    shape = config.buttons.shape,
                                    forced_width = dpi(config.buttons.size, s),
                                    forced_height = dpi(config.buttons.size, s),
                                    border_width = dpi(config.buttons.thickness, s),
                                    fg = table.get_dynamic(config.buttons.color.foreground),
                                    bg = table.get_dynamic(config.buttons.color.background),
                                    border_color = table.get_dynamic(config.buttons.color.foreground),
                                    buttons = awful.button({
                                        modifiers = {},
                                        group = "session",
                                        button = awful.button.names.LEFT,
                                        description = "Hibernate Session",
                                        --> Close object on left click
                                        on_release = current.actions.session.hibernate
                                    }),
                                    widget = wibox.container.background
                                }, {cursor = beautiful.cursor.button, border_color = table.get_dynamic(config.buttons.color.accent), fg = table.get_dynamic(config.buttons.color.accent)}
                            ),
                            spacing = dpi(config.spacing, s),
                            layout = wibox.layout.fixed.horizontal
                        },
                        buttons = awful.button({
                            modifiers = {},
                            group = "session",
                            button = awful.button.names.LEFT,
                            description = "Close Session menu",
                            --> Close object on left click
                            on_release = current.actions.hide
                        }),
                        widget = wibox.container.place
                    }
                }), "main", s
            )
        end
    end
end
-- =========================================================>
--> Resets the session with (restart):
-- =========================================================>
function this:reset(restart)
    -->> Current screen-specific object reference
    local current = self.session
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.session = nil
        --> Loop trough all screnns
        for s in screen do
            --> Remove references to the object on awesome's end
            current.widget[s.index].main.visible = false
        end
        --> Restarts the widget if needed
        if (restart) then
           return self:init() --> Proper tail call
        end
    end
end
-- =========================================================>
return this
