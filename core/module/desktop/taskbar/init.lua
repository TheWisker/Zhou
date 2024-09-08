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
local mysc = require("util.mysc")
local link = require("util.link")
local color = require("util.color")
local table = require("util.table")
-- =========================================================>
--  [Imports] Taskbar:
-- =========================================================>
local raven = require("module.desktop.taskbar.raven")
local clock = require("module.desktop.taskbar.clock")
local naught = require("module.desktop.taskbar.naught")
local taglist = require("module.desktop.taskbar.taglist")
local systray = require("module.desktop.taskbar.systray")
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
        local config = beautiful.taskbar(s)
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end

        -->> Current object widget
        return link_to(
            awful.wibar({
                screen = s,
                type = "dock",
                ontop = false,
                cursor = "cross",
                shape = config.shape,
                visible = config.visible,
                opacity = config.opacity,
                stretch = config.stretch,
                restrict_workarea = true,
                position = config.position,
                margins = mysc.dpi(config.margins, s),
                --> Needed as wibar.opacity does not
                --> seem to have any effect on the bg
                bg = gears.color.change_opacity(
                    table.get_dynamic(config.color.background),
                    config.opacity
                ),
                --> Height also takes into account the inner top-bottom padding
                height = dpi(config.height + (2 * config.padding), s),
                widget = {
                    {
                        {
                            raven:init(s),
                            mysc.enabled(
                                config.awesome.enabled,
                                {
                                    {
                                        auto_dpi = true,
                                        halign = "center",
                                        scaling_quality = "best",
                                        image = color.image(
                                            beautiful.icon.image.awesome,
                                            gears.color.change_opacity(
                                                table.get_dynamic(config.color.awesome),
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
                            terminal:init(s),
                            spacing = dpi(config.spacing + (config.awesome.enabled and 5 or 0), s),
                            layout = wibox.layout.fixed.horizontal
                        },
                        taglist:init(s),
                        {
                            systray:init(s),
                            layoutbox:init(s),
                            clock:init(s),
                            --naught:init(s),
                            spacing = dpi(config.spacing, s),
                            layout = wibox.layout.fixed.horizontal
                        },
                        expand = "none",
                        layout = wibox.layout.align.horizontal
                    },
                    margins = mysc.dpi(config.padding, s),
                    widget = wibox.container.margin
                }
            }), "main"
        ) --> Proper tail call
    end
    -->> Always return what must be returned
    return self.taskbars[s.index].widget.main
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
        terminal:reset(s, restart) --> Terminal widget
        taglist:reset(s, restart) --> Taglist widget
        systray:reset(s, restart) --> Systray widget
        layoutbox:reset(s, restart) --> Layoutbox widget
        clock:reset(s, restart) --> Clock widget
        --naught:reset(s, restart) --> Naught widget
        --> Restarts the widget if needed
        if (restart) then
            self:init(s)
        end
        --> Remove references to the object on awesome's end
        return current.widget.main:remove() --> Proper tail call
    end
end
-- =========================================================>
return this
