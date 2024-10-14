-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          COLOR
-- =========================================================>
----> AwesomeWM Color Utils
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local gears = require("gears")
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local mysc = require("util.mysc")
local table = require("util.table")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local type = type
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Functions] Color:
-- =========================================================>
--> Ensures the color (c) is a pango color:
-- =========================================================>
function this.is_color(c)
    return gears.color.ensure_pango_color(c, "NaC") ~= "NaC"
end
-- =========================================================>
--> Ensures the color (c) is in the rgba color format:
-- =========================================================>
function this.as_rgba(c)
    return gears.color.parse_color(
        gears.color.to_rgba_string(c)
    ) --> Proper tail call
end
-- =========================================================>
--> Gets the opacity of the color (c):
-- =========================================================>
function this.get_opacity(c)
    if (not this.is_color(c)) then return c end
    --> the 4th element is opacity (r, g, b, a)
    local _, _, _, o = this.as_rgba(c)
    return o
end
-- =========================================================>
--> Returns the color (c) as a solid or a gradient color:
-- =========================================================>
function this.solid_gradient(c, a, o)
    --> If color is a gradient its type is table
    if (type(c) == "table") then
        local stops = {}
        --> Gradients come as arrays of {stop, color}
        for i=1,#c do
            --> Colors can be dynamic values
            stops[i] = {
                c[i][1],
                gears.color.to_rgba_string( --> must be in string and changin opacity returns surface
                    gears.color.change_opacity(
                        table.get_dynamic(c[i][2]),
                        o or 1
                    )
                )
            }
        end
        return gears.table.crush(a, {stops = stops}) --> Proper tail call
    end
    return gears.color.change_opacity(
        table.get_dynamic(c),
        o or 1
    ) --> Proper tail call
end
-- =========================================================>
--> Memoize variant of gears.color.recolor_image:
-- =========================================================>
this.image = mysc.memoize(gears.color.recolor_image)
-- =========================================================>
return this
