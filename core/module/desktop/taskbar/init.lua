-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          TASKBAR
-- =========================================================>
----> AwesomeWM Taskbar Widget
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local link = require("util.link")
local mysc = require("util.mysc")
local color = require("util.color")
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local rubato = require("lib.rubato")
-- =========================================================>
--  [Imports] Taskbar:
-- =========================================================>
local raven = require("module.desktop.taskbar.raven")
local clock = require("module.desktop.taskbar.clock")
local player = require("module.desktop.taskbar.player")
local taglist = require("module.desktop.taskbar.taglist")
local systray = require("module.desktop.taskbar.systray")
local tasklist = require("module.desktop.taskbar.tasklist")
local terminal = require("module.desktop.taskbar.terminal")
local layoutbox = require("module.desktop.taskbar.layoutbox")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {taskbars = {}}
-- =========================================================>
--  [Functions] Taskbar:
-- =========================================================>
--> Initializes the taskbar for screen (s):
-- =========================================================>
function this:init(s)
    -->> Taskbar guard
    if (not self.taskbars[s.index]) then

        -->> Current screen-specific object reference
        self.taskbars[s.index] = {widget = {}}
        local current = self.taskbars[s.index]

        -->> Code shortening declarations
        local config = beautiful.taskbar
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end

        -->> Current object actions
        current.actions = {
            toggle = function()
                current.widget.main.visible = not current.widget.main.visible
            end,
            position = function(pos)
                current.widget.progressbar.visible = (pos ~= -1)
                current.animations.progressbar.target = ((pos ~= -1) and pos or 0)
            end
        }

        -->> Current object animations
        current.animations = {
            -->> Object progressbar animation
            progressbar = rubato.timed({
                pos = (config.track or 0),
                rate = beautiful.animation.fps,
                easing = beautiful.animation.widget.taskbar.easing,
                duration = (beautiful.animation.widget.taskbar.duration),
                subscribed = function(pos)
                    current.widget.progressbar.value = pos
                end
            })
        }

        -->> Current object widget
        return link_to(
            awful.wibar({
                screen = s,
                type = "dock",
                ontop = false,
                shape = config.shape,
                cursor = config.cursor,
                visible = config.visible,
                opacity = config.opacity,
                stretch = config.stretch,
                restrict_workarea = true,
                position = config.position,
                margins = mysc.dpi(config.margins, s),
                --> Needed as wibar.opacity does not
                --> seem to have any effect on the bg
                bg = gears.color.change_opacity(
                    table.get_dynamic(config.color),
                    config.opacity
                ),
                --> Height also takes into account the inner top-bottom padding
                height = dpi(config.height + (2 * config.padding) + config.progressbar.height, s), -- update globally
                widget = {
                    link_to(
                        {
                            visible = true,
                            value = (config.track or 0),
                            shape = config.progressbar.shape,
                            opacity = config.progressbar.opacity,
                            bar_shape = config.progressbar.shape,
                            forced_height = dpi(config.progressbar.height, s),
                            color = table.get_dynamic(config.progressbar.color),
                            background_color = table.get_dynamic(config.progressbar.background),
                            widget = wibox.widget.progressbar
                        }, "progressbar"
                    ),
                    {
                        {
                            {
                                raven:init(s),
                                mysc.enabled( --> If 1st param is true then the 2nd param gets added
                                    (not config.awesome.disabled),
                                    {
                                        {
                                            auto_dpi = true,
                                            halign = "center",
                                            scaling_quality = "best",
                                            image = color.image(
                                                beautiful.icon.image.awesome,
                                                gears.color.change_opacity(
                                                    table.get_dynamic(config.awesome.color),
                                                    config.awesome.opacity
                                                )
                                            ),
                                            clip_shape = mysc.shape("rounded_rect", config.awesome.radius, s),
                                            widget = wibox.widget.imagebox
                                        },
                                        margins = mysc.dpi(config.awesome.margins, s),
                                        widget = wibox.container.margin
                                    }
                                ),
                                player:init(s),
                                terminal:init(s),
                                spacing = dpi(config.spacing + (config.awesome.disabled and 0 or 5), s),
                                layout = wibox.layout.fixed.horizontal
                            },
                            taglist:init(s),
                            {
                                systray:init(s),
                                tasklist:init(s),
                                layoutbox:init(s),
                                clock:init(s),
                                spacing = dpi(config.spacing, s),
                                layout = wibox.layout.fixed.horizontal
                            },
                            expand = "none",
                            layout = wibox.layout.align.horizontal
                        },
                        margins = mysc.dpi(config.padding, s),
                        widget = wibox.container.margin
                    },
                    layout = wibox.layout.fixed.vertical
                },
            }), "main"
        ) --> Proper tail call
    end
end
-- =========================================================>
--> Resets the taskbar for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.taskbars[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.taskbars[s.index] = nil
        --> Reset independent child widgets
        raven:reset(s, restart) --> Raven widget
        player:reset(s, restart) --> Player widget
        terminal:reset(s, restart) --> Terminal widget
        taglist:reset(s, restart) --> Taglist widget
        systray:reset(s, restart) --> Systray widget
        tasklist:reset(s, restart) --> Tasklist widget
        layoutbox:reset(s, restart) --> Layoutbox widget
        clock:reset(s, restart) --> Clock widget
        --> Restarts the widget if needed
        if (restart) then
            --> Initialize the new object
            self:init(s)
        end
        --> Remove references to the object on awesome's end
        return current.widget.main:remove() --> Proper tail call
    end
end
-- =========================================================>
return this
