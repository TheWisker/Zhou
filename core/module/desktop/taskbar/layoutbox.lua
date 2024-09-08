-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                         LAYOUTBOX
-- =========================================================>
----> AwesomeWM Taskbar Layoutbox Widget
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
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local rubato = require("lib.rubato")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {layoutboxs = {}, signals = {}}
-- =========================================================>
--  [Functions] Layoutbox:
-- =========================================================>
---> Initializes the layoutbox for screen (s):
-- =========================================================>
function this:init(s)
    -->> Layoutbox guard
    if (not self.layoutboxs[s.index]) then
        -->> Current screen-specific object reference
        self.layoutboxs[s.index] = {widget = {}}
        local current = self.layoutboxs[s.index]

        -->> Code shortening declarations
        local config = beautiful.layoutbox(s)
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        local taskbar_height = dpi(beautiful.taskbar(s).height, s)

        -->> Current object layouts
        current.layout = (config.layout or awful.layout.get(s))
        current.last = config.last

        -->> Current object actions
        current.actions = {
            -->> Switch to the next layout
            next = function()
                awful.layout.inc(1, s)
                return current.actions.update() --> Proper tail call
            end,
            -->> Toggle favourite layout in and out
            favourite = function()
                --> Capture value as the signal
                --> derived fom the change of layout
                --> triggers current.actions.update and
                --> changes the value of current.layout
                local last = current.layout
                --> Set layout depending on state
                awful.layout.set(
                    ((config.favourite ~= current.layout) and
                    config.favourite or
                    current.last),
                    s.selected_tag
                )
                --> Save last layout
                current.last = last
                return current.actions.update() --> Proper tail call
            end,
            -->> Switch to the previous layout
            prev = function()
                awful.layout.inc(-1, s)
                return current.actions.update() --> Proper tail call
            end,
            -->> Retrieve the name or icon of the specified or current layout
            layout = function(type, layout)
                local name = awful.layout.getname(
                    (layout or awful.layout.get(s)) --> Gets layout for screen
                ) --> Gets name for layout
                if type == "icon" then
                    --> Return icon
                    return color.image(
                        beautiful.icon.image.layout[name],
                        table.get_dynamic(config.color.icon)
                    ) --> Proper tail call
                elseif type == "text" then
                    --> Return formatted text
                    return config.tooltip.format(
                        (beautiful.layout.name[name] or name)
                    ) --> Proper tail call
                end
                --> Return the name
                return name
            end,
            -->> Update the object for current layout
            update = function()
                local layout = awful.layout.get(s)
                --> If the layout did not change do not bother updating
                if (current.layout ~= layout) then
                    current.widget.layout.image = current.actions.layout("icon", layout)
                    current.widget.tooltip.markup = current.actions.layout("text", layout)
                    current.widget.tooltip.visible = true
                    current.layout = layout
                    return current.timer:again() --> Proper tail call
                end
            end
        }

        -->> Signal single-time screen-specific guarded connection
        if (not self.signals[s.index]) then
            -->> Dynamic tag update function
            local update = function()
                -->> Current screen-specific object reference
                local current = self.layoutboxs[s.index]
                -->> If there is an object then update it
                if (current) then
                    return current.actions.update() --> Proper tail call
                end
            end
            -->> When a tag is selected or deselected update the widget
            awful.tag.attached_connect_signal(s, "property::selected", update)
            -->> When a tag's layout changes update the widget
            awful.tag.attached_connect_signal(s, "property::layout", update)
            -->> When a tag changes screens update the widget
            awful.tag.attached_connect_signal(
                s, "property::screen",
                function()
                    --> If screen changed update all layoutboxes
                    for layoutbox in next, self.layoutboxs do
                        layoutbox.actions.update()
                    end
                end
            )
            -->> Set guard to true
            self.signals[s.index] = true
        end

         -->> Current object timer
        current.timer = gears.timer({
            call_now = false,
            autostart = false,
            single_shot = true,
            timeout = config.tooltip.timeout,
            -->> Timer on-timeout callback
            callback = function()
                current.widget.tooltip.visible = false
            end
        })

        -->> Current object widget
        return sfx.on_hover(
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
                            --> Layout must be jumpstarted to current one
                            markup = current.actions.layout("text"),
                            --> Needed as tooltip.opacity does not
                            --> seem to have any effect on the bg
                            bg = gears.color.change_opacity(
                                table.get_dynamic(config.color.bg),
                                config.tooltip.opacity
                            ),
                            fg = table.get_dynamic(config.color.fg),
                            margins = mysc.dpi(config.tooltip.margins, s),
                            preferred_alignments = {"middle", "back", "front"},
                            font = beautiful.fonts.main(config.tooltip.font_size)
                        }), "tooltip"
                    ), link_to(
                        {
                            {
                                link_to(
                                    {
                                        auto_dpi = true,
                                        halign = "center",
                                        scaling_quality = "best",
                                        forced_width = taskbar_height,
                                        forced_height = taskbar_height,
                                        --> Layout must be jumpstarted to current one
                                        image = current.actions.layout("icon"),
                                        widget = wibox.widget.imagebox
                                    }, "layout"
                                ),
                                margins = mysc.dpi(config.margins, s),
                                widget = wibox.container.margin
                            },
                            bg = "#00000000",
                            shape = mysc.shape("rounded_rect", (taskbar_height/2), s),
                            buttons = {
                                awful.button({
                                    modifiers = {},
                                    group = "layoutbox",
                                    button = awful.button.names.RIGHT,
                                    description = "Switch to the next layout",
                                    on_release = current.actions.next
                                }),
                                awful.button({
                                    modifiers = {},
                                    group = "layoutbox",
                                    button = awful.button.names.SCROLL_UP,
                                    description = "Switch to the next layout",
                                    on_release = current.actions.next
                                }),
                                awful.button({
                                    modifiers = {},
                                    group = "layoutbox",
                                    button = awful.button.names.MIDDLE,
                                    description = "Toggle favourite layout",
                                    on_release = current.actions.favourite
                                }),
                                awful.button({
                                    modifiers = {},
                                    group = "layoutbox",
                                    button = awful.button.names.LEFT,
                                    description = "Switch to the previous layout",
                                    on_release = current.actions.prev
                                }),
                                awful.button({
                                    modifiers = {},
                                    group = "layoutbox",
                                    button = awful.button.names.SCROLL_DOWN,
                                    description = "Switch to the previous layout",
                                    on_release = current.actions.prev
                                })
                            },
                            widget = wibox.container.background
                        }, "main"
                    )
                ), {bg = beautiful.color(s).static.click}
            ), {cursor = beautiful.cursor.button, bg = beautiful.color(s).static.hover}
        )
    end
    -->> Always return what must be returned
    return self.layoutboxs[s.index].widget.main
end
-- =========================================================>
--> Resets the layoutbox for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference and signals
    local current = self.layoutboxs[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.layoutboxs[s.index] = nil
        --> Restarts the widget if needed
        if (restart) then
            --> Current screen-specific configuration
            local config = beautiful.layoutbox(s)
            --> Ensure the object's state
            --> remains the same trough restarts
            config.state = current.widget.tooltip.visible
            --> Ensure the object's layouts
            --> remain the same trough restarts
            config.layout = current.layout
            config.last = current.last
            --> Initialize the new object
            self:init(s)
        end
        --> Stop the tooltip timer if needed and
        --> allow it to be garbage-collected
        if (current.timer) then
            current.timer:stop()
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
