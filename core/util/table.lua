-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          TABLE
-- =========================================================>
----> AwesomeWM Table Utils
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local gears = require("gears")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
local floor = math.floor
local setmetatable = setmetatable
local getmetatable = getmetatable
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Variables] Table:
-- =========================================================>
-->  Metamethods for xback metatables:
-- =========================================================>
this.meta = {
    fallback = {
        __call = function(table, s)
            return ((s and s.index and table[s.index]) or table.default)
        end
    },
    fontback = {
        -->> Call to build a font description
        __call = function(self, s, m)
            s = self.sizes[s] or s
            if m then m = " " .. m ..  " " else m = " " end
            --m = " " .. (m or " ") .. " "
            return self.name .. m .. floor(s)
        end
    }
}
-- =========================================================>
--  [Functions] Table:
-- =========================================================>
--> Sets fallback metamethod for table (t):
-- =========================================================>
function this.fallback(t)
    return setmetatable(
        t,
        this.meta.fallback
    ) --> Proper tail call
end
-- =========================================================>
--> Sets fontback metamethod for table (t):
-- =========================================================>
function this.fontback(t)
    return setmetatable(
        t,
        this.meta.fontback
    ) --> Proper tail call
end
-- =========================================================>
--> Tags table (t) with (id):
-- =========================================================>
function this.tag(t, id)
    --> This does not override t's metatable
    if (not getmetatable(t)) then
        --> Id will be returned with getmetatable
        return setmetatable(t, {__metatable = id}) --> Proper tail call
    end
end
-- =========================================================>
--> Checks if table (t) has tag (id):
-- =========================================================>
function this.is(t, id)
    return (getmetatable(t) == id)
end
-- =========================================================>
--> Creates dynamic pointer to table's (t) index (ix):
-- =========================================================>
function this.set_dynamic(t, ix)
    return this.tag(
        {
            table = t,
            key = ix
        }, "dynamic"
    ) --> Proper tail call
end
-- =========================================================>
--> Accesses dynamic pointer (t) to table:
-- =========================================================>
function this.get_dynamic(t)
    if (this.is(t, "dynamic")) then
        return this.get_dynamic(t.table[t.key]) --> Proper tail call
    end
    return t
end
-- =========================================================>
--> Returns table of dynamic pointer to every index of (t):
-- =========================================================>
function this.dynamic(t)
    -->> Create dynamic table
    local dynamic = {}
    -->> Set dynamic entries pointing to t
    for key,_ in next, t do
        dynamic[key] = this.set_dynamic(t, key)
    end
    -->> Return dynamic table
    return setmetatable(
        dynamic,
        {
            --> Object identifier
            __metatable = "dynamic_table",
            --> Modification gate
            __call = function(_, o)
                return gears.table.crush(t, o) --> Proper tail call
            end
        }
    ) --> Proper tail call
end
-- =========================================================>
return this
