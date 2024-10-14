-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          TAGLIST
-- =========================================================>
----> AwesomeWM Taskbar Taglist Widget
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
local this = {taglists = {}, signals = {}}
-- =========================================================>
--  [Functions] Taglist:
-- =========================================================>
--> Initializes the taglist for screen (s):
-- =========================================================>
function this:init(s)
    -->> Taglist guard
    if (not self.taglists[s.index]) then
        --> Current screen-specific object reference
        self.taglists[s.index] = {widget = {}, func = {}}
        local current = self.taglists[s.index]

        --> Code shortening declarations
        local config = beautiful.taglist
        local link_fn = function(func, key)
            return link.to(current.func, func, key) --> Proper tail call
        end
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        local taskbar_height = dpi(beautiful.taskbar.height, s)

        -->> Disabled guard
        if (not config.enabled) then
            self.taglists[s.index] = nil
            return nil
        end

        -->> Current object index constructor
        current.widget.index = function()
            -->> Index guard
            if (config.index.enabled) then
                -->> Signal single-time screen-specific guarded connection
                if (not self.signals[s.index]) then
                    -->> When a tag is selected or deselected update the widget
                    awful.tag.attached_connect_signal(
                        s, "property::selected",
                        function(tag)
                            if (self.taglists[s.index]) then --check for index
                                --> Set selected tag index if any
                                self.taglists[s.index].widget.index.markup = config.index.format(
                                    (tag.screen.selected_tag and
                                    tag.screen.selected_tag.index or
                                    config.index.default)
                                )
                            end
                        end
                    )
                    -->> Set guard to true
                    self.signals[s.index] = true
                end
                -->> Index widget
                return link_to(
                    {
                        halign = "center",
                        forced_width = taskbar_height,
                        forced_height = taskbar_height,
                        font = beautiful.fonts.main(config.index.size),
                        markup = config.index.format(
                            (s.selected_tag and
                            s.selected_tag.index or
                            config.index.default)
                        ),
                        widget = wibox.widget.textbox
                    }, "index"
                ) --> Proper tail call
            end
        end

        -->> Current object focused constructor
        current.widget.focused = function()
            -->> Focused guard
            if (config.focused.enabled) then
                -->> Focused signal updater on-focus
                client.connect_signal(
                    "focus",
                    link_fn(
                        function()
                            --> I really am paranoid
                            if (client.focus) then
                                --> As this signal was triggered client.focus must exist
                                current.widget.focused.image = client.focus.icon
                            end
                        end, "focus"
                    )
                )
                -->> Focused signal updater on-unfocus
                client.connect_signal(
                    "unfocus",
                    link_fn(
                        function()
                            if (not client.focus) then
                                current.widget.focused.image = beautiful.theme_assets.awesome_icon(
                                    (taskbar_height * 0.6),
                                    table.get_dynamic(config.focused.color),
                                    table.get_dynamic(beautiful.color.dynamic.background)
                                )
                            end
                        end, "unfocus"
                    )
                )
                -->> Focused widget
                return link_to(
                    {
                        auto_dpi = true,
                        halign = "center",
                        scaling_quality = "best",
                        clip_shape = gears.shape.circle,
                        forced_width = (taskbar_height * 0.6),
                        forced_height = (taskbar_height * 0.6),
                        --> Always check if client.focus exists as this can be run in a restart
                        image = (client.focus and client.focus.icon) or beautiful.theme_assets.awesome_icon(
                            (taskbar_height * 0.6),
                            table.get_dynamic(config.focused.color),
                            table.get_dynamic(beautiful.color.dynamic.background)
                        ),
                        widget = wibox.widget.imagebox
                    }, "focused"
                ) --> Proper tail call
            end
        end

        -->> Current object widget
        return link_to(
            {
                {
                    {
                        {
                            --> Constructs one of both widgets
                            mysc.choose(
                                config.swap_sides,
                                current.widget.index,
                                current.widget.focused
                            ),
                            right = (config.swap_sides and 0 or dpi(12, s)),
                            widget = wibox.container.margin
                        },
                        widget = wibox.container.place
                    },
                    sfx.on_hover(
                        {
                            {
                                awful.widget.taglist({
                                    screen = s,
                                    filter = config.filter,
                                    layout = wibox.layout.fixed.horizontal,
                                    source = awful.widget.taglist.source.for_screen,
                                    widget_template = {
                                        forced_width = (taskbar_height - dpi(5, s)),
                                        forced_height = (taskbar_height - dpi(5, s)),
                                        -->> Widget (self) on-creation callback
                                        create_callback = function(self, tag)
                                            -->> Connect shadow's events
                                            event.connect(
                                                event.connect(
                                                    self,
                                                    function() return signal.shadow.hide() end, "mouse::leave"
                                                ), function() return signal.shadow.show(tag) end, "mouse::enter"
                                            )

                                            -->> Current object animation
                                            self.animation = rubato.timed({
                                                rate = beautiful.animation.fps,
                                                pos = dpi(config.tag.height, s),
                                                easing = beautiful.animation.widget.taglist.easing,
                                                duration = beautiful.animation.widget.taglist.duration,
                                                subscribed = function(pos)
                                                    self.widget.forced_width = pos
                                                end
                                            })

                                            -->> Current object widget
                                            self.widget = {
                                                shape = config.tag.shape,
                                                forced_height = dpi(config.tag.height, s),
                                                widget = wibox.container.background
                                            }

                                            -->> Initialize current object using its context
                                            return self:update_callback(tag) --> Proper tail call
                                        end,
                                        -->> Widget (self) on-update callback
                                        update_callback = function(self, tag)
                                            --current.shadows

                                            -->> Returns tag state
                                            local state = function()
                                                --> Loop trough all tag clients
                                                for _,client in next, tag:clients() do
                                                    --> Check if tag has urgent clients
                                                    if (client.urgent) then
                                                        return "urgent"
                                                    end
                                                end
                                                --> If tag is not urgent check other states
                                                return (tag.volatile and "volatile" or "normal")
                                            end
                                            -->> Manage status-corresponding styling
                                            if (tag.selected) then
                                                --> Selected tags ratio is 5:2
                                                self.animation.target = (dpi(config.tag.height, s) * 2.5)
                                                self.widget.bg = table.get_dynamic(
                                                    config.tag.color[state()]
                                                )
                                            elseif (#(tag:clients()) == 0) then
                                                --> Unselected empty tags ratio is 1:1
                                                self.animation.target = dpi(config.tag.height, s)
                                                --> Empty tags cannot be volatile nor urgent
                                                self.widget.bg = table.get_dynamic(
                                                    config.tag.color["empty"]
                                                )
                                            else
                                                --> Unselected non-empty tags ratio is 7:4
                                                self.animation.target = (dpi(config.tag.height, s) * 1.75)
                                                self.widget.bg = table.get_dynamic(
                                                    config.tag.color[state()]
                                                )
                                            end
                                        end,
                                        widget = wibox.container.place
                                    },
                                    --[[
                                    buttons = {
                                        awful.button({
                                            modifiers = {},
                                            button = awful.button.names.LEFT,
                                            on_release = function(tag)
                                                return tag:view_only() --> Proper tail call
                                            end
                                        }),
                                         awful.button({
                                            modifiers = {},
                                            button = awful.button.names.MIDDLE,
                                            on_release = function(tag)
                                                awful.tag.add("Volatile", )
                                            end
                                        }),
                                        awful.button({
                                            modifiers = {"Mod4"}, --> Windows key
                                            button = awful.button.names.MIDDLE,
                                            on_release = function()
                                                if tag.volatile then
                                                    return tag:delete() --> Proper tail call
                                                end
                                                return tag:clear() --> Proper tail call
                                            end
                                        })
                                        awful.button({
                                            modifiers = {},
                                            button = awful.button.names.RIGHT,
                                            on_release = awful.tag.viewtoggle
                                        })

                                    }]]
                                    buttons = {
                                        awful.button({}, 1, nil, function(t) t:view_only() end),
                                        awful.button({"Mod4"}, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
                                        awful.button({}, 3, nil, function(t) awful.tag.viewtoggle(t) end),
                                        awful.button({"Mod4"}, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
                                        awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
                                        awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
                                    }
                                }),
                                margins = mysc.margins(0, 6, s),
                                widget = wibox.container.margin
                            },
                            shape = config.shape,
                            bg = table.get_dynamic(config.color),
                            widget = wibox.container.background
                        }, {cursor = beautiful.cursor.button, opacity = 0.8}
                    ),
                    {
                        {
                            --> Constructs one of both widgets
                            mysc.choose(
                                config.swap_sides,
                                current.widget.focused,
                                current.widget.index
                            ),
                            left = (config.swap_sides and dpi(12, s) or 0),
                            widget = wibox.container.margin
                        },
                        widget = wibox.container.place
                    },
                    layout = wibox.layout.fixed.horizontal
                },
                margins = mysc.margins(5, 10, s),
                widget = wibox.container.margin
            }, "main"
        ) --> Proper tail call
    end
    -->> Always return what must be returned
    return self.taglists[s.index].widget.main
end
-- =========================================================>
--> Resets the taglist for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.taglists[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.taglists[s.index] = nil
        --> Remove client focus widget signal
        if (current.func.focus) then
            client.disconnect_signal("focus", current.func.focus)
        end
        --> Remove client unfocus widget signal
        if (current.func.unfocus) then
            client.disconnect_signal("unfocus", current.func.unfocus)
        end
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
