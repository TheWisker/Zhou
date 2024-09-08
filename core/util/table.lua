--- Utils for working with tables and metatables
-- @module table

local require = require
local gears = require("gears")

local next = next
local setmetatable = setmetatable
local getmetatable = getmetatable


local mysc = require("util.mysc")

local floor = math.floor

local this = {


}

this.meta = {
    fallback = {
        __call = function(table, s)
            return ((s and s.index and table[s.index]) or table.default)
        end
    },
    crushback = {
        __call = function(table, s)
            return this.crush(
                table,
                this.crush(
                    this.crush({}, table.default),
                    (s and s.index and table[s.index]) or mysc.null
                )
            )--> Proper tail call
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

--> Negative values for depth work like infinite depth, 0 value for depth makes the function return
function this.crush(t, tt, depth)
    depth = (depth or -1)

    if (depth == 0) then
        return t
    end

    for kk,vv in next, tt do
        if (type(vv) == "table" and type(t[kk]) == "table") then
            this.crush(t[kk], vv, (depth - 1))
        else
            t[kk] = vv
        end
    end

    return t
end


--- Sets the <b>__call</b> metamethod for <b>t</b> to work as a fallback.
-- When calling t with an awesome screen object as parameter
-- it will return its entry which key matches the screen's index,
-- if any and not false, or the entry with the 'default' key.
-- @tparam table t table to attach metamethod to
-- @treturn table passed table with metamethod attached
-- @see crushback
-- @function fallback
function this.fallback(t)
    return setmetatable(
        t,
        this.meta.fallback
    ) --> Proper tail call
end


function this.wallback(t)
    return setmetatable(
        t,
        this.meta.fallback
    ) --> Proper tail call
end

--- Sets the <b>__call</b> metamethod for a table to work as a crushback.
-- When calling the table with an awesome screen object as parameter
-- it will return the entry of the table whichs key matches the screen's index
-- crushed to the entry with the 'default' key. If the first entry is false or nil
-- it will only return the 'default' entry.
-- @tparam table t table to attach metamethod to
-- @treturn table passed table with metamethod attached
-- @see fallback
-- @function crushback
function this.crushback(t)
    return setmetatable(
        t,
        this.meta.crushback
    ) --> Proper tail call
end


function this.fontback(t)
    return setmetatable(
        t,
        this.meta.fontback
    ) --> Proper tail call
end

--- Tags a table by setting its <b>__metatable</b> metatable property.
-- Sets the '__metatable' metatable property for t to id as to allow
-- this table to be recognized.
-- @tparam table t table to tag
-- @param id id to tag with
-- @return the passed table tagged or nil if it already had a metatable
-- @see is
-- @function tag
function this.tag(t, id)
    --> This does not override t's metatable
    if (not getmetatable(t)) then
        --> Id will be returned with getmetatable
        return setmetatable(t, {__metatable = id}) --> Proper tail call
    end
end

--- Sets the <b>__call</b> metamethod for a table to work as a crushback.
-- When calling the table with an awesome screen object as parameter
-- it will return the entry of the table whichs key matches the screen's index
-- crushed to the entry with the 'default' key. If the first entry is false or nil
-- it will only return the 'default' entry.
-- @tparam table t table to attach metamethod to
-- @treturn table passed table with metamethod attached
-- @see tag
-- @function is
function this.is(t, id)
    return (getmetatable(t) == id)
end


--- Creates a dynamic pointer to a key of a table to dynamically access it.
-- Allows to access a table key in a dynamic way, by creating a
-- table, tagged as "dynamic" and containing a 'table' and an 'key' entry,
-- which when passed to this function's counterpart get_dynamic returns the
-- current value of the table's key.
-- @tparam table t table which contains the key to point to
-- @param ix key to point to
-- @treturn table tagged table containing the pointer data
-- @see get_dynamic
-- @see tag
-- @function set_dynamic
function this.set_dynamic(t, ix)
    return this.tag(
        {
            table = t,
            key = ix
        }, "dynamic"
    ) --> Proper tail call
end


--- Dynamically accesses the key of a table trough a dynamic pointer.
-- Allows to access a table key in a dynamic way, by passing a
-- table, created by this function's counterpart set_dynamic,
-- tagged as "dynamic" and containing a 'table' and an 'key' entry.
-- @tparam table t tagged table containing the dynamic pointer data
-- @return dynamically accessed value
-- @see set_dynamic
-- @see tag
-- @function get_dynamic
function this.get_dynamic(t)
    if this.is(t, "dynamic") then
        return this.get_dynamic(t.table[t.key]) --> Proper tail call
    end
    return t
end


--- Creates a table with dynamic pointers to every key of another table.
-- The created table has the same keys as the passed table that contain
-- dynamic pointers to their respective passed table's keys.
-- @tparam table t table which keys to point to
-- @treturn table table containing all dynamic pointers to the passed table
-- @see set_dynamic
-- @see get_dynamic
-- @function dynamic
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

return this
