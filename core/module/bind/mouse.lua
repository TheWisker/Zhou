-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                       BIND - MOUSE
-- =========================================================>
----> AwesomeWM Global & Client Mouse Bindings
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local dpi = require("beautiful").xresources.apply_dpi
-- =========================================================>
--  [Imports] Signal:
-- =========================================================>
local signal = require("module.signal")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
local mouse = mouse
local client = client
-- =========================================================>
--  [Imports] Bind - Mouse:
-- =========================================================>
local ks = require("module.bind.keys")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Config] Snapping:
-- =========================================================>
--> Enable screen edges snapping:
-- =========================================================>
awful.mouse.snap.edge_enabled = true
-- =========================================================>
--> Enable client to client snapping:
-- =========================================================>
awful.mouse.snap.client_enabled = true
-- =========================================================>
--> Switch tag when client is dragged to edge of the screen:
-- =========================================================>
awful.mouse.drag_to_tag.enabled = true
-- =========================================================>
--> The default distance before activating screen edge snap:
-- =========================================================>
awful.mouse.snap.aerosnap_distance = dpi(10)
-- =========================================================>
--> The default distance before snapping clients together:
-- =========================================================>
awful.mouse.snap.default_distance = dpi(20)
-- =========================================================>
--  [Mousebindings] Global & Clients:
-- =========================================================>
this.mousebindings = {
    global = {
-- =========================================================>
---> Desktop global mouse bindings:
-- =========================================================>
        group = "desktop",
-- =========================================================>
        awful.button({
            modifiers = {},
            button = awful.button.names.LEFT,
            description = "Switch to next wallpaper",
            on_release = function()

            end
        }),
        awful.button({
            modifiers = {},
            button = awful.button.names.MIDDLE,
            description = "Toggle wallpaper timers", --notify state
            on_release = function()
                return signal.wallpaper.pause(mouse.screen) --> Proper tail call
            end
        }),
        awful.button({
            modifiers = {},
            button = awful.button.names.RIGHT,
            description = "Switch to next wallpaper", -- Show menu
            on_release = function()
                return signal.wallpaper.next(mouse.screen) --> Proper tail call
            end
        }),
-- =========================================================>
        awful.button({
            modifiers = {},
            button = awful.button.names.SCROLL_UP,
            description = "Switch to next tag",
            on_release = function()
                return awful.tag.viewnext(mouse.screen) --> Proper tail call
            end
        }),
        awful.button({
            modifiers = {},
            button = awful.button.names.SCROLL_DOWN,
            description = "Switch to previous tag",
            on_release = function()
                return awful.tag.viewprev(mouse.screen) --> Proper tail call
            end
        })
-- =========================================================>
    },
    client = {
-- =========================================================>
---> Client mouse bindings:
-- =========================================================>
        group = "client",
-- =========================================================>
        awful.button({
            modifiers = {},
            button = awful.button.names.LEFT,
            description = "Activate the client",
            on_press = function(c)
                return c:activate({
                    context = "mouse_click"
                }) --> Proper tail call
            end
        }),
-- =========================================================>
        awful.button({
            modifiers = {ks.MOD},
            button = awful.button.names.LEFT,
            description = "Move the client as per how the mouse moves",
            on_press = function(c)
                return c:activate({
                    context = "mouse_click",
                    action = "mouse_move"
                }) --> Proper tail call
            end
        }),
        awful.button({
            modifiers = {ks.MOD},
            button = awful.button.names.MIDDLE,
            description = "Toggle minimization of the client",
            on_press = function(c)
                return c:activate({
                    context = "mouse_click",
                    action = "toggle_minimization"
                }) --> Proper tail call
            end
        }),
        awful.button({
            modifiers = {ks.MOD},
            button = awful.button.names.RIGHT,
            description = "Resize the client as per how the mouse moves",
            on_press = function(c)
                return c:activate({
                    context = "mouse_click",
                    action = "mouse_resize"
                }) --> Proper tail call
            end
        }),
-- =========================================================>
        awful.button({
            modifiers = {ks.MOD, ks.CTRL},
            button = awful.button.names.MIDDLE,
            description = "Kill the client using the X11 Protocol",
            on_press = function(c)
                return c:kill() --> Proper tail call
            end
        })
-- =========================================================>
    }
}
-- =========================================================>
--  [Functions] Bind - Mouse:
-- =========================================================>
---> Binds our mousebindings to awful.mouse:
-- =========================================================>
function this:bind(v)
    -->> If the bindspace matches bind globals
    if ((v == "global") or (v == "all")) then
        -->> Bind all global mousebindings in one call
        awful.mouse.append_global_mousebindings(
            self.mousebindings.global
        )
    end
    -->> If the bindspace matches bind clients
    if ((v == "client") or (v == "all")) then
        -->> Bind all client mousebindings in one call
        return awful.mouse.append_client_mousebindings(
            self.mousebindings.client
        ) --> Proper tail call
    end
end
-- =========================================================>
---> Unbinds our mousebindings from awful.mouse:
-- =========================================================>
function this:unbind(v)
    -->> If the bindspace matches unbind globals
    if ((v == "global") or (v == "all")) then
        -->> Loop trough all global mousebindings
        for _,mousebinding in next, self.mousebindings.global do
            awful.mouse.remove_global_mousebinding(mousebinding)
        end
    end
    -->> If the bindspace matches unbind clients
    if ((v == "client") or (v == "all")) then
        -->> Loop trough all client mousebindings
        for _,mousebinding in next, self.mousebindings.client do
            awful.mouse.remove_client_mousebinding(mousebinding)
        end
    end
end
-- =========================================================>
--  [Signal] Bind - Mouse:
-- =========================================================>
client.connect_signal(
    "request::default_mousebindings",
    function()
        return this:bind("client") --> Proper tail call
    end
)
-- =========================================================>
return this
