-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                         CHEATSHEET
-- =========================================================>
----> AwesomeWM Cheatsheet Popup Widget
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local hotkeys_popup = require("awful.hotkeys_popup")
--require("awful.hotkeys_popup.keys")
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local table = require("util.table")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local client = client --> Awesome Global
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {cheatsheet = nil}
-- =========================================================>
--  [Functions] Cheatsheet:
-- =========================================================>
--> Initializes the cheatsheet for desktop:
-- =========================================================>
function this:init()
    -->> Cheatsheet guard
    if (not self.cheatsheet) then
        -->> Current object reference
        self.cheatsheet = {widget = nil}
        local current = self.cheatsheet

        -->> Code shortening declarations
        local config = beautiful.cheatsheet

        -->> Current object actions
        current.actions = {
            show = function(sak)
                current.widget.width = (awful.screen.focused().geometry.width/2.5)--btful
                current.widget.height = (awful.screen.focused().geometry.height/2.5)
                return current.widget:show_help(nil, awful.screen.focused(), sak) --> Proper tail call -- client.focus
            end
        }

        -->> Current object widget
        current.widget = hotkeys_popup.widget.new({
            shape = config.shape,
            merge_duplicates = true,
            hide_without_description = true,
            group_margin = dpi(config.margin),
            border_width = dpi(config.thickness),
            font = beautiful.fonts.main(config.font_size),
            bg = gears.color.change_opacity(
                table.get_dynamic(config.color.background),
                config.opacity
            ),
            fg = table.get_dynamic(config.color.foreground),
            border_color = table.get_dynamic(config.color.accent),
            label_bg = table.get_dynamic(config.color.background),
            label_fg = table.get_dynamic(config.color.foreground),
            modifiers_fg = table.get_dynamic(config.color.mod_foreground),
            description_font = beautiful.fonts.main(config.desc_font_size)
        })
    end
end
-- =========================================================>
--> Resets the cheatsheet for desktop with (restart):
-- =========================================================>
function this:reset(restart)
    -->> Current screen-specific object reference
    local current = self.cheatsheet
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.cheatsheet = nil
        --> Remove references to the object on awesome's end
        current.widget.visible = false
        --> Restarts the widget if needed
        if (restart) then
           return self:init() --> Proper tail call
        end
    end
end
-- =========================================================>
return this