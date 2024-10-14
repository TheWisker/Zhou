-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          TERMINAL
-- =========================================================>
----> AwesomeWM Taskbar Terminal Widget
-- =========================================================>
--                           TODO
-- =========================================================>
--  1. Fix highlighting of the '|' char (related to 2)
--  2. Fix problems with chars that use Mod5 (AltGr) like '@'
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
local rubato = require("lib.rubato")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {terminals = {}}
-- =========================================================>
--  [Definitions] Terminal:
-- =========================================================>
-->> Complete memory-union utility definition :>
-- =========================================================>
this.data = {
    -->> Tag used to store the cursor position when highlighting
    --> It is intended to be a combination of characters
    --> that is really unlikely to be entered on the terminal
    --> It also has spaces on both ends to make substitution patterns
    --> easier when the cursor is positioned inside or in the edges of a match
    tag = " #CVRS0R# ",
    -->> Array of match patterns with respective substitution keys
    match = {
        {
            subs = 1,
            --> Matches variables ($var)
            pattern = "(%$%a%w*)"
        },
        {
            subs = 2,
            --> Matches the character (&)
            pattern = "(&amp;)" --> XML escape code
        },
        {
            subs = 2,
            --> Matches the character (>)
            pattern = "(&gt;)" --> XML escape code
        },
        {
            subs = 3,
            --> Matches anything in between ('')
            pattern = "(&apos;.*&apos;)" --> XML escape code
        },
        {
            subs = 3,
            --> Matches anything in between ("")
            pattern = "(&quot;.*&quot;)" --> XML escape code
        }
    },
    -->> Array of substitution patterns
    subs = {
        function(config)
            return text.color(
                "%1",
                table.get_dynamic(config.color.hightlighter.variable)
            ) --> Proper tail call
        end,
        function(config)
            return text.color(
                "%1",
                table.get_dynamic(config.color.hightlighter.control)
            ) --> Proper tail call
        end,
        function(config)
            return text.color(
                "%1",
                table.get_dynamic(config.color.hightlighter.string)
            ) --> Proper tail call
        end
    }
}
-- =========================================================>
--  [Functions] Terminal:
-- =========================================================>
--> Initializes the terminal for screen (s):
-- =========================================================>
function this:init(s)
    -->> Terminal guard
    if (not self.terminals[s.index]) then
        -->> Current screen-specific object reference
        self.terminals[s.index] = {widget = {}, state = false}
        local current = self.terminals[s.index]

        -->> Code shortening declarations
        local config = beautiful.terminal
        local link_to = function(widget, key)
            return link.to(current.widget, widget, key) --> Proper tail call
        end
        local size = {
            width = dpi(config.size, s),
            height = dpi(beautiful.taskbar.height, s)
        }

        -->> Current object state
        current.state = config.state

        -->> Current object actions
        current.actions = {
            -->> Switch between open and closed states
            switch = function()
                if (current.state) then
                    return current.actions.close() --> Proper tail call
                else
                    return current.actions.open() --> Proper tail call
                end
            end,
            -->> Open the object throught its animation
            open = function()
                current.state = true
                current.animations.open.state = true
                current.animations.open.target = size.width
                current.widget.evoker.image = color.image(
                    beautiful.icon.image.arrow.left,
                    table.get_dynamic(config.color.icon)
                )
                return current.actions.run() --> Proper tail call
            end,
            -->> Close the object throught its animation
            close = function()
                config.text = nil
                current.state = false
                current.animations.opacity.state = true
                current.animations.opacity.target = 0
                current.widget.evoker.image = color.image(
                    beautiful.icon.image.arrow.right,
                    table.get_dynamic(config.color.icon)
                )
            end,
            -->> Run the object's prompt
            run = function()
                -->> Current object prompt
                return awful.prompt.run({
                    text = config.text,
                    history_max = config.history,
                    textbox = current.widget.prompt,
                    done_callback = current.actions.close,
                    bg_cursor = table.get_dynamic(config.color.cursor),
                    prompt = config.format.prompt(config.prompt.prefix),
                    font = beautiful.fonts.main(config.prompt.font_size),
                    history_path = gears.filesystem.get_cache_dir() .. "/prompt.ch",
                    -->> Command (c) on-change callback
                    changed_callback = function()
                        --> On prompt input reset timer timeout
                        if (current.timer.started) then
                            return current.timer:again() --> Proper tail call
                        end
                    end,
                    -->> Command (c) on-execution callback
                    exe_callback = function(c)
                        -->> Remove leading and trailing spaces
                        c = text.clean(c)
                        -->> Manage execution options
                        if (c:sub(1, 1) == ">") then
                            --> Command starts with > -> Execute with sudo
                            c = "sudo " .. c:sub(2)
                        elseif (c:sub(1, 1) == ":") then
                            if (c:sub(2, 2) == ">") then
                                --> Command starts with :> -> Execute with sudo on terminal app
                                c = beautiful.apps.terminal .. " -e sudo " .. c:sub(3)
                            else
                                --> Command starts with : -> Execute on terminal app
                                c = beautiful.apps.terminal .. " -e " .. c:sub(2)
                            end
                        end
                        --> Spawn actual command
                        return awful.spawn.with_shell(c) --> Proper tail call
                    end,
                    -->> Command (c) on-completion callback
                    completion_callback = mysc.memoize(
                        --> Cursor position (cur_pos), number of completion element (ncomp)
                        function(c, cur_pos, ncomp)
                            --> Supported shells: bash or zsh.
                            return awful.completion.shell(c, cur_pos, ncomp, config.completion_shell) --> Proper tail call
                        end
                    ),
                    -->> Command (bc .. ac) highlighting callback
                    highlighter = function(bc, ac)
                        --> Tag and format command
                        local c = config.format.command(bc .. self.data.tag .. ac)
                        --> Loop trough all patterns
                        for k=1,#(self.data.match) do
                            --> Make global substitution
                            c = c:gsub(
                                self.data.match[k].pattern,
                                self.data.subs[self.data.match[k].subs](config)
                            )
                        end
                        --> Find tagged cursor position
                        local cursor = c:find(self.data.tag)
                        --> Return command split in before cursor and after cursor
                        return c:sub(1, cursor - 1), c:sub(cursor + #(self.data.tag))
                    end,
                    -->> Prompt hooks
                    hooks = {
                        { --> {Ctrl + Enter}: Execute in terminal
                            {"Ctrl"}, --> Modifier
                            "Return", --> Key
                            function(c) --> Callback
                                -->> Remove leading and trailing spaces
                                c = text.clean(c)
                                -->> Manage execution option
                                return ((c:sub(1, 1) ~= ":") and (":" .. c) or c:sub(2)), false
                            end
                        },
                        { --> {Shift + Enter}: Execute in elevated environment
                            {"Shift"}, --> Modifier
                            "Return", --> Key
                            function(c) --> Callback
                                -->> Remove leading and trailing spaces
                                c = text.clean(c)
                                -->> Manage execution options
                                if (c:sub(1, 1) == ":") then
                                    return ((c:sub(2, 2) ~= ">") and (":>" .. c:sub(3)) or (":" .. c:sub(3))), false
                                else
                                    return ((c:sub(1, 1) ~= ">") and (">" .. c:sub(2)) or c:sub(2)), false
                                end
                            end
                        }
                    }
                }) --> Proper tail call
            end
        }

        -->> Current object animations
        current.animations = {
            -->> Object open enlargement animation
            open = rubato.timed({
                state = false,
                rate = beautiful.animation.fps,
                --> Constraint must be jumpstarted
                --> according to current object state
                pos = (current.state and size.width or 0),
                easing = beautiful.animation.widget.terminal.easing,
                duration = beautiful.animation.widget.terminal.duration,
                subscribed = function(pos)
                    --> Change constraint width
                    current.widget.constraint.width = pos
                    --> If it is opening (less to more) and has achieved 80% or more width
                    if (current.animations.open.state and (pos >= (size.width * 0.8))) then
                        --> Avoid running 'if' more than once
                        current.animations.open.state = false
                        --> Set respective sibling animation state and target
                        current.animations.opacity.state = false
                        current.animations.opacity.target = 1
                    end
                end
            }),
            -->> Object opacity in-and-out animation
            opacity = rubato.timed({
                state = false,
                rate = beautiful.animation.fps,
                --> Opacity must be jumpstarted
                --> according to current object state
                pos = (current.state and 1 or 0),
                easing = beautiful.animation.widget.terminal.easing,
                duration = (beautiful.animation.widget.terminal.duration/2),
                subscribed = function(pos)
                    --> Change prompt opacity
                    current.widget.prompt.opacity = pos
                    --> If it is fading (more to less) and has achieved 40% or less opacity
                    if (current.animations.opacity.state and (pos <= 0.4)) then
                        --> Avoid running 'if' more than once
                        current.animations.opacity.state = false
                        --> Set respective sibling animation state and target
                        current.animations.open.state = false
                        current.animations.open.target = 0
                    end
                end
            })
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
                    --> If object open close it
                    if (current.state) then
                        current.actions.close()
                        --> If it was open it must have its keygrabber running
                        --> on top unless another keygrabber was opened on top of this one.
                        --> This edge-case is hardly addressable because of the
                        --> closed structure, with which the 'awful.prompt' package is
                        --> designed, that does not export the actual keygrabber object.
                        if (awful.keygrabber.is_running and awful.keygrabber.current_instance) then
                            --> Stop the topmost keygrabber whichever it may be
                            return awful.keygrabber.current_instance:stop() --> Proper tail call
                        end
                    end
                end
            })
        end

        -->> Current object widget
        return event.connect(
            event.connect(
                link_to(
                    {
                        link_to(
                            {
                                {
                                    link_to(
                                        {
                                            ellipsize = config.prompt.ellipsize,
                                            --> Opacity must be jumpstarted
                                            --> according to current object state
                                            opacity = (current.state and 1 or 0),
                                            widget = wibox.widget.textbox
                                        }, "prompt"
                                    ),
                                    margins = mysc.margins(0, 10, s),
                                    widget = wibox.container.margin
                                },
                                --> Constraint must be jumpstarted
                                --> according to current object state
                                width = (current.state and size.width or 0),
                                widget = wibox.container.constraint
                            }, "constraint"
                        ),
                        sfx.on_hover(
                            sfx.on_press(
                                {
                                    {
                                        link_to(
                                            {
                                                auto_dpi = true,
                                                halign = "center",
                                                scaling_quality = "best",
                                                forced_width = (size.height * 0.6),
                                                forced_height = (size.height * 0.6),
                                                image = color.image(
                                                    --> Arrow direction must be jumpstarted
                                                    --> according to current object state
                                                    beautiful.icon.image.arrow[(current.state and "left" or "right")],
                                                    table.get_dynamic(config.color.icon)
                                                ),
                                                widget = wibox.widget.imagebox
                                            }, "evoker"
                                        ),
                                        widget = wibox.container.place
                                    },
                                    forced_width = size.height,
                                    forced_height = size.height,
                                    bg = beautiful.color.static.transparent,
                                    shape = mysc.shape("rounded_rect", (size.height/2), s),
                                    buttons = awful.button({
                                        modifiers = {},
                                        group = "terminal",
                                        button = awful.button.names.LEFT,
                                        description = "Toggles the terminal",
                                        --> Switch object state on evoker left-click event
                                        on_release = current.actions.switch
                                    }),
                                    widget = wibox.container.background
                                }, {bg = beautiful.color.static.click}
                            ), {cursor = beautiful.cursor.button, bg = beautiful.color.static.hover}
                        ),
                        layout = wibox.layout.fixed.horizontal
                    }, "main"
                ), function() return current.timer:start() end, "mouse::leave", (not current.timer)
            ), function() return current.timer:stop() end, "mouse::enter", (not current.timer)
        ) --> Proper tail call
    end
    -->> Always return what must be returned
    return self.terminals[s.index].widget.main
end
-- =========================================================>
--> Resets the terminal for screen (s) with (restart):
-- =========================================================>
function this:reset(s, restart)
    -->> Current screen-specific object reference
    local current = self.terminals[s.index]
    -->> If there is an object then reset it
    if (current) then
        --> Remove references to the object on our end
        self.terminals[s.index] = nil
        --> Restarts the widget if needed
        if (restart) then
            --> Current screen-specific configuration
            local config = beautiful.terminal
            --> Ensure the object's state
            --> remains the same trough restarts
            config.state = current.state
            --> Ensure the object's timer
            --> remains the same trough restarts
            config.timer = current.timer.started
            --> Ensure the object's prompt text
            --> remains the same trough restarts
            config.text = text.clean(
                current.widget.prompt.text:sub(
                    #(config.prompt.prefix)
                )
            )
            --> Initialize the new object
            self:init(s)
            --> If the prompt was running run it again
            if (current.state) then
                --> If it was open it must have its keygrabber running
                --> on top unless another keygrabber was opened on top of this one.
                --> This edge-case is hardly addressable because of the
                --> closed structure, with which the 'awful.prompt' package is
                --> designed, that does not export the actual keygrabber object.
                if (awful.keygrabber.is_running and awful.keygrabber.current_instance) then
                    --> Stop the topmost keygrabber whichever it may be
                    awful.keygrabber.current_instance:stop()
                end
                --> The cursor position before the reset will be forcefully
                --> set to the end of the prompt be it where it may before.
                --> This edge-case is hardly addressable because of the
                --> closed structure, with which the 'awful.prompt' package is
                --> designed, that does not export the actual cursor position property.
                self.terminals[s.index].actions.run()
            end
        end
        --> Stop the timer if needed and
        --> allow it to be garbage-collected
        if (current.timer) then
            current.timer:stop()
        end
        --> Remove references to the object on awesome's end
        current.widget.main.visible = false
    end
end
-- =========================================================>
return this
