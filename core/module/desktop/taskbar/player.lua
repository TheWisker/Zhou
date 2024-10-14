-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          PLAYER
-- =========================================================>
----> AwesomeWM Taskbar Player Widget
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
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local playerctl = require("lib.bling").signal.playerctl.lib()
-- =========================================================>
--  [Imports] Bind - Keyboard:
-- =========================================================>
local ks = require("module.bind.keys")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {players = {}}
-- =========================================================>
--  [Functions] Player:
-- =========================================================>
--> Initializes the player for screen (s):
-- =========================================================>
function this:init(s)
    -->> Player guard
    if (not self.players[s.index]) then
        -->> Current screen-specific object reference
        self.players[s.index] = {widget = {}, func = {}, player = nil}
        local current = self.players[s.index]

        -->> Code shortening declarations
        local config = beautiful.player
        config.metadata = config.metadata or {}
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        local link_fn = function(func, key)
            return link.to(current.func, func, key) --> Proper tail call
        end

        -->> Current object actions
        current.actions = {
            next = function()
                return playerctl:next(current.player) --> Proper tail call
            end,
            prev = function()
                if ((current.player:get_position()/(current.player.metadata.value["mpris:length"] or 1)) <= 0.05) then
                    return playerctl:previous(current.player) --> Proper tail call
                end
                return playerctl:set_position(0, current.player) --> Proper tail call
            end,
            toggle = function()
                return playerctl:play_pause(current.player) --> Proper tail call
            end,
            seek = function()
                return playerctl:set_position((current.player:get_position() / 1000000) + 5, current.player) --> Proper tail call
            end,
            rewind = function()
                return playerctl:set_position((current.player:get_position() / 1000000) - 5, current.player) --> Proper tail call
            end
        }

        -->> Metadata signal
        playerctl:connect_signal(
            "metadata",
            link_fn(
                function(_, title, artist, album_path, _, _, player_name)
                    title, artist = (title or "Unnamed"), (artist or "Unknown")
                    current.player = playerctl:get_player_of_name(player_name)
                    current.widget.tooltip.markup = config.tooltip.format(title .. " (" .. artist .. ")")
                    gears.table.crush(config.metadata, {player_name = player_name, title = title, artist = artist})
                    if (album_path) then
                        return signal.notification.notify(
                            {
                                title = title,
                                text = artist,
                                style = "default",
                                app_name = "Now Playing",
                                image = gears.surface.load_uncached_silently(
                                    album_path,
                                    beautiful.theme_assets.awesome_icon(
                                        100,
                                        table.get_dynamic(config.buttons.color),
                                        table.get_dynamic(beautiful.color.dynamic.background)
                                    )
                                )
                            }
                        ) --> Proper tail call
                    end
                end, "metadata"
            )
        )

        -->> Position signal
        playerctl:connect_signal(
            "position",
            link_fn(
                function(_, interval_sec, length_sec)
                    return signal.taskbar.position(interval_sec/length_sec, s) --> Proper tail call
                end, "position"
            )
        )
        -->> Playback_status signal
        playerctl:connect_signal(
            "playback_status",
            link_fn(
                function(_, playing)
                    current.widget.main.visible = true
                    gears.table.crush(config.metadata, {playing = playing})
                    current.widget.toggle.markup = text.color(
                        text.bold(
                            (playing and beautiful.icon.text.player.pause or beautiful.icon.text.player.play)
                        ), table.get_dynamic(config.buttons.color)
                    )
                end, "playback_status"
            )
        )
        -->> No_players signal
        playerctl:connect_signal(
            "no_players",
            link_fn(
                function()
                    current.widget.main.visible = false
                    current.widget.tooltip.visible = false
                    return signal.taskbar.position(-1, s) --> Proper tail call
                end, "no_players"
            )
        )

        -->> Current object widget
        return link.tooltip(
            link_to(
                awful.tooltip({
                    screen = s,
                    ontop = true,
                    visible = false,
                    mode = "outside",
                    type = "tooltip",
                    input_passthrough = true,
                    shape = config.tooltip.shape,
                    opacity = config.tooltip.opacity,
                    delay_show = config.tooltip.delay,
                    gaps = mysc.dpi(config.tooltip.gaps, s),
                    margins = mysc.dpi(config.tooltip.margins, s),
                    --> Needed as tooltip.opacity does not
                    --> seem to have any effect on the bg
                    bg = gears.color.change_opacity(
                        table.get_dynamic(config.tooltip.background),
                        config.tooltip.opacity
                    ),
                    fg = table.get_dynamic(config.tooltip.foreground),
                    preferred_alignments = {"middle", "back", "front"},
                    font = beautiful.fonts.main(config.tooltip.font_size)
                }), "tooltip"
            ),
            link_to(
                {
                    sfx.on_hover(
                        sfx.on_press(
                            {
                                {
                                    {
                                        halign = "center",
                                        markup = text.color(
                                            text.bold(beautiful.icon.text.player.backward),
                                            table.get_dynamic(config.buttons.color)
                                        ),
                                        font = beautiful.fonts.icon(config.buttons.font_size),
                                        buttons = {
                                            awful.button({
                                                modifiers = {},
                                                group = "player",
                                                button = awful.button.names.LEFT,
                                                description = "Restart or change to previous track for the current sink",
                                                on_release = current.actions.prev
                                            }),
                                            awful.button({
                                                modifiers = {ks.ALT},
                                                group = "player",
                                                button = awful.button.names.LEFT,
                                                description = "Seek the current track by 5s for the current sink",
                                                on_release = current.actions.rewind
                                            }),
                                        },
                                        widget = wibox.widget.textbox
                                    },
                                    margins = dpi(5, s),
                                    widget = wibox.container.margin
                                },
                                shape = config.buttons.shape,
                                bg = beautiful.color.static.transparent,
                                widget = wibox.container.background
                            }, {bg = beautiful.color.static.click}
                        ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}
                    ),
                    sfx.on_hover(
                        sfx.on_press(
                            {
                                {
                                    link_to(
                                        {
                                            halign = "center",
                                            markup = text.color(
                                                text.bold(beautiful.icon.text.player.play),
                                                table.get_dynamic(config.buttons.color)
                                            ),
                                            font = beautiful.fonts.icon(config.buttons.font_size),
                                            buttons = awful.button({
                                                modifiers = {},
                                                group = "player",
                                                button = awful.button.names.LEFT,
                                                description = "Play/pause the track for the current sink",
                                                on_release = current.actions.toggle
                                            }),
                                            widget = wibox.widget.textbox
                                        }, "toggle"
                                    ),
                                    margins = dpi(5, s),
                                    widget = wibox.container.margin
                                },
                                shape = config.buttons.shape,
                                bg = beautiful.color.static.transparent,
                                widget = wibox.container.background
                            }, {bg = beautiful.color.static.click}
                        ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}
                    ),
                    sfx.on_hover(
                        sfx.on_press(
                            {
                                {
                                    {
                                        halign = "center",
                                        markup = text.color(
                                            text.bold(beautiful.icon.text.player.forward),
                                            table.get_dynamic(config.buttons.color)
                                        ),
                                        font = beautiful.fonts.icon(config.buttons.font_size),
                                        buttons = {
                                            awful.button({
                                                modifiers = {},
                                                group = "player",
                                                button = awful.button.names.LEFT,
                                                description = "Change to next track for the current sink",
                                                on_release = current.actions.next
                                            }),
                                            awful.button({
                                                modifiers = {ks.ALT},
                                                group = "player",
                                                button = awful.button.names.LEFT,
                                                description = "Rewind the current track by 5s for the current sink",
                                                on_release = current.actions.seek
                                            })
                                        },
                                        widget = wibox.widget.textbox
                                    },
                                    margins = dpi(5, s),
                                    widget = wibox.container.margin
                                },
                                shape = config.buttons.shape,
                                bg = beautiful.color.static.transparent,
                                widget = wibox.container.background
                            }, {bg = beautiful.color.static.click}
                        ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}
                    ),
                    spacing = dpi(6, s),
                    visible = config.state,
                    layout = wibox.layout.fixed.horizontal
                }, "main"
            )
        ) --> Proper tail call
    end
    -->> Always return what must be returned
    return self.players[s.index].widget.main
end
-- =========================================================>
--> Resets the player for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.players[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.players[s.index] = nil
        --> Disconnect all signals
        playerctl:disconnect_signal("metadata", current.func.metadata)
        playerctl:disconnect_signal("position", current.func.position)
        playerctl:disconnect_signal("playback_status", current.func.playback_status)

        --> Restarts the widget if needed
        if (restart) then
            --> Current config
            local config = beautiful.player
            --> Save player state in config
            config.state = current.widget.main.visible
            --> Initialize the new object
            self:init(s)
            --> Set states to what they were previously
            if (config.metadata) then
                self.players[s.index].func.metadata(nil, config.metadata.title, config.metadata.artist, nil, nil, config.metadata.player_name)
                self.players[s.index].func.playback_status(nil, config.metadata.playing)
            end
        end
        --> Remove references to the object on awesome's end
        current.widget.main.visible = false
    end
end
-- =========================================================>
return this
