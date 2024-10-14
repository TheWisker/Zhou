-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                            SFX
-- =========================================================>
----> AwesomeWM Special Effects Utils
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local beautiful = require("beautiful")
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local mysc = require("util.mysc")
local link = require("util.link")
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local rubato = require("lib.rubato")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
local mouse = mouse
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Functions] SFX:
-- =========================================================>
---> Sets up the widget's (w) signals for the on/off
---> events (e) for special effects properties (sfx):
-- =========================================================>
local function setup(w, sfx, e)
    -->> Initialize sfx if needed
    if (not w.sfx) then w.sfx = {active = {stack = {}}} end
    -->> Initialize our event in sfx
    w.sfx[e] = {on = sfx, off = {}, func = {}, animation = {}}
    -->> Retrieve event animation configuration
    local config = beautiful.animation.event[e]
    -->> Code shortening declarations
    local event = w.sfx[e]
    local active = w.sfx.active
    local stack = w.sfx.active.stack
    local link_fn = function(func, key)
        return link.to(event.func, func, key) --> Proper tail call
    end
    -->> Copy current properties that will
    -->> be crushed in 'on' state to 'off' state
    for key,value in next, event.on do
        --> Source widget values cannot be dynamic
        event.off[key] = w[key]
        --> Target sfx values can be dynamic
        event.on[key] = table.get_dynamic(value)
    end
    -->> Closure function to crush state (s)
    local crush_state = function(s)
        --> Loop trough all the properties in the state
        for key,value in next, event[s] do
            --> If property is animation-enabled
            if (config.properties.enabled[key]) then
                --> If there is not an animation object then make one
                if (not event.animation[key]) then
                    --> Make the animation object per se
                    event.animation[key] = rubato.timed({
                        easing = config.easing,
                        duration = config.duration,
                        rate = beautiful.animation.fps,
                        pos = config.properties.value[key](w[key]),
                        subscribed = config.properties.subscribed[key](w, key, value)
                    })
                end
                --> Set the target for the animation object to set the property gradually in widget
                event.animation[key].target = config.properties.value[key](value)
            else
                --> Set property directly in widget
                w[key] = value
            end
        end
    end

    -->> Why use 'weak_connect_signal'?
    --> We use 'weak_connect_signal' instead of 'connect_signal' as
    --> to allow the signals to be disconnected when the functions are
    --> garbage-collected. Having bound each function lifetime to 'event'
    --> which has in turn its lifetime bound to 'sfx' we ensure the signals
    --> disconnect automatically at some point after 'sfx' or 'event are destroyed.

    -->> Connect 'on' signal
    w:weak_connect_signal(
        config.trigger.on,
        link_fn(
            function()
                --> Garbage-collection guard
                if (w.sfx) then
                    --> If there are events active in
                    --> the stack then crush widget state 'off'
                    if ((#stack) >= 1) then
                        crush_state("off")
                    end
                    --> If event is not active activate it
                    --> and push it to the end of the stack
                    if (not active[e]) then
                        active[e] = true
                        stack[((#stack) + 1)] = e
                    end
                    --> Special handling of the cursor property, needed
                    --> as its inner workings require it, otherwise it will not work
                    if (event.on.cursor and mouse.current_wibox) then
                    mouse.current_wibox.cursor = event.on.cursor
                    end
                    --> Crush widget state 'on'
                    return crush_state("on") --> Proper tail call
                end
            end, "on"
        )
    )

    -->> Connect 'off' signal
    w:weak_connect_signal(
        config.trigger.off,
        link_fn(
            function()
                --> Garbage-collection guard
                if (w.sfx) then
                    --> Deactivate event
                    active[e] = nil
                    --> Starts checking if the last event is the current one
                    local ev = stack[(#stack)] == e
                    --> Loop trough the stack
                    for i=1,(#stack) do
                        --> Check is there is an event
                        --> and if the last one is the current one
                        if ev then
                            --> Event is at the end of the stack
                            ev = stack[(#stack)]
                            --> If the last event is
                            --> active then crush its state 'on'
                            if (active[ev]) then
                                return w.sfx[ev].func.on() --> Proper tail call
                            end
                        end
                        --> Else remove it from stack
                        --> thus decrasing (#stack) by one
                        stack[(#stack)] = nil
                    end
                    --> Special handling of the cursor property, needed
                    --> as its inner workings require it, otherwise it will not work
                    if (event.off.cursor and mouse.current_wibox) then
                    mouse.current_wibox.cursor = event.off.cursor
                    end
                    --> Crush widget state 'off'
                    return crush_state("off") --> Proper tail call
                end
            end, "off"
        )
    )
    return w
end
-- =========================================================>
---> Sets up the widget's (w) hover
---> events for special effects properties (sfx):
-- =========================================================>
function this.on_hover(w, sfx, off)
    --> Make w a widget if it is not one
    w = mysc.to_widget(w)
    if (not off) then
        --> Set up the events
        return setup(w, sfx, "hover") --> Proper tail call
    end
    return w
end
-- =========================================================>
---> Sets up the widget's (w) press
---> events for special effects properties (sfx):
-- =========================================================>
function this.on_press(w, sfx, off)
    --> Make w a widget if it is not one
    w = mysc.to_widget(w)
    if (not off) then
        --> Set up the events
        return setup(w, sfx, "press") --> Proper tail call
    end
    return w
end
-- =========================================================>
return this
