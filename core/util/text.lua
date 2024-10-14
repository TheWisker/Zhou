-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          TEXT
-- =========================================================>
----> AwesomeWM Text Utils
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local require = require
-- =========================================================>
local table = require("util.table")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local upper = string.upper
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Functions] Text:
-- =========================================================>
function this.clean(s)
    s = (s or "")
    --> Strangely although '*' and '-' are
    --> equivalent in lua pattern-matching this
    --> does not work if '-' is substituted by a '*'.
    return s:gsub("^%s*(.-)%s*$", "%1") --> Proper tail call
end
-- =========================================================>
function this.bold(s)
    return "<b>" .. (s or "") .. "</b>"
end
-- =========================================================>
function this.italic(s)
    return "<i>" .. (s or "") .. "</i>"
end
-- =========================================================>
function this.color(s, c)
    return "<span foreground='" .. table.get_dynamic(c) .. "'>" .. (s or "") .. "</span>"
end
-- =========================================================>
--> Capitalizes the string (s) with (p) or
--> without (¬p) pango markup and returns it:
-- =========================================================>
function this.capitalize(s, p)
    s = (s or "")
    if (p) then
        return "<span text_transform='capitalize'>" .. s .. "</span>"
    end
    return s:gsub("^%l", upper):gsub("%s+%l", upper) --> Proper tail call
end
-- =========================================================>
return this
