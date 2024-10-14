-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                            MYSC
-- =========================================================>
----> AwesomeWM Miscellaneous Utilities
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local type = type
local unpack = table.unpack
local setmetatable = setmetatable
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Definitions] Mysc:
-- =========================================================>
-->> Complete memory-union utility definition :>
-- =========================================================>
this.null = {}
-- =========================================================>
--  [Functions] Mysc:
-- =========================================================>
--> Ensures that the argument (w)
--> is a wibox.widget and returns it:
-- =========================================================>
function this.to_widget(w)
    --> Entry connect_signal is used as widget condition
    return w.connect_signal and w or wibox.widget(w)
end
-- =========================================================>
--> Returns function (f) as a memoize function:
-- =========================================================>
function this.memoize(f)
    return setmetatable({
        cache = setmetatable({}, {__mode = "kv"}),
        set = function(self, args, results)
            local node = self.cache
            for i=1, (args.n or #args) do
                node[args[i]] = node[args[i]] or {}
                node = node[args[i]]
            end
            node.results = results
            return unpack(results) --> Proper tail call
        end,
        get = function(self, args)
            local node = self.cache
            for i=1, (args.n or #args) do
                node = node[args[i]]
                if not node then return nil end
            end
            return unpack(node.results) --> Proper tail call
        end
    }, {
        __metatable = "memoize",
        __call = function(self, ...)
            -->> Argument "results" is illegal here -->> WIP use __ as prefix
            local results = self:get({...})
            return (results ~= nil) and results or self:set({...}, {f(...)})
        end
    })
end
-- =========================================================>
--> Returns a gears shape (sh) function with
--> radius (r) adjusted to the screen's (s) dpi:
-- =========================================================>
-->> Complete syntactic sugar utility function :<
-- =========================================================>
function this.shape(sh, r, s)
    r = dpi(r, s)
    return function(cr, w, h)
        gears.shape[sh](cr, w, h, r)
    end
end
-- =========================================================>
--> Returns an awful placement (pc)
--> function with arguments (args):
-- =========================================================>
-->> Complete syntactic sugar utility function :<
-- =========================================================>
function this.placement(pc, args)
    return function(d)
        awful.placement[pc](d, args)
    end
end
-- =========================================================>
--> Returns a margins table for the values top-bottom (v)
--> and right-left (h) adjusted to the screen's (s) dpi:
-- =========================================================>
-->> Complete syntactic sugar utility function :<
-- =========================================================>
function this.margins(v, h, s)
    v, h = dpi(v, s), dpi(h, s)
    return {top = v, right = h, bottom = v, left = h}
end
-- =========================================================>
--> Standard beautiful apply_dpi function that also accepts
--> tables with numeric-value entries to which applies dpi:
-- =========================================================>
-->> Complete syntactic sugar utility function :<
-- =========================================================>
function this.dpi(o, s)
    if (o) then
        --> If table loop and apply_dpi for each entry
        if (type(o) == "table") then
            for i=1,(#o) do
                o[i] = dpi(o[i], s)
            end
            return o
        end
        --> If not table apply_dpi in standard way
        return dpi(o, s) --> Proper tail call
    end
end
-- =========================================================>
--> Returns the index (ix) from the table (t) if it
--> is a table, else it returns it without any changes:
-- =========================================================>
-->> Complete syntactic sugar utility function :<
-- =========================================================>
function this.index(t, ix, f)
    if (type(t) == "table") then
        return t[ix] or f
    end
    return t or f
end
-- =========================================================>
--> Chooses option (o1, o2) depending on the condition (c):
-- =========================================================>
-->> Complete syntactic sugar utility function :<
-- =========================================================>
function this.choose(c, o1, o2)
    if (c) then
        return o1() --> Proper tail call
    end
    return o2() --> Proper tail call
end
-- =========================================================>
--> Chooses option (o1, o2) depending on the condition (c):
-- =========================================================>
-->> Complete syntactic sugar utility function :<
-- =========================================================>
function this.enabled(c, o)
    return this.choose(c, function() return o end, this.empty)
end
-- =========================================================>
--> Returns a function that sets object's
--> (o) key (k) to its argument's (v) value:
-- =========================================================>
-->> Complete memory-union utility function :>
-- =========================================================>
function this.set_key(o, k)
    return function(v)
        o[k] = v
    end
end
-- =========================================================>
--> Returns the argument (v) value:
-- =========================================================>
-->> Complete memory-union utility function :>
-- =========================================================>
function this.refund(v)
    return v
end
-- =========================================================>
--> Empty function:
-- =========================================================>
-->> Complete memory-union utility function :>
-- =========================================================>
function this.empty() end
-- =========================================================>
return this
