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
--  [Table] This:
-- =========================================================>
local this = {sessions = {}}
-- =========================================================>
--  [Functions] Session:
-- =========================================================>
--> Initializes the session for screen (s):
-- =========================================================>
function this:init(s)
    -->> Exit guard
    if (not self.sessions[s.index]) then
        -->> Current screen-specific object reference
        self.sessions[s.index] = {widget = {}}
        local current = self.sessions[s.index]

        -->> Code shortening declarations
        local config = beautiful.session(s)
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end

        -->> Current object actions
        current.actions = {
            open = function()
                current.widget.main.visible = true
                return current.keygrabber.on
            end,
            close = function()
                current.widget.main.visible = false
                return current.keygrabber.stop --> Proper tail call
            end,
            session = {
                shutdown = function()

                end



            }
        }

        -->> Current object keygrabber
        current.keygrabber = awful.keygrabber({
            --auto_start = true,
            stop_event = "release",
            keypressed_callback = function(self, mod, key, command)
                if key == "s" then
                    suspend_command()
                elseif key == "e" then
                    exit_command()
                elseif key == "l" then
                    lock_command()
                elseif key == "p" then
                    poweroff_command()
                elseif key == "r" then
                    reboot_command()
                elseif key == "Escape" or key == "q" or key == "x" then
                    awesome.emit_signal("module::exit_screen:hide")
                end
            end,
        })

        -->> Current object widget
        return link_to(
            awful.popup({
                screen = s,
                ontop = true,
                type = "splash",
                visible = false,
                cursor = "cross",
                minimum_width = s.geometry.width,
                maximum_width = s.geometry.width,
                placement = gears.placement.center,
                minimum_height = s.geometry.height,
                maximum_height = s.geometry.height,
                bg = gears.color.change_opacity(
                    table.get_dynamic(config.color.background),
                    config.opacity
                ),
                buttons = awful.button({
                    modifiers = {},
                    group = "session",
                    button = awful.button.names.LEFT,
                    description = "Hide the session manager",
                    --> Close object on left click
                    on_release = current.actions.close
                }),
                widget = {
                    {
                        {
                            sfx.on_hover(
                                {
                                    {
                                        {
                                            halign = "center",
                                            markup = beatuiful.icon.text.shutdown,
                                            font = beautiful.fonts.icon(config.buttons.font_size),
                                            widget = wibox.widget.textbox
                                        },
                                        widget = wibox.container.place
                                    },
                                    shape = config.buttons.shape,
                                    fg = config.buttons.foreground,
                                    bg = config.buttons.background,
                                    forced_width = config.buttons.size,
                                    forced_height = config.buttons.size,
                                    border_color = config.buttons.accent,
                                    border_width = dpi(config.buttons.thickness, s),
                                    buttons = awful.button({
                                        modifiers = {},
                                        group = "session",
                                        button = awful.button.names.LEFT,
                                        description = "Shutdown session",
                                        --> Close object on left click
                                        on_release = current.actions.session.shutdown
                                    }),
                                    widget = wibox.container.background
                                }, {border_color = "red", fg = "red"}
                            )
                        },
                        spacing = dpi(15, s),
                        layout = wibox.layout.fixed.horizontal
                    },
                    widget = wibox.container.place
                }
            }), "main"
        ) --> Proper tail call
    end
    -->> Always return what must be returned
    return self.sessions[s.index].widget.main
end
-- =========================================================>
--> Resets the session for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.sessions[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.sessions[s.index] = nil
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
