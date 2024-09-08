-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          SHADOW
-- =========================================================>
----> AwesomeWM Shadow Popup Widget


--> set border color correctly for clients
--> fails to set in preview location of sticky clients when in another tag
--> Paint a taskbar

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
local text = require("util.text")
local color = require("util.color")
local event = require("util.event")
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local cairo = require("lgi").cairo
local rubato = require("lib.rubato")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local floor = math.floor
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {shadows = {}}
-- =========================================================>
--  [Functions] Shadow:
-- =========================================================>
--> Initializes the shadow for screen (s):
-- =========================================================>
function this:init(s)
    -->> Shadow guard
    if (not self.shadows[s.index]) then
        -->> Current screen-specific object reference
        self.shadows[s.index] = {widget = {}}
        local current = self.shadows[s.index]

        -->> Code shortening declarations
        local config = beautiful.shadow(s)
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        local scale = function(n)
            return floor(
                dpi(n * config.preview.scale, s)
            ) --> Proper tail call
        end

        -->> Current object state
        current.state = ((config.state == nil) and config.glimpse or config.state)

        -->> Current object actions
        current.actions = {
            -->> Open the object throught its animation
            open = function(tag)
                current.state = true
                current.actions.update(tag)
                current.widget.main.visible = true
                if (current.animations) then
                    current.animations.opacity.target = config.opacity
                else
                    --> Change the bg's opacity instead of widgets opacity
                    --> as the latter does not have any effect on the widget
                    current.widget.main.bg = gears.color.change_opacity(
                        table.get_dynamic(config.title.color),
                        config.opacity
                    )
                    current.widget.margin.opacity = 1
                end
                if (current.timer) then
                    return current.timer:stop() --> Proper tail call
                end
            end,
            -->> Close the object throught its animation
            close = function()
                current.state = false
                if (current.timer) then
                    return current.timer:again() --> Proper tail call
                else
                    current.widget.main.visible = false
                end
            end,
            -->> Make image preview for tag (tag)
            image = function(tag)
                -->> Tag's clients map image
                local image = wibox.widget({
                    forced_width = scale(tag.screen.workarea.width),
                    forced_height = scale(tag.screen.workarea.height),
                    layout = wibox.layout.manual
                })
                -->> Code shortening declaration
                local config = config.preview
                -->> Declare variable outside the loop
                local content = nil
                -->> Loop trough all of tag's clients
                for _,c in next, tag:clients() do
                    --> If the client is visible on the tag and content must be shown
                    if (config.show_content and not (c.minimized or c.hidden)) then
                        --> If tag is selected or client has previous content
                        if (tag.selected) then
                            --> Get the content for the current client
                            content = gears.surface(c.content) --> Current content

                            --> Gets the painting context of the content
                            local context = cairo.Context(content)
                            --> Gets the bounds of the content from its context
                            local bounds = {context:clip_extents()}
                            --> Creates a new surface with appropiate bounds
                            local surface = cairo.ImageSurface.create(
                                cairo.Format.ARGB32,
                                bounds[3] - bounds[1],
                                bounds[4] - bounds[2]
                            )
                            --> Gets the painting context of the surface
                            context = cairo.Context(surface)
                            --> Sets the source of the paint from the content
                            context:set_source_surface(content, 0, 0)
                            --> Paints covering what it has below
                            context.operator = cairo.Operator.SOURCE
                            --> Performs the painting operation
                            context:paint()

                            --> Loads the surface to content
                            content = gears.surface(surface)
                            --> Save current content as last known content
                            c.content_cache = content
                        else
                            content = c.content_cache --> Last known content
                        end
                    else
                        content = c.icon --> Use client icon instead
                    end

                    --> Add client to the preview at scaled coordinates
                    image:add_at(
                        wibox.widget(
                            { --> Widget
                                {
                                    {
                                        --> Client icons shall not be resized
                                        resize = (content ~= c.icon),
                                        opacity = config.client.opacity,
                                        image = content or beautiful.theme_assets.awesome_icon(
                                            dpi(config.icon.size, s),
                                            table.get_dynamic(config.icon.color.main),
                                            table.get_dynamic(beautiful.color.dynamic.background)
                                        ), --> Fallback
                                        widget = wibox.widget.imagebox
                                    },
                                    widget = wibox.container.place
                                },
                                forced_width = scale(c.width),
                                forced_height = scale(c.height),
                                shape_border_width = config.client.thickness,
                                bg = table.get_dynamic(config.client.color.background),
                                shape = mysc.shape("rounded_rect", config.client.radius, s),
                                shape_border_color = table.get_dynamic(config.client.color.border),
                                widget = wibox.container.background
                            }
                        ),
                        { --> Coordinates
                            x = scale(c.x - tag.screen.workarea.x),
                            y = scale(c.y - tag.screen.workarea.y)
                        }
                    )
                end
                -->> Return the image
                return image
            end,
            -->> Update the object for tag (tag)
            update = function(tag)
                --> Update the title for tag
                current.widget.title.markup = " " .. config.title.format(tag.name) .. " (" .. tag.gap .. ")"

                --> Update the preview for tag
                current.widget.preview_bg.image = signal.wallpaper.get(s)
                current.widget.preview_box.widget = current.actions.image(tag)

                --> Update the icon for tag
                current.widget.icon.image = tag.icon and color.image(
                    tag.icon,
                    table.get_dynamic(config.icon.color.main)
                ) or beautiful.theme_assets.awesome_icon(
                    dpi(config.icon.size, s),
                    table.get_dynamic(config.icon.color.main),
                    table.get_dynamic(beautiful.color(s).dynamic.background)
                )

                --> Update the layout for tag
                current.widget.layout.image = beautiful["layout_" .. awful.layout.getname(tag.layout)] and
                color.image(
                    beautiful["layout_" .. awful.layout.getname(tag.layout)], --WIP
                    table.get_dynamic(config.icon.color.sub)
                ) or beautiful.theme_assets.awesome_icon(
                    dpi(config.icon.size, s) * 0.5,
                    table.get_dynamic(config.icon.color.sub),
                    table.get_dynamic(beautiful.color(s).dynamic.background)
                ) --WIP

                --> Set tag as current tag
                current.tag = tag
            end
        }

        -->> Animation guard
        if (beautiful.animation.widget.enabled) then
            -->> Current object animations
            current.animations = {
                -->> Object opacity in-and-out animation
                opacity = rubato.timed({
                    rate = beautiful.animation.fps,
                    --> Opacity must be jumpstarted
                    --> according to current object state
                    pos = (current.state and config.opacity or 0),
                    easing = beautiful.animation.widget.shadow.easing,
                    duration = beautiful.animation.widget.shadow.duration,
                    subscribed = function(pos)
                        --> Change the bg's opacity instead of widgets opacity
                        --> as the latter does not have any effect on the widget
                        current.widget.main.bg = gears.color.change_opacity(
                            table.get_dynamic(config.title.color),
                            pos
                        )
                        --> Object child widget opacity must also be animated
                        --> in order to also affect all the object's children
                        --> This division always ensures opacity will reach 1
                        current.widget.margin.opacity = (pos / config.opacity)
                    end,
                    end_callback = function(pos)
                        --> On 'out' completion make the widget not visible
                        if (pos == 0) then
                            current.widget.main.visible = false
                        end
                    end
                })
            }
        end

        -->> Timer guard
        if (config.timeout and (config.timeout ~= 0)) then
            -->> Current object timer
            current.timer = gears.timer({
                call_now = false,
                single_shot = true,
                timeout = config.timeout,
                autostart = ((config.timer == nil) and config.glimpse or config.timer),
                -->> Timer on-timeout callback
                callback = function()
                    if (current.animations) then
                        current.animations.opacity.target = 0
                    else
                        current.widget.main.visible = false
                    end
                end
            })
        end

        -->> Current object widget
        return link_to(
            event.connect(
                event.connect(
                    awful.popup({
                        screen = s,
                        ontop = true,
                        type = "popup_menu",
                        cursor = config.cursor,
                        visible = current.state,
                        --> Needed as popup.opacity does not
                        --> seem to have any effect on the bg
                        bg = gears.color.change_opacity(
                            table.get_dynamic(config.title.color),
                            --> Opacity must be jumpstarted
                            --> according to visibility state
                            (current.state and config.opacity or 0)
                        ),
                        shape = mysc.shape("rounded_rect", config.radius, s),
                        placement = mysc.placement("bottom_right", {
                            margins = {
                                right = dpi(config.spacing, s),
                                bottom = dpi(config.spacing + beautiful.taskbar(s).height, s)
                            }
                        }),
                        widget = link_to(
                            {
                                {
                                    {
                                        {
                                            {
                                                markup = config.title.prefix,
                                                font = beautiful.fonts.main(config.title.size),
                                                widget = wibox.widget.textbox
                                            },
                                            link_to(
                                                {
                                                    font = beautiful.fonts.main(config.title.size),
                                                    widget = wibox.widget.textbox
                                                }, "title"
                                            ),
                                            layout = wibox.layout.fixed.horizontal
                                        },
                                        margins = mysc.margins(10, 25, s),
                                        widget = wibox.container.margin
                                    },
                                    {
                                        {
                                            {
                                                link_to(
                                                    {
                                                        auto_dpi = true,
                                                        halign = "center",
                                                        scaling_quality = "best",
                                                        forced_width = scale(s.geometry.width),
                                                        forced_height = scale(s.geometry.height),
                                                        --> If there are no margins then the shape is better of as a rectangle
                                                        clip_shape = (config.margins and (config.margins ~= 0)) and
                                                            mysc.shape("rounded_rect", config.radius, s),
                                                        widget = wibox.widget.imagebox
                                                    }, "preview_bg"
                                                ),
                                                link_to(
                                                    {
                                                        --> Pushes inwards the actual workarea client preview into place
                                                        margins = {
                                                            --> Push from the top until where the workarea starts
                                                            top = scale(s.workarea.y),
                                                            --> Push from the right the remaing distance from the workarea's end to the end of the screen
                                                            right = scale(s.geometry.width - (s.workarea.x + s.workarea.width)),
                                                            --> Push from the bottom the remaing distance from the workarea's end to the end of the screen
                                                            bottom = scale(s.geometry.height - (s.workarea.y + s.workarea.height)),
                                                            --> Push from the left until where the workarea starts
                                                            left = scale(s.workarea.x)
                                                        },
                                                        widget = wibox.container.margin
                                                    }, "preview_box"
                                                ),
                                                layout = wibox.layout.stack
                                            },
                                            strategy = "exact",
                                            width = scale(s.geometry.width),
                                            height = scale(s.geometry.height),
                                            widget = wibox.container.constraint
                                        },
                                        {
                                            nil, nil,
                                            {
                                                nil, nil,
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
                                                                            widget = wibox.widget.imagebox
                                                                        }, "icon"
                                                                    ),
                                                                    margins = dpi(config.icon.size * 0.1, s),
                                                                    widget = wibox.container.margin
                                                                },
                                                                shape = config.icon.shape,
                                                                bg = beautiful.color(s).static.widget,
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
                                                                        link_to(
                                                                            {
                                                                                auto_dpi = true,
                                                                                halign = "center",
                                                                                scaling_quality = "best",
                                                                                forced_width = dpi(config.icon.size * 0.5, s),
                                                                                forced_height = dpi(config.icon.size * 0.5, s),
                                                                                widget = wibox.widget.imagebox
                                                                            }, "layout"
                                                                        ),
                                                                        margins = dpi(config.icon.size * 0.1, s),
                                                                        widget = wibox.container.margin
                                                                    },
                                                                    shape = config.icon.shape,
                                                                    bg = beautiful.color(s).static.widget,
                                                                    forced_width = dpi(config.icon.size * 0.5, s),
                                                                    forced_height = dpi(config.icon.size * 0.5, s),
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
                                                    margins = {
                                                        right = (scale(s.geometry.height)/15),
                                                        bottom = (scale(s.geometry.height)/15)
                                                    },
                                                    widget = wibox.container.margin
                                                },
                                                expand = "none",
                                                layout = wibox.layout.align.horizontal
                                            },
                                            expand = "none",
                                            layout = wibox.layout.align.vertical
                                        },
                                        layout = wibox.layout.stack
                                    },
                                    layout = wibox.layout.fixed.vertical
                                },
                                margins = config.margins,
                                --> Opacity must be jumpstarted
                                --> according to current object state
                                opacity = (current.state and 1 or 0),
                                widget = wibox.container.margin
                            }, "margin"
                        )
                    }), function() return current.timer:start() end, "mouse::leave", (not current.timer)
                ), function() return current.timer:stop() end, "mouse::enter", (not current.timer)
            ), "main"
        ) --> Proper tail call
    end
end
-- =========================================================>
--> Resets the shadow for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.shadows[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.shadows[s.index] = nil
        --> Restarts the widget if needed
        if (restart) then
            --> Current screen-specific configuration
            local config = beautiful.shadow(s)
            --> Ensure the object's state
            --> remains the same trough restarts
            config.state = current.state
            --> Ensure the object's timer
            --> remains the same trough restarts
            config.timer = current.timer and current.timer.started
            --> Initialize the new object
            self:init(s)
            --> If a tag was being shown ensure it is shown again
            if (current.tag) then
                self.shadows[s.index].actions.update(current.tag)
            end
        end
        --> Stop the timer if needed and allow it to be garbage-collected
        if (current.timer) then current.timer:stop() end
        --> Remove references to the object on awesome's end
        current.widget.main.visible = false
    end
end
-- =========================================================>
return this
