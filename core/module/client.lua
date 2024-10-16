-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          CLIENT
-- =========================================================>
----> AwesomeWM Clients
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
require("awful.autofocus")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local bling = require("lib.bling")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
local client = client --> Awesome Global
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Functions] Client:
-- =========================================================>
--> Set properties for client:
-- =========================================================>
function this.func(c)
    --> Code shortening declarations
    local config = beautiful.client
    --> Set client properties
    c.shape = config.shape
    c.border_width =  config.border.thickness
    if (c.active) then
        --> Set beautiful snap properties
        beautiful.snap_shape = config.snap.shape
        beautiful.snapper_gap = dpi(config.snap.gap, c.screen)
        beautiful.snap_bg = table.get_dynamic(config.snap.color)
        beautiful.snap_border_width = dpi(config.snap.thickness, c.screen)
        --> Set border color
        c.border_color = table.get_dynamic(config.border.color.focused)
        return bling.module.flash_focus.flashfocus(c) --> Proper tail call
    elseif (c.floating) then
        --> Set border color
        c.border_color = table.get_dynamic(config.border.color.floating)
    elseif (c.urgent) then
        --> Set border color
        c.border_color = table.get_dynamic(config.border.color.urgent)
        return bling.module.flash_focus.flashfocus(c) --> Proper tail call
    else
        --> Set border color
        c.border_color = table.get_dynamic(config.border.color.normal)
    end
end
-- =========================================================>
--> Initializes the clients:
-- =========================================================>
function this:init()
    -->> Enable client autofocus
    if (beautiful.client.autofocus) then
        client.connect_signal(
            "mouse::enter", 
            function(c)
                return c:emit_signal(
                    "request::activate",
                    "mouse_enter",
                    {raise = false}
                ) --> Proper tail call
            end
        )
    end
    -->> Connect focus signal
    client.connect_signal("focus", self.func)
    -->> Connect unfocus signal
    client.connect_signal("unfocus", self.func)
    -->> Connect manage signal
    client.connect_signal("request::manage", self.func)
    -->> Connect floating signal
    client.connect_signal("property::floating", self.func)
    -->> Connect urgent signal
    client.connect_signal("property::urgent", self.func)
    -->> Connect screen signal
    return client.connect_signal("property::screen", self.func) --> Proper tail call
end
-- =========================================================>
--> Resets the clients with (restart):
-- =========================================================>
function this:reset(restart)
    --> Restarts the object if needed
    if (restart) then
        --> Set properties for each client
        for _,c in next, client.get() do
            self.func(c)
        end
    else
        -->> Clean focus signal
        client.disconnect_signal("focus", self.func)
        -->> Clean unfocus signal
        client.disconnect_signal("unfocus", self.func)
        -->> Clean manage signal
        client.disconnect_signal("request::manage", self.func)
        -->> Clean floating signal
        client.disconnect_signal("property::floating", self.func)
        -->> Clean urgent signal
        client.disconnect_signal("property::urgent", self.func)
        -->> Clean screen signal
        return client.disconnect_signal("property::screen", self.func) --> Proper tail call
    end
end
-- =========================================================>
return this
