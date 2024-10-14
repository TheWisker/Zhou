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
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local floor = math.floor
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {shadow = nil}
-- =========================================================>
--  [Functions] Shadow:
-- =========================================================>
--> Initializes the shadow for desktop:
-- =========================================================>
function this:init()
    -->> Shadow guard
    if (not self.shadow) then
        -->> Current object reference
        self.shadow = {widget = {}}
        local current = self.shadow

        -->> Code shortening declarations
        local config = beautiful.shadow
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        local scale = function(n, s)
            return floor(
                dpi(n * config.preview.scale, s)
            ) --> Proper tail call
        end

        -->> Current object actions
        current.actions = {
            -->> Show the object
            show = function(tag)
                --> Update and then show shadow
                current.actions.update(tag)
                current.widget.main.visible = true
                --> Stop timer if it exists
                if (current.timer) then
                    return current.timer:stop() --> Proper tail call
                end
            end,
            -->> Hide the object
            hide = function()
                --> Use timer if it exists
                if (current.timer) then
                    return current.timer:again() --> Proper tail call
                else
                    --> Delete current tag
                    current.tag = nil
                    current.widget.main.visible = false
                end
            end,
            -->> Make image preview for tag (tag)
            preview = function(tag)
                -->> Code shortening declarations
                local s = tag.screen
                -->> Tag's clients map preview
                local preview = wibox.widget({
                    forced_width = scale(tag.screen.workarea.width, s),
                    forced_height = scale(tag.screen.workarea.height, s),
                    layout = wibox.layout.manual
                })
                -->> Declare variables outside the loop
                local content, context, bounds, surface = nil, nil, nil, nil
                -->> Loop trough all of tag's clients
                for _,c in next, tag:clients() do
                    --> If the client is visible on the tag and content must be shown
                    if (config.preview.show_content and (not (c.minimized or c.hidden))) then
                        --> If tag is selected or client has previous content
                        if (tag.selected) then
                            --> Get the content for the current client
                            content = gears.surface(c.content) --> Current content
                            --> Gets the painting context of the content
                            context = cairo.Context(content)
                            --> Gets the bounds of the content from its context
                            bounds = {context:clip_extents()}
                            --> Creates a new surface with appropiate bounds
                            surface = cairo.ImageSurface.create(
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
                    preview:add_at(
                        wibox.widget(
                            { --> Widget
                                {
                                    {
                                        --> Client icons shall not be resized
                                        resize = (content ~= c.icon),
                                        opacity = config.preview.client.opacity,
                                        image = content or beautiful.theme_assets.awesome_icon(
                                            dpi(config.icon.size),
                                            table.get_dynamic(config.icon.color.main),
                                            table.get_dynamic(beautiful.color.dynamic.background)
                                        ), --> Fallback
                                        widget = wibox.widget.imagebox
                                    },
                                    widget = wibox.container.place
                                },
                                forced_width = scale(c.width),
                                forced_height = scale(c.height),
                                shape_border_width = config.preview.client.thickness,
                                bg = gears.color.change_opacity(
                                    table.get_dynamic(config.preview.client.color.background),
                                    config.preview.client.opacity
                                ),
                                shape = mysc.shape("rounded_rect", config.preview.client.radius),
                                shape_border_color = table.get_dynamic(config.preview.client.color.border),
                                widget = wibox.container.background
                            }
                        ),
                        { --> Coordinates
                            x = scale(c.x - tag.screen.workarea.x, s),
                            y = scale(c.y - tag.screen.workarea.y, s)
                        }
                    )
                end
                -->> Return the preview
                return preview
            end,
            -->> Update the object for tag (tag)
            update = function(tag)
                -->> Code shortening declaration
                local s = tag.screen

                local image = function(img, c)
                    return img and color.image(img, table.get_dynamic(c)) or
                    beautiful.theme_assets.awesome_icon(
                        dpi(config.icon.size),
                        table.get_dynamic(c),
                        table.get_dynamic(beautiful.color.dynamic.background)
                    )
                end
                -->> Main widget properties
                current.widget.main.screen = s
                current.widget.main.placement = mysc.placement(
                    "bottom_right",
                    {
                        margins = {
                            right = dpi(config.spacing, s),
                            bottom = dpi(config.spacing + beautiful.taskbar.height, s)
                        }
                    }
                )
                -->> Title widget properties
                current.widget.title.markup = text.color(
                    config.title.format(tag.name) .. " (" .. tag.gap .. ")",
                    config.title.color
                )
                -->> Preview widget properties
                current.widget.preview_bg.image = signal.wallpaper.get()
                current.widget.preview_bg.forced_width = scale(s.geometry.width, s)
                current.widget.preview_bg.forced_height = scale(s.geometry.height, s)
                current.widget.preview_box.widget = current.actions.preview(tag)
                --> Pushes inwards the actual workarea client preview into place
                current.widget.preview_box.margins = {
                    --> Push from the top until where the workarea starts
                    top = scale(s.workarea.y, s),
                    --> Push from the right the remaing distance from the workarea's end to the end of the screen
                    right = scale(s.geometry.width - (s.workarea.x + s.workarea.width), s),
                    --> Push from the bottom the remaing distance from the workarea's end to the end of the screen
                    bottom = scale(s.geometry.height - (s.workarea.y + s.workarea.height), s),
                    --> Push from the left until where the workarea starts
                    left = scale(s.workarea.x, s)
                }
                current.widget.preview_constraint.width = scale(s.geometry.width, s)
                current.widget.preview_constraint.height = scale(s.geometry.height, s)
                -->> Icon widget properties
                current.widget.icon.image = image(tag.icon, config.icon.color.main)
                -->> Layout widget properties
                current.widget.layout.image = image(beautiful.icon.image.layout[awful.layout.getname(tag.layout)], config.icon.color.sub)
                -->> Set tag as current tag
                current.tag = tag
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
                -->> Timer on-timeout callback
                callback = function()
                    --> Delete current tag
                    current.tag = nil
                    current.widget.main.visible = false
                end
            })
        end

        -->> Glimpse startup action
        if (config.glimpse) then
            -->> Delay glimpse action to allow loading theme completely
            gears.timer({
                timeout = 2,
                call_now = false,
                autostart = true,
                single_shot = true,
                -->> Timer on-timeout callback
                callback = function()
                    --> Timer should exist for achieving glimpse effect
                    current.actions.show(awful.screen.focused().selected_tag)
                    return current.actions.hide() --> Proper tail call
                end
            })
            -->> Only once per session
            config.glimpse = false
        end

        -->> Current object widget
        return link_to(
            event.connect(
                event.connect(
                    awful.popup({
                        ontop = true,
                        type = "popup_menu",
                        cursor = config.cursor,
                        visible = config.state or false,
                        --> Needed as popup.opacity does not
                        --> seem to have any effect on the bg
                        bg = gears.color.change_opacity(
                            table.get_dynamic(config.background),
                            config.opacity
                        ),
                        placement = awful.placement.bottom_right,
                        shape = mysc.shape("rounded_rect", config.radius),
                        widget = {
                            {
                                link_to(
                                    {
                                        font = beautiful.fonts.main(config.title.font_size),
                                        widget = wibox.widget.textbox
                                    }, "title"
                                ),
                                margins = mysc.margins(10, 15),
                                widget = wibox.container.margin
                            },
                            {
                                link_to(
                                    {
                                        {
                                            link_to(
                                                {
                                                    auto_dpi = true,
                                                    halign = "center",
                                                    scaling_quality = "best",
                                                    --> If there are no margins then the shape is better of as a rectangle
                                                    clip_shape = (config.preview.margins and (config.preview.margins ~= 0)) and
                                                        mysc.shape("rounded_rect", config.radius),
                                                    widget = wibox.widget.imagebox
                                                }, "preview_bg"
                                            ),
                                            link_to(
                                                {
                                                    widget = wibox.container.margin
                                                }, "preview_box"
                                            ),
                                            layout = wibox.layout.stack
                                        },
                                        strategy = "exact",
                                        widget = wibox.container.constraint
                                    }, "preview_constraint"
                                ),
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
                                                                    clip_shape = config.icon.shape,
                                                                    forced_width = dpi(config.icon.size),
                                                                    forced_height = dpi(config.icon.size),
                                                                    widget = wibox.widget.imagebox
                                                                }, "icon"
                                                            ),
                                                            margins = dpi(config.icon.size * 0.1),
                                                            widget = wibox.container.margin
                                                        },
                                                        shape = config.icon.shape,
                                                        bg = beautiful.color.static.widget,
                                                        widget = wibox.container.background
                                                    },
                                                    strategy = "exact",
                                                    width = dpi(config.icon.size),
                                                    height = dpi(config.icon.size),
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
                                                                        clip_shape = config.icon.shape,
                                                                        forced_width = dpi(config.icon.size * 0.5),
                                                                        forced_height = dpi(config.icon.size * 0.5),
                                                                        widget = wibox.widget.imagebox
                                                                    }, "layout"
                                                                ),
                                                                margins = dpi(config.icon.size * 0.1),
                                                                widget = wibox.container.margin
                                                            },
                                                            shape = config.icon.shape,
                                                            bg = beautiful.color.static.widget,
                                                            forced_width = dpi(config.icon.size * 0.5),
                                                            forced_height = dpi(config.icon.size * 0.5),
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
                                                right = dpi(config.icon.size/2),
                                                bottom = dpi(config.icon.size/2)
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
                        }
                    }), function() return current.timer:start() end, "mouse::leave", (not current.timer)
                ), function() return current.timer:stop() end, "mouse::enter", (not current.timer)
            ), "main"
        ) --> Proper tail call
    end
end
-- =========================================================>
--> Resets the shadow with (restart):
-- =========================================================>
function this:reset(restart)
    -->> Current screen-specific object reference
    local current = self.shadow
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.shadow = nil
        --> Restarts the widget if needed
        if (restart) then
            --> Current screen-specific configuration
            local config = beautiful.shadow
            --> Ensure the object's state
            --> remains the same trough restarts
            config.state = current.widget.main.visible
            --> Ensure the object's timer
            --> remains the same trough restarts
            config.timer = (current.timer and current.timer.started)
            --> Initialize the new object
            self:init()
            --> If a tag was being shown ensure it is shown again
            if (current.tag) then
                self.shadow.actions.update(current.tag)
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
