-- =========================================================>
--  [Todo] Toggles:
-- =========================================================>
--
-- =========================================================>
-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          TOGGLES
-- =========================================================>
----> Awesome window manager raven toggles:
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
-- =========================================================>
--  [Imports] Helpers:
-- =========================================================>
local sfx = require("helpers.sfx")
local text = require("helpers.text")
local chrono = require("helpers.chrono")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local ipairs = ipairs
local ceil = math.ceil
local find = string.find
local tostring = tostring
local tonumber = tonumber
local insert = table.insert
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {updates = {}}
-- =========================================================>
--  [Functions] Toggles:
-- =========================================================>
function this:make_toggle(functions, icon)
    local graphic = wibox.widget({
        resize = true,
        --halign = "center",
        forced_width = dpi(35),
        forced_height = dpi(35),
        scaling_quality = "best",
        image = gears.color.recolor_image(icon, gears.color.change_opacity(beautiful.color.accent, 0.9)),
        widget = wibox.widget.imagebox,
        toggle = function(self, v) self.image = gears.color.recolor_image(icon, v and beautiful.color.widget2 or  gears.color.change_opacity(beautiful.color.accent, 0.9)) end
    })

    local toggle = sfx.hover(
        wibox.widget({
            {
                {
                    graphic,
                    widget = wibox.container.place
                },
                margins = dpi(5),
                widget = wibox.container.margin
            },
            forced_width = dpi(70),
            forced_height = dpi(70),
            shape = gears.shape.circle,
            bg = beautiful.color.widget,
            shape_border_width = dpi(2),
            shape_border_color = beautiful.color.border,
            widget = wibox.container.background,
            toggle = function(self, t)
                functions.toggle()
                self.enabled = not self.enabled
                self:update_st()
            end,
            update_st = function(self)
                self.bg = self.enabled and gears.color.change_opacity(beautiful.color.accent, 0.9) or beautiful.color.widget
                graphic:toggle(self.enabled)
            end
        }), {opacity = 0.8, cursor = beautiful.cursor.button}
    ) toggle:add_button(awful.button({}, 1, function() toggle:toggle() end))
    insert(self.updates, function() functions.get(toggle) end)
    return toggle
end

function this:make()
    local sliders = wibox.widget({
        self:make_toggle({
            get = function(o)
                o.enabled = naughty.suspended
                o:update_st()
            end,
            toggle = function()
                --local c = naughty.expiration_paused REVISE
                naughty.suspended = not naughty.suspended

            end
        }, beautiful.icon.image..dnd),
        self:make_toggle({
            get = function(o)
                awful.spawn.easy_async_with_shell([[
                    if [ ! -z $(pgrep redshift) ]; then
                        echo '[off]'
                    else
                        echo '[on]'
                    fi
                ]], function(out)
                    o.enabled = (find(out, "%[on%]") or not find(out, "%[off%]"))
                    --print( (find(out, "%[on%]") or not find(out, "%[off%]")))
                    o:update_st()
                end)
            end,
            toggle = function()


                awful.spawn([[
                    if [ ! -z $(pgrep redshift) ]; then
                        redshift -x
                        pkill redshift
                        killall redshift
                    else
                        redshift -c ]] .. gears.filesystem.get_configuration_dir() .. [[config/redshift.conf &>/dev/null &
                    fi
                ]], false)

            end
        }, beautiful.icon.image.redlight),
        homogeneous = true,
        forced_num_cols = 4,
        horizontal_expand = true,
        vertical_spacing = dpi(20),
        horizontal_spacing = dpi(20),
        layout = wibox.layout.grid
    }) chrono.set_interval(function() for _,update in ipairs(self.updates) do update() end end, 1)
    return sliders
end

return this
