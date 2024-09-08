-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                      BIND - KEYBOARD
-- =========================================================>
----> AwesomeWM Global & Client Keyboard Bindings
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local beautiful = require("beautiful")
-- =========================================================>
--  [Imports] Signal:
-- =========================================================>
local signal = require("module.signal")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local playerctl = require("lib.bling").signal.playerctl.lib()
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
local client = client
-- =========================================================>
--  [Imports] Bind - Keyboard:
-- =========================================================>
local ks = require("module.bind.keys")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Keybindings] Global & Clients:
-- =========================================================>
---> Table containing global and client keybindings:
-- =========================================================>
this.keybindings = {
    global = {
        {
-- =========================================================>
---> Awesome global keyboard bindings:
-- =========================================================>
            group = "awesome",
-- =========================================================>
            awful.key({
                key = ks.H,
                modifiers = {ks.MOD},
                description = "Show/hide help popup",
                on_release = function()
                    --require("awful.hotkeys_popup").show_help()
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.R,
                modifiers = {ks.MOD, ks.CTRL},
                description = "Safe restart AwesomeWM",
                on_release = function()
                    return awful.util.restart() -- returns nil if correct and error message if fails because of bad config
                end
            }),
            awful.key({
                key = ks.R,
                modifiers = {ks.MOD, ks.SHIFT, ks.CTRL},
                description = "Safe restart AwesomeWM",
                on_release = awesome.restart
            }),
-- =========================================================>
            awful.key({
                key = ks.Q,
                modifiers = {ks.MOD, ks.CTRL},
                description = "Quit AwesomeWM",
                on_release = awesome.quit
            }),


            awful.key({
                key = ks.ESC,
                modifiers = {ks.MOD},
                description = "Open session popup",
                on_release = function()
                    return signal.exitscreen.show() --> Proper tail call
                end
            }),

            awful.key({
                key = ks.D,
                modifiers = {ks.MOD},
                description = "Show desktop",
                on_release = function()

                end
            }),

            awful.key({
                key = ks.LESS,
                modifiers = {ks.MOD},
                description = "Toggle taskbar",
                on_release = function()
                    return signal.taskbar.toggle() --> Proper tail call
                end
            }),


            awful.key({
                key = ks.L,
                modifiers = {ks.MOD},
                description = "Lock session",
                on_release = function()
                    return awful.spawn.with_shell(beautiful.exec.command.lock) --> Proper tail call
                end
            })
-- =========================================================>
        },
        {
-- =========================================================>
---> Application global keyboard bindings:
-- =========================================================>
            group = "application",
-- =========================================================>
            awful.key({
                key = ks.S,
                modifiers = {ks.MOD},
                description = "Open launcher",
                on_release = function()
                    return awful.spawn.with_shell(beautiful.exec.app.launcher) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.T,
                modifiers = {ks.MOD},
                description = "Open terminal emulator",
                on_release = function()
                    return awful.spawn.with_shell(beautiful.exec.app.terminal) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.F,
                modifiers = {ks.MOD},
                description = "Open file manager",
                on_release = function()
                    return awful.spawn.with_shell(beautiful.exec.app.files) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.B,
                modifiers = {ks.MOD},
                description = "Open browser",
                on_release = function()
                    return awful.spawn.with_shell(beautiful.exec.app.browser) --> Proper tail call
                end
            })
-- =========================================================>
        },
        {
-- =========================================================>
---> Tag global keyboard bindings:
-- =========================================================>
            group = "tag",
-- =========================================================>
            awful.key({
                key = ks.ESC,
                modifiers = {ks.MOD, ks.CTRL},
                description = "Switch to previous tag history index",
                on_release = function()
                    return awful.tag.history.restore(
                        awful.screen.focused()
                    ) --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.LEFT,
                modifiers = {ks.MOD, ks.CTRL},
                description = "Switch to previous tag",
                on_release = function()
                    return awful.tag.viewprev(
                        awful.screen.focused()
                    ) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.RIGHT,
                modifiers = {ks.MOD, ks.CTRL},
                description = "Switch to next tag",
                on_release = function()
                    return awful.tag.viewnext(
                        awful.screen.focused()
                    ) --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                keygroup = awful.key.keygroup.NUMPAD,
                modifiers = {ks.MOD},
                description = "Show only the focused screen's nth tag",
                on_release = function(index)
                    local tag = awful.screen.focused().tags[index]
                    if (tag) then
                        return tag:view_only() --> Proper tail call
                    end
                end
            }),
            awful.key({
                keygroup = awful.key.keygroup.NUMPAD,
                modifiers = {ks.MOD, ks.CTRL},
                description = "Toggle showing the focused screen's nth tag",
                on_release = function(index)
                    local tag = awful.screen.focused().tags[index]
                    if (tag) then
                        return awful.tag.viewtoggle(tag) --> Proper tail call
                    end
                end
            }),
-- =========================================================>
            awful.key({
                keygroup = awful.key.keygroup.NUMPAD,
                modifiers = {ks.MOD, ks.SHIFT},
                description = "Move the focused client to its screen's nth tag",
                on_release = function(index)
                    if (client.focus) then
                        local tag = client.focus.screen.tags[index]
                        if (tag) then
                            return client.focus:move_to_tag(tag) --> Proper tail call
                        end
                    end
                end
            }),
            awful.key({
                keygroup = awful.key.keygroup.NUMPAD,
                modifiers = {ks.MOD, ks.SHIFT, ks.CTRL},
                description = "Toggle the focused client on its screen's nth tag",
                on_release = function(index)
                    if (client.focus) then
                        local tag = client.focus.screen.tags[index]
                        if (tag) then
                            return client.focus:toggle_tag(tag) --> Proper tail call
                        end
                    end
                end
            })
-- =========================================================>
        },
        {
-- =========================================================>
---> Focus global keyboard bindings:
-- =========================================================>
            group = "focus",
-- =========================================================>
            awful.key({
                key = ks.U,
                modifiers = {ks.MOD},
                description = "Jump to urgent client",
                on_release = awful.client.urgent.jumpto
            }),
-- =========================================================>
            awful.key({
                key = ks.UP,
                modifiers = {ks.MOD},
                description = "Focus client up by direction",
                on_release = function()
                    return awful.client.focus.bydirection("up") --> Proper tail call
                end
            }),
            awful.key({
                key = ks.DOWN,
                modifiers = {ks.MOD},
                description = "Focus client down by direction",
                on_release = function()
                    return awful.client.focus.bydirection("down") --> Proper tail call
                end
            }),
            awful.key({
                key = ks.LEFT,
                modifiers = {ks.MOD},
                description = "Focus client left by direction",
                on_release = function()
                    return awful.client.focus.bydirection("left") --> Proper tail call
                end
            }),
            awful.key({
                key = ks.RIGHT,
                modifiers = {ks.MOD},
                description = "Focus client right by direction",
                on_release = function()
                    return awful.client.focus.bydirection("right") --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.J,
                modifiers = {ks.MOD},
                description = "Focus previous client by index",
                on_release = function()
                    return awful.client.focus.byidx(-1) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.K,
                modifiers = {ks.MOD},
                description = "Focus next client by index",
                on_release = function()
                    return awful.client.focus.byidx( 1) --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.J,
                modifiers = {ks.MOD, ks.ALT},
                description = "Focus previous screen by index",
                on_release = function()
                    return awful.screen.focus_relative(-1) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.K,
                modifiers = {ks.MOD, ks.ALT},
                description = "Focus next screen by index",
                on_release = function()
                    return awful.screen.focus_relative( 1) --> Proper tail call
                end
            })
-- =========================================================>
        },
        {
-- =========================================================>
---> Resize global keyboard bindings:
-- =========================================================>
            group = "move",
-- =========================================================>
            awful.key({
                keygroup = awful.key.keygroup.ARROWS,
                modifiers = {ks.MOD, ks.SHIFT},
                description = "Move the client in the direction of the arrow",
                on_release = function(arrow)
                    local c = client.focus
                    if (c) then
                        if (c.floating or (awful.layout.get(c.screen) == awful.layout.suit.floating)) then
                            local workarea = awful.screen.focused().workarea
                            local useless_gap = awful.screen.focused().selected_tag.gap
                            if (arrow == "up") then
                                return c:geometry({nil, y = workarea.y + (useless_gap * 2), nil, nil}) --> Proper tail call
                            elseif (arrow == "down") then
                                return c:geometry({nil, y = (workarea.height + workarea.y) - (c:geometry().height + (useless_gap * 2) + (c.border_width * 2)), nil, nil}) --> Proper tail call
                            elseif (arrow == "left") then
                                return c:geometry({x = workarea.x + (useless_gap * 2), nil, nil, nil}) --> Proper tail call
                            elseif (arrow == "right") then
                                return c:geometry({x = (workarea.width + workarea.x) - (c:geometry().width + (s) + (c.border_width * 2)), nil, nil, nil}) --> Proper tail call
                            end
                        elseif (awful.layout.get(c.screen) == awful.layout.suit.max) then
                            if ((arrow == "up") or (arrow == "left")) then
                                return awful.client.swap.byidx(-1, c) --> Proper tail call
                            elseif ((direction == "down") or (direction == "right")) then
                                return awful.client.swap.byidx(1, c) --> Proper tail call
                            end
                        else
                            return awful.client.swap.bydirection(arrow, c, nil) --> Proper tail call
                        end
                    end
                end
            }),
            awful.key({
                keygroup = awful.key.keygroup.ARROWS,
                modifiers = {ks.MOD, ks.SHIFT, ks.ALT},
                description = "Swap the screen with the one in the direction of the arrow",
                on_release = function(arrow)
                    local s = awful.screen.focused()
                    return s:swap(
                        s:get_next_in_direction(arrow)
                    ) --> Proper tail call
                end
            })
        },
        {
-- =========================================================>
---> Resize global keyboard bindings:
-- =========================================================>
            group = "resize",
-- =========================================================>
            awful.key({
                keygroup = awful.key.keygroup.ARROWS,
                modifiers = {ks.MOD, ks.SHIFT, ks.CTRL},
                description = "Resize the client in the direction of the arrow",
                on_release = function(arrow)
                    local c = client.focus
                    if (c) then
                        if (c.floating or (awful.layout.get(c.screen) == awful.layout.suit.floating)) then
                            if ((arrow == "up") or (arrow == "down")) then
                                return c:relative_move(0, 0, 0, floating_resize_amount * ((arrow == "up") and -1 or 1)) --> Proper tail call
                            elseif ((arrow == "left") or (arrow == "right")) then
                                return c:relative_move(0, 0, floating_resize_amount * ((arrow == "left") and -1 or 1), 0) --> Proper tail call
                            end
                        else
                            if ((arrow == "up") or (arrow == "down")) then
                                return awful.client.incwfact(tiling_resize_factor * ((arrow == "up") and -1 or 1)) --> Proper tail call
                            elseif ((arrow == "left") or (arrow == "right")) then
                                return awful.tag.incmwfact(tiling_resize_factor * ((arrow == "left") and -1 or 1)) --> Proper tail call
                            end
                        end
                    end
                end
            })
        },
        {
-- =========================================================>
---> Layout global keyboard bindings:
-- =========================================================>
            group = "layout",
-- =========================================================>
            awful.key({
                key = ks.T,
                modifiers = {ks.MOD, ks.ALT},
                description = "Switch to tiling layout", -- make so that it changes direction on consecutive calls
                on_release = function()
                    return awful.layout.set(awful.layout.suit.tile) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.F,
                modifiers = {ks.MOD, ks.ALT},
                description = "Switch to floating layout",
                on_release = function()
                    return awful.layout.set(awful.layout.suit.floating) --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.LEFT,
                modifiers = {ks.MOD, ks.ALT},
                description = "Switch to previous layout",
                on_release = function()
                    return awful.layout.inc(
                        -1,
                        awful.screen.focused()
                    ) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.RIGHT,
                modifiers = {ks.MOD, ks.ALT},
                description = "Switch to next layout",
                on_release = function()
                    return awful.layout.inc(
                         1,
                        awful.screen.focused()
                    ) --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.J,
                modifiers = {ks.MOD, ks.SHIFT},
                description = "Swap with previous client by index",
                on_release = function()
                    return awful.client.swap.byidx(-1) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.K,
                modifiers = {ks.MOD, ks.SHIFT},
                description = "Swap with next client by index",
                on_release = function()
                    return awful.client.swap.byidx( 1) --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.H,
                modifiers = {ks.MOD},
                description = "Decrease the master_width_factor of the current focused layout",
                on_release = function()
                    return awful.tag.incmwfact(-0.05) --> Proper tail call -- set step in btful
                end
            }),
            awful.key({
                key = ks.L,
                modifiers = {ks.MOD},
                description = "Increase the master_width_factor of the current focused layout",
                on_release = function()
                    return awful.tag.incmwfact( 0.05)  --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.H,
                modifiers = {ks.MOD, ks.ALT},
                description = "Decrease the master_count of the current focused layout",
                on_release = function()
                    return awful.tag.incnmaster(-1, nil, true) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.L,
                modifiers = {ks.MOD, ks.ALT},
                description = "Increase the master_count of the current focused layout",
                on_release = function()
                    return awful.tag.incnmaster( 1, nil, true) --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.H,
                modifiers = {ks.MOD, ks.CTRL},
                description = "Decrease the column_count of the current focused layout",
                on_release = function()
                    return awful.tag.incncol(-1, nil, true) --> Proper tail call
                end
            }),
            awful.key({
                key = ks.L,
                modifiers = {ks.MOD, ks.CTRL},
                description = "Increase the column_count of the current focused layout",
                on_release = function()
                    return awful.tag.incncol( 1, nil, true) --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({ -- baad, colission
                keygroup =awful.key.keygroup.NUMROW,
                modifiers = {ks.MOD, ks.CTRL},
                description = "Toggle showing the focused screen's nth tag",
                on_release = function(index)
                    local tag = awful.screen.focused().selected_tag
                    if (tag) then
                        tag.layout = (tag.layouts[index] or tag.layout)
                    end
                end
            })
-- =========================================================>
        },
        {
-- =========================================================>
---> Audio global keyboard bindings:
-- =========================================================>
            group = "audio",
-- =========================================================>
            awful.key({
                key = ks.V_MUTE,
                modifiers = {},
                description = "Mute current audio sink",
                on_release = function()

                end
            }),
-- =========================================================>
            awful.key({
                key = ks.V_RAISE,
                modifiers = {},
                description = "Raise volume of current audio sink",
                on_release = function()

                end
            }),
            awful.key({
                key = ks.V_LOWER,
                modifiers = {},
                description = "Lower volume of current audio sink",
                on_release = function()

                end
            }),
-- =========================================================>
            awful.key({
                key = ks.A_PLAY,
                modifiers = {},
                description = "Play/pause current audio source",
                on_release = function()
                    return playerctl:play_pause() --> Proper tail call
                end
            }),
-- =========================================================>
            awful.key({
                key = ks.A_NEXT,
                modifiers = {},
                description = "Skip to next for current audio source",
                on_release = function()
                    return playerctl:next() --> Proper tail call
                end
            }),
            awful.key({
                key = ks.A_PREV,
                modifiers = {},
                description = "Skip to previous for current audio source",
                on_release = function()
                    return playerctl:previous() --> Proper tail call
                end
            })
        },
        {
-- =========================================================>
---> Special global keyboard bindings:
-- =========================================================>
            group = "special",
-- =========================================================>
            awful.key({
                key = ks.PRINT,
                modifiers = {},
                description = "Take a screenshot",
                on_release = function()
                    return awful.spawn.with_shell(beautiful.exec.app.screenshot) --> Proper tail call
                end
            }),
        }

    },
    client = {
-- =========================================================>
---> Client keyboard bindings:
-- =========================================================>
        group = "client",
-- =========================================================>
        awful.key({
            key = ks.SPACE,
            modifiers = {ks.MOD, ks.CTRL},
            description = "Toggle floating for the client",
            on_release = awful.client.floating.toggle
        }),
        awful.key({
            key = ks.F,
            modifiers = {ks.MOD, ks.CTRL},
            description = "Toggle fullscreen for the client",
            on_release = function(c)
                c.fullscreen = not c.fullscreen
                return c:raise() --> Proper tail call
            end
        }),
        awful.key({
            key = ks.O,
            modifiers = {ks.MOD, ks.CTRL},
            description = "Toggle ontop for the client",
            on_release = function(c)
                c.ontop = not c.ontop
                return c:raise() --> Proper tail call
            end
        }),
        awful.key({
            key = ks.P,
            modifiers = {ks.MOD, ks.CTRL},
            description = "Toggle sticky for the client",
            on_release = function(c)
                c.sticky = not c.sticky
                return c:raise() --> Proper tail call
            end
        }),
-- =========================================================>
        awful.key({
            key = ks.M,
            modifiers = {ks.MOD, ks.CTRL},
            description = "Toggle maximize for the client",
            on_release = function(c)
                c.maximized = not c.maximized
                return c:raise() --> Proper tail call
            end
        }),
        awful.key({
            key = ks.M,
            modifiers = {ks.MOD, ks.CTRL, ks.ALT},
            description = "Toggle maximize horizontal for the client",
            on_release = function(c)
                c.maximized_horizontal = not c.maximized_horizontal
                return c:raise() --> Proper tail call
            end
        }),
        awful.key({
            key = ks.M,
            modifiers = {ks.MOD, ks.CTRL, ks.SHIFT},
            description = "Toggle maximize vertical for the client",
            on_release = function(c)
                c.maximized_vertical = not c.maximized_vertical
                return c:raise() --> Proper tail call
            end
        }),
-- =========================================================>
        awful.key({
            key = ks.C,
            modifiers = {ks.MOD, ks.CTRL},
            description = "Center the client",
            on_release = function(c)
                return awful.placement.centered(c, {
                    honor_padding = true,
                    honor_workarea = true
                }) --> Proper tail call
            end
        }),
-- =========================================================>
        awful.key({
            key = ks.Q,
            modifiers = {ks.MOD, ks.CTRL},
            description = "Kill client using the X11 Protocol",
            on_release = function(c)
                return c:kill() --> Proper tail call
            end
        }),

-- =========================================================>
        awful.key({
            key = ks.PLUS,
            modifiers = {ks.MOD, ks.CTRL},
            description = "Upscale client by 0.05",
            on_release = function(c)
                return awful.placement.scale(c, {
                    by_percent = 0.05
                }) --> Proper tail call
            end
        }), -- LOOKOUT
        awful.key({
            key = ks.MINUS,
            modifiers = {ks.MOD, ks.CTRL},
            description = "Downscale client by 0.05",
            on_release = function(c)
                return awful.placement.scale(c, {
                    by_percent = -0.05
                }) --> Proper tail call
            end
        }) -- LOOKOUT

        --"move to master"
        --"move to screen cycling"
        --minimize and hide
-- =========================================================>
    }
}
-- =========================================================>
--  [Functions] Bind - Keyboard:
-- =========================================================>
---> Binds our keybindings to awful.keyboard:
-- =========================================================>
function this:bind(v)
    -->> If the bindspace matches bind globals
    if ((v == "global") or (v == "all")) then
        -->> Loop trough all global keybindings
        for _,keybindings in next, self.keybindings.global do
            --> We have to do it one by one
            --> as they are declared by groups
            awful.keyboard.append_global_keybindings(
                keybindings
            )
        end
    end
    -->> If the bindspace matches bind clients
    if ((v == "client") or (v == "all")) then
        -->> Bind all client keybindings in one call
        return awful.keyboard.append_client_keybindings(
            self.keybindings.client
        ) --> Proper tail call
    end
end
-- =========================================================>
---> Unbinds our keybindings from awful.keyboard:
-- =========================================================>
function this:unbind(v)
    -->> If the bindspace matches unbind globals
    if ((v == "global") or (v == "all")) then
        -->> Loop trough all global keybindings
        for _,keybindings in next, self.keybindings.global do
            for _,keybinding in next, keybindings do
                --> We have to do it one by one
                --> as they are declared by groups
                awful.keyboard.remove_global_keybinding(keybinding)
            end
        end
    end
    -->> If the bindspace matches unbind clients
    if ((v == "client") or (v == "all")) then
        -->> Loop trough all client keybindings
        for _,keybinding in next, self.keybindings.client do
            awful.keyboard.remove_client_keybinding(keybinding)
        end
    end
end
-- =========================================================>
--  [Signal] Bind - Keyboard:
-- =========================================================>
---> Connects the keybinding request petition to bind ours:
-- =========================================================>
client.connect_signal(
    "request::default_keybindings",
    function()
        return this:bind("client") --> Proper tail call
    end
)
-- =========================================================>
return this
