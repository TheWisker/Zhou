-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                      THEME DEFAULTS
-- =========================================================>
---> AwesomeWM Theme Defaults
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
-- =========================================================>
--  [Imports] Signal:
-- =========================================================>
local signal = require("module.signal")
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local mysc = require("util.mysc")
local text = require("util.text")
local color = require("util.color")
local table = require("util.table")
-- =========================================================>
--  [Imports] Libraries:
-- =========================================================>
local rubato = require("lib.rubato")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
local floor = math.floor
local loadfile = loadfile
-- =========================================================>
--  [Definitions] Paths:
-- =========================================================>
local conf_path = gears.filesystem.get_configuration_dir()
local icon_path = conf_path .. "assets/icons/"
local symlink_path = conf_path .. "assets/symlinks/"
local wallpaper_path = conf_path .. "assets/wallpapers/"
-- =========================================================>
--  [Table] Theme:
-- =========================================================>
local theme = {}
-- =========================================================>
--  [Theme] Functions:
-- =========================================================>
--> Refreshes the current theme's dynamic colors according
--> to the symlinked 'colors.lua' file in 'symlink_path':
-- =========================================================>
function theme:colors_refresh(s)
    -->> Use of dynamic table modification gate
    return self.color(s).dynamic(
        signal.notification.assert(
            --> Uses loadfile to ensure the file gets loaded from scratch
            loadfile(symlink_path .. "colors.lua")
        )() --> Call the returned function to load the file
    ) --> Proper tail call
end
-- =========================================================>
--  [Theme] Behaviour:
-- =========================================================>
--> Define specific apps for each category:
-- =========================================================>
theme.exec = {
    app = {
        terminal = "kitty",
        browser = "firefox",
        filemanager = "dolphin",
        screenshot = "flameshot",
        launcher = "rofi -modes drun,window,filebrowser,run -show drun"
    },
    pywall = "",
    compositor = {
        on = "picom --daemon",
        off = "pkill picom"
    },
    session = {
        lock = "light-locker",
        sleep = "systemctl sleep",
        restart = "systemctl reboot",
        suspend = "systemctl suspend",
        shutdown = "systemctl poweroff",
        hibernate = "systemctl hibernate"
    }
}
-- =========================================================>
--> Define global layout list and names:
-- =========================================================>
theme.layout = {
    list = {
        awful.layout.suit.floating,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        --awful.layout.suit.spiral,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.max,
        awful.layout.suit.magnifier,
        --awful.layout.suit.max.fullscreen,
        awful.layout.suit.tile.top,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.right,
        awful.layout.suit.corner.se,
        awful.layout.suit.corner.sw,
        awful.layout.suit.corner.ne,
        awful.layout.suit.corner.nw
    },
    --> List of names for layoutbox
    name = {
        floating = "Floating",
        fairv = "Fair Vertical",
        fairh = "Fair Horizontal",
        spiral = "Spiral Inwards",
        dwindle = "Spiral Outwards",
        max = "Max",
        magnifier = "Magnifier",
        fullscreen = "Fullscreen",
        tiletop = "Tiletop",
        tilebottom = "Tile Bottom",
        tileleft = "Tile Left",
        tile = "Tile Right",
        cornerse = "Corner Southeast",
        cornersw = "Corner Southwest",
        cornerne = "Corner Northeast",
        cornernw = "Corner Northwest"
    }
}
-- =========================================================>
--> Define tags for each screen with default fallback:
-- =========================================================>
-->> Uses screen-specific with default fallback precedence
-- =========================================================>
theme.tag = {
    default = {
        {
            gap = 20,
            index = 1,
            name = "Core",
            selected = true,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        }
    },
    {
       {
            gap = 20,
            index = 1,
            name = "Alpha",
            selected = true,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        },
        {
            gap = 15,
            index = 2,
            name = "Beta",
            selected = false,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        },
        {
            gap = 15,
            index = 3,
            name = "Gamma",
            selected = false,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        },
        {
            gap = 15,
            index = 3,
            name = "Delta",
            selected = false,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        },
        {
            gap = 15,
            index = 3,
            name = "Epsilon",
            selected = false,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        }
    },
    {
       {
            gap = 20,
            index = 1,
            name = "Alpha",
            selected = true,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        },
        {
            gap = 15,
            index = 2,
            name = "Beta",
            selected = false,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        },
        {
            gap = 15,
            index = 3,
            name = "Gamma",
            selected = false,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        },
        {
            gap = 15,
            index = 3,
            name = "Delta",
            selected = false,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        },
        {
            gap = 15,
            index = 3,
            name = "Epsilon",
            selected = false,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        }
    }
}
-- =========================================================>
--  [Theme] Style:
-- =========================================================>
--> Define icon theme for Awesome:
-- =========================================================>
theme.icon_theme = "Amy-Dark-Icons"
-- =========================================================>
--> Define some styling parameters:
-- =========================================================>
theme.maximized_hide_border = true
theme.fullscreen_hide_border = true
theme.maximized_honor_padding = true
-- =========================================================>
--> Define screen spacing for widgets:
-- =========================================================>
theme.spacing = 20
-- =========================================================>
--> Define font's names and sizes for each function:
-- =========================================================>
theme.fonts = {
    -->> Font used in all text
    main = {
        name = "Aesthetic Iosevka Original",
        sizes = {
            XXS = 8,
            XS = 10,
            S = 12,
            M = 14,
            L = 16,
            XL = 18,
            XXL = 20
        }
    },
    -->> Font used in text icons
    icon = {
        name = "Material Icons",
        sizes = {
            XXS = 8,
            XS = 10,
            S = 12,
            M = 14,
            L = 16,
            XL = 18,
            XXL = 20
        }
    }
}
-- =========================================================>
--> Define static and dynamic colors for the theme:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.color = {
    default = {
        --> These colors get changed dynamically with pywall
        dynamic = table.dynamic({
            cursor = "#E3CCE6",
            color0 = "#0C0719",
            color1 = "#6D55D2",
            color2 = "#A016A5",
            color3 = "#D132CB",
            color4 = "#9763E5",
            color5 = "#4BBBE3",
            color6 = "#A39AF0",
            color7 = "#E3CCE6",
            color8 = "#9E8EA1",
            color9 = "#6D55D2",
            color10 = "#A016A5",
            color11 = "#D132CB",
            color12 = "#9763E5",
            color13 = "#4BBBE3",
            color14 = "#A39AF0",
            color15 = "#E3CCE6",
            foreground = "#E3CCE6",
            background = "#0C0719"
        }),
        --> These colors never change
        static = {
            hover = "#333739CC",
            click = "#3F4345CC",
            widget = "#272A2B99",
            transparent = "#00000000"
        }
    },
    {
        --> These colors get changed dynamically with pywall
        dynamic = table.dynamic({
            cursor = "#E3CCE6",
            color0 = "#0C0719",
            color1 = "#6D55D2",
            color2 = "#A016A5",
            color3 = "#D132CB",
            color4 = "#9763E5",
            color5 = "#4BBBE3",
            color6 = "#A39AF0",
            color7 = "#E3CCE6",
            color8 = "#9E8EA1",
            color9 = "#6D55D2",
            color10 = "#A016A5",
            color11 = "#D132CB",
            color12 = "#9763E5",
            color13 = "#4BBBE3",
            color14 = "#A39AF0",
            color15 = "#E3CCE6",
            foreground = "#E3CCE6",
            background = "#0C0719"
        }),
        --> These colors never change
        static = {
            hover = "#333739CC",
            click = "#3F4345CC",
            widget = "#272A2B99",
            transparent = "#00000000"
        }
    },
    {
        --> These colors get changed dynamically with pywall
        dynamic = table.dynamic({
            cursor = "#E3CCE6",
            color0 = "#0C0719",
            color1 = "#6D55D2",
            color2 = "#A016A5",
            color3 = "#D132CB",
            color4 = "#9763E5",
            color5 = "#4BBBE3",
            color6 = "#A39AF0",
            color7 = "#E3CCE6",
            color8 = "#9E8EA1",
            color9 = "#6D55D2",
            color10 = "#A016A5",
            color11 = "#D132CB",
            color12 = "#9763E5",
            color13 = "#4BBBE3",
            color14 = "#A39AF0",
            color15 = "#E3CCE6",
            foreground = "#E3CCE6",
            background = "#0C0719"
        }),
        --> These colors never change
        static = {
            hover = "#333739CC",
            click = "#3F4345CC",
            widget = "#272A2B99",
            transparent = "#00000000"
        }
    }
}
-- =========================================================>
--> Define animation properties, animated events and fps:
-- =========================================================>
theme.animation = {
    fps = 60,
    --> Bit of technical event configuration for util.sfx
    event = {
        hover = {
            duration = 0.35, -- Seconds
            easing = rubato.quadratic,
            trigger = {
                on = "mouse::enter",
                off = "mouse::leave"
            },
            properties = {
                enabled = {
                    bg = true,
                    opacity = true,
                    forced_width = true,
                    forced_height = true
                },
                value = {
                    bg = function(value)
                        return color.get_opacity(value)
                    end,
                    opacity = mysc.refund,
                    forced_width = mysc.refund,
                    forced_height = mysc.refund
                },
                subscribed = {
                    bg = function(w, _, value)
                        return function(pos)
                            w.bg = gears.color.change_opacity(
                                table.get_dynamic(value),
                                pos
                            )
                        end
                    end,
                    opacity = mysc.set_key,
                    forced_width = mysc.set_key,
                    forced_height = mysc.set_key
                }
            }
        },
        press = {
            duration = 0.2, -- Seconds
            easing = rubato.quadratic,
            trigger = {
                on = "button::press",
                off = "button::release"
            },
            properties = {
                enabled = {
                    forced_width = true,
                    forced_height = true
                },
                value = {
                    forced_width = mysc.refund,
                    forced_height = mysc.refund
                },
                subscribed = {
                    forced_width = mysc.set_key,
                    forced_height = mysc.set_key
                }
            }
        }
    },
    widget = {
        --> Wheter to enable animations that picom can do for us better
        enable = false,
        raven = {
            duration = 1/3.5, -- Seconds
            easing = rubato.quadratic
        },
        terminal = {
            duration = 1/2, -- Seconds
            easing = rubato.bouncy
        },
        systray = {
            duration = 1/2, -- Seconds
            easing = rubato.bouncy
        },
        taglist = {
            duration = 1/4, -- Seconds
            easing = rubato.bouncy
        },
        shadow = {
            duration = 1/3.5, -- Seconds
            easing = rubato.quadratic
        },
        clock = {
            duration = 1/2, -- Seconds
            easing = rubato.quadratic
        },
        layoutbox = {
            duration = 1/2, -- Seconds
            easing = rubato.quadratic
        },
        notification = {
            duration = 1/2, -- Seconds
            easing = rubato.zero
        }
    }
}
-- =========================================================>
--> Define icon paths for every icon concept:
-- =========================================================>
theme.icon = {
    --> Text character icons
    text = {
        --> Close icon
        close = "",
        --> Application icons
        apps = {
            firefox = "",
            discord = "",
            music = "",
            screenshot_tool = "",
            color_picker = ""
        },
        --> Exit icons
        exit = {
            exit = "",
            lock = "",
            sleep = "",
            restart = "",
            suspend = "",
            shutdown = "",
            hibernate = ""
        }
    },
    --> Image file icons
    image = {
        --> Awesome icon
        awesome = icon_path .. "awesome.svg",
        --> Raven icon
        raven = icon_path .. "widgets/raven.svg",
        --> Do not disturb icon
        dnd = icon_path .. "do_not_disturb.svg",
        --> Redlight icon
        redlight = icon_path .. "redlight.svg",
        --> Arrow icons
        arrow = {
            top = icon_path .. "arrow/top.svg",
            right = icon_path .. "arrow/right.svg",
            bottom = icon_path .. "arrow/bottom.svg",
            left = icon_path .. "arrow/left.svg"
        },
        --> Dart icons
        dart = {
            top = icon_path .. "dart/top.svg",
            right = icon_path .. "dart/right.svg",
            bottom = icon_path .. "dart/bottom.svg",
            left = icon_path .. "dart/left.svg"
        },
        --> Volume icons
        volume = {
            low = icon_path .. "volume/volume_low.svg",
            off = icon_path .. "volume/volume_mute.svg",
            high = icon_path .. "volume/volume_high.svg",
            error = icon_path .. "volume/volume_off.svg"
        },
        --> Brightness icons
        brightness = {
            low = icon_path .. "brightness/brightness_low.svg",
            off = icon_path .. "brightness/brightness_low.svg",
            high = icon_path .. "brightness/brightness_high.svg",
            error = icon_path .. "brightness/brightness_low.svg"
        },
        --> Layout icons
        layout = {
            fairh = icon_path .. "layouts/fair/horizontal.svg",
            fairv = icon_path .. "layouts/fair/vertical.svg",
            floating  = icon_path .. "layouts/floating.svg",
            magnifier = icon_path .. "layouts/center/magnifier.svg",
            max = icon_path .. "layouts/center/max.svg",
            fullscreen = icon_path .. "layouts/center/fullscreen.svg",
            tilebottom = icon_path .. "layouts/tile/bottom.svg",
            tileleft   = icon_path .. "layouts/tile/left.svg",
            tile = icon_path .. "layouts/tile/right.svg",
            tiletop = icon_path .. "layouts/tile/top.svg",
            spiral  = icon_path .. "layouts/spiral/inwards.svg",
            dwindle = icon_path .. "layouts/spiral/outwards.svg",
            cornernw = icon_path .. "layouts/corner/northwest.svg",
            cornerne = icon_path .. "layouts/corner/northeast.svg",
            cornersw = icon_path .. "layouts/corner/southwest.svg",
            cornerse = icon_path .. "layouts/corner/southeast.svg"
        }
    }
}
-- =========================================================>
--  [Theme] Objects:
-- =========================================================>
--> Client styling
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.client = {
    --> (Global) Autofocus
    autofocus = true,
    --> Default properties
    default = {
        --> Shape of the client
        shape = mysc.shape("rounded_rect", 20),
        --> Snap properties
        snap = {
            gap = 15,
            thickness = 8,
            shape = mysc.shape("rounded_rect", 20),
            color = theme.color.default.dynamic.color1
        },
        --> Border properties
        border = {
            thickness = 4,
            color = {
                urgent = theme.color.default.dynamic.color2,
                focused = theme.color.default.dynamic.color1,
                floating = theme.color.default.dynamic.color3,
                normal = theme.color.default.dynamic.background
            }
        }
    },
    --> Screen 1
    {
        --> Shape of the client
        shape = mysc.shape("rounded_rect", 20),
        --> Snap properties
        snap = {
            gap = 15,
            thickness = 8,
            shape = mysc.shape("rounded_rect", 20),
            color = theme.color[1].dynamic.color1
        },
        --> Border properties
        border = {
            thickness = 4,
            color = {
                urgent = theme.color[1].dynamic.color2,
                focused = theme.color[1].dynamic.color1,
                floating = theme.color[1].dynamic.color3,
                normal = theme.color[1].dynamic.background
            }
        }
    },
    --> Screen 2
    {
        --> Shape of the client
        shape = mysc.shape("rounded_rect", 20),
        --> Snap properties
        snap = {
            gap = 15,
            thickness = 8,
            shape = mysc.shape("rounded_rect", 20),
            color = theme.color[2].dynamic.color1
        },
        --> Border properties
        border = {
            thickness = 4,
            color = {
                urgent = theme.color[2].dynamic.color2,
                focused = theme.color[2].dynamic.color1,
                floating = theme.color[2].dynamic.color3,
                normal = theme.color[2].dynamic.background
            }
        }
    }
}
-- =========================================================>
--  [Theme] Widgets:
-- =========================================================>
--> Define general and style-specific notification props:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.notification = {
    default = {
        radius = 12,
        opacity = 0.8,
        cursor = "cross",
        position = "top_right",
        background = theme.color.default.dynamic.background,
        size = {
            width = 350,
            height = 200
        },
        icon = {
            size = 45,
            hollow = false,
            thickness = 4,
            shape = gears.shape.circle,
            foreground = theme.color.default.dynamic.foreground
        },
        arcbar = {
            size = 32,
            opacity = 0.8,
            thickness = 5,
            icon = {
                font_size = "XS",
                foreground = theme.color.default.dynamic.foreground
            }
        },
        actions = {
            radius = 5,
            font_size = "S",
            foreground = theme.color.default.dynamic.foreground,
            size = {
                width = 70,
                height = 38
            },
            space = {
                spacing = 4,
                margins = mysc.margins(0, 12)
            }
        },
        text = {
            app = {
                font_size = "S",
                foreground = theme.color.default.dynamic.foreground
            },
            title = {
                font_size = "S",
                foreground = theme.color.default.dynamic.foreground
            },
            message = {
                font_size = "S",
                foreground = theme.color.default.dynamic.foreground
            },
            scroll = {
                fps = 60,
                speed = 75,
                step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth
            }
        },
        style = {
            default = {
                bg = {
                    {0, theme.color.default.dynamic.color1},
                    {0.25, theme.color.default.dynamic.color4},
                    {0.75, theme.color.default.dynamic.color3},
                    {1, theme.color.default.dynamic.color2}
                }
            },
            error = {
                timeout = 0,
                resident = false,
                urgency = "critical",
                category = "awesome.event.error",
            }
        }
    },
    {
        radius = 12,
        opacity = 0.8,
        cursor = "cross",
        position = "top_right",
        background = theme.color[1].dynamic.background,
        size = {
            width = 350,
            height = 200
        },
        icon = {
            size = 45,
            hollow = false,
            thickness = 4,
            shape = gears.shape.circle,
            foreground = theme.color[1].dynamic.foreground
        },
        arcbar = {
            size = 32,
            opacity = 0.8,
            thickness = 5,
            icon = {
                font_size = "XS",
                foreground = theme.color[1].dynamic.foreground
            }
        },
        actions = {
            radius = 5,
            font_size = "S",
            foreground = theme.color[1].dynamic.foreground,
            size = {
                width = 70,
                height = 38
            },
            space = {
                spacing = 4,
                margins = mysc.margins(0, 12)
            }
        },
        text = {
            app = {
                font_size = "S",
                foreground = theme.color[1].dynamic.foreground
            },
            title = {
                font_size = "S",
                foreground = theme.color[1].dynamic.foreground
            },
            message = {
                font_size = "S",
                foreground = theme.color[1].dynamic.foreground
            },
            scroll = {
                fps = 60,
                speed = 75,
                step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth
            }
        },
        style = {
            default = {
                bg = {
                    {0, theme.color[1].dynamic.color1},
                    {0.25, theme.color[1].dynamic.color4},
                    {0.75, theme.color[1].dynamic.color3},
                    {1, theme.color[1].dynamic.color2}
                }
            },
            error = {
                timeout = 0,
                resident = false,
                urgency = "critical",
                category = "awesome.event.error",
            }
        }
    },
    {
        radius = 12,
        opacity = 0.8,
        cursor = "cross",
        position = "top_right",
        background = theme.color[2].dynamic.background,
        size = {
            width = 350,
            height = 200
        },
        icon = {
            size = 45,
            hollow = false,
            thickness = 4,
            shape = gears.shape.circle,
            foreground = theme.color[2].dynamic.foreground
        },
        arcbar = {
            size = 32,
            opacity = 0.8,
            thickness = 5,
            icon = {
                font_size = "XS",
                foreground = theme.color[2].dynamic.foreground
            }
        },
        actions = {
            radius = 5,
            font_size = "S",
            foreground = theme.color[2].dynamic.foreground,
            size = {
                width = 70,
                height = 38
            },
            space = {
                spacing = 4,
                margins = mysc.margins(0, 12)
            }
        },
        text = {
            app = {
                font_size = "S",
                foreground = theme.color[2].dynamic.foreground
            },
            title = {
                font_size = "S",
                foreground = theme.color[2].dynamic.foreground
            },
            message = {
                font_size = "S",
                foreground = theme.color[2].dynamic.foreground
            },
            scroll = {
                fps = 60,
                speed = 75,
                step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth
            }
        },
        style = {
            default = {
                bg = {
                    {0, theme.color[2].dynamic.color1},
                    {0.25, theme.color[2].dynamic.color4},
                    {0.75, theme.color[2].dynamic.color3},
                    {1, theme.color[2].dynamic.color2}
                }
            },
            error = {
                timeout = 0,
                resident = false,
                urgency = "critical",
                category = "awesome.event.error",
            }
        }
    }
}
-- =========================================================>
--> Define desktop session screen popup properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.session = {
    default = {
        opacity = 0.8,
        buttons = {
            size = 60,
            thickness = 8,
            font_size = "L",
            shape = gears.shape.circle,
            colors = {
                fg = theme.color.default.dynamic.foreground,
                bg = theme.color.default.static.widget,
                fga = theme.color.default.dynamic.foreground,
                bga = nil
            },
            background = theme.color.default.static.widget
        },
        color = {
            background = theme.color.default.dynamic.background
        }
    } -- make 2 more screens
}
-- =========================================================>
--> Define desktop taskbar widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.taskbar = {
    default = {
        height = 25, --> Height of the taskbar (pixels)
        spacing = 5, --> Spacing between taskbar widgets (pixels)
        padding = 6, --> Internal taskbar padding that adds to the height (pixels)
        margins = 0, --> External taskbar margins (pixels)
        opacity = 0.8, --> Opacity of the taskbar and its background (int: [0 -> 1])
        enabled = true,
        visible = true,
        stretch = true,-- false works strange
        --> top or bottom
        position = "bottom",
        shape = gears.shape.rectangle,
        awesome = {
            radius = 5,
            opacity = 0.6,
            enabled = true,
            margins = mysc.margins(5, 0)
        },
        color = {
            awesome = theme.color.default.dynamic.color1,
            background = theme.color.default.dynamic.background
        }
    },
    {
        height = 25, --> Height of the taskbar (pixels)
        spacing = 5, --> Spacing between taskbar widgets (pixels)
        padding = 6, --> Internal taskbar padding that adds to the height (pixels)
        margins = 0, --> External taskbar margins (pixels)
        opacity = 0.8, --> Opacity of the taskbar and its background (int: [0 -> 1])
        enabled = true,
        visible = true,
        stretch = true,-- false works strange
        --> top or bottom
        position = "bottom",
        shape = gears.shape.rectangle,
        awesome = {
            radius = 5,
            opacity = 0.6,
            enabled = true,
            margins = mysc.margins(5, 0)
        },
        color = {
            awesome = theme.color[1].dynamic.color1,
            background = theme.color[2].dynamic.background
        }
    }
}
-- =========================================================>
--> Define desktop taskbar raven sidebar widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.raven = {
    default = {
        width = 300,
        radius = 25,
        timeout = 4,
        opacity = 0.8,
        enabled = true,
        visible = true,
        title = {
            font_size = 45,
            color = theme.color.default.dynamic.foreground
        },
        color = {
            evoker = theme.color.default.dynamic.color1,
            background = theme.color.default.dynamic.background
        }
    }
}
-- =========================================================>
--> Define desktop taskbar terminal widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.terminal = {
    default = {
        size = 400,
        timeout = 5,
        history = 250,
        enabled = true,
        --> Supported shells: bash or zsh.
        completion_shell = "bash",
        prompt = {
            prefix = "Execute: ",
            ellipsize = "middle"
        },
        color = {
            icon = theme.color.default.dynamic.color1,
            cursor = theme.color.default.dynamic.color1,
            hightlighter = {
                string = "#935DD9",
                control = "#D15454",
                variable = "#34CFEB"
            }
        },
        format =  {
            prompt = function(txt) -- apply directly
                return text.bold(
                    text.color(
                        txt,
                        table.get_dynamic(theme.color.default.dynamic.foreground)
                    )
                ) --> Proper tail call
            end,
            command = function(txt)
                return text.italic(txt) --> Proper tail call
            end
        }
    }
}
-- =========================================================>
--> Define desktop taskbar taglist widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.taglist = {
    default = {
        enabled = true,
        swap_sides = true,
        shape = gears.shape.rounded_bar,
        color = theme.color.default.static.widget,
        filter = awful.widget.taglist.filter.all,
        focused = {
            enabled = true,
            color = theme.color.default.dynamic.color1
        },
        tag = {
            height = 8,
            shape = gears.shape.rounded_bar,
            color = {
                empty = theme.color.default.dynamic.color0,
                normal = theme.color.default.dynamic.color1,
                urgent = theme.color.default.dynamic.color2,
                volatile = theme.color.default.dynamic.color4
            }
        },
        index = {
            size = "S",
            default = "∞",
            enabled = true,
            format = function(txt)
                return text.color(
                    text.italic(
                        text.bold(txt)
                    ),
                    theme.color.default.dynamic.color1
                ) --> Proper tail call
            end
        }
    }
}
-- =========================================================>
--> Define desktop taskbar taglist shadow widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.shadow = {
    default = {
        radius = 10,
        timeout = 2, -- Seconds
        margins = 0, --WIP
        spacing = 25,
        opacity = 0.9,
        enabled = true,
        cursor = "cross",
        title = {
            size = "S",
            prefix = text.bold("Tag:"),
            color = theme.color.default.dynamic.background,
            format = function(txt)
                return text.italic(txt) --> Proper tail call
            end
        },
        preview = {
            scale = 1/4,
            show_content = true,
            client = {
                radius = 10,
                thickness = 2,
                opacity = 0.9,
                color = {
                    border = theme.color.default.dynamic.color1,
                    background = theme.color.default.dynamic.background
                }
            }
        },
        icon = {
            size = 80,
            shape = gears.shape.circle,
            color = {
                main = theme.color.default.dynamic.color1,
                sub = theme.color.default.dynamic.color2
            }
        }
    }
}
-- =========================================================>
--> Define desktop taskbar systray widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.systray = {
    default = {
        size = 400,
        timeout = 5, -- Seconds
        enabled = true,
        icon = {
            size = 20,
            opacity = 0.8,
            color = theme.color.default.dynamic.color1
        }
    }
}
-- =========================================================>
--> Define desktop taskbar layoutbox widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.layoutbox = {
    default = {

        margins = mysc.margins(5, 8),
        favourite = awful.layout.suit.floating,
        color = {
            icon = theme.color.default.dynamic.color1,
            fg = theme.color.default.dynamic.foreground,
            bg = theme.color.default.dynamic.background,
            flash = theme.color.default.dynamic.foreground
        },
        tooltip = {
            gaps = 6,
            delay = 0.5,
            margins = 8,
            timeout = 2,
            opacity = 0.6,
            font_size = "S",
            shape = gears.shape.rounded_bar,
            format = function(txt)
                return text.bold(
                    text.capitalize(txt)
                ) --> Proper tail call
            end
        }
    }
}
-- =========================================================>
--> Define desktop taskbar clock widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.clock = {
    default = {
        refresh = 1, -- Seconds
        timeout = 4, -- Seconds
        enabled = true,
        margins = mysc.margins(2, 8),
        timezones = {
            "Europe/Madrid",
            "America/Montevideo",
            "Asia/Tokyo"
        },
        color = {
            fg = theme.color.default.dynamic.foreground,
            bg = theme.color.default.dynamic.background,
            flash = theme.color.default.dynamic.foreground
        },
        time = {
            font_size = "M",
            format = text.capitalize(
                text.bold("%B, %A %d | %H:%M:%S"),
                true --> With pango markup
            )
        },
        tooltip = {
            gaps = 6,
            delay = 0.5,
            margins = 8,
            timeout = 2,
            opacity = 0.6,
            font_size = "S",
            shape = gears.shape.rounded_bar,
            format = function(txt)
                return text.bold(
                    text.capitalize(txt)
                ) --> Proper tail call
            end
        }
    }
}


-- =========================================================>
--> Define desktop taskbar naught sidebar widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.naught = {
    default = {
        notification = {
            radius = 12,
            opacity = 0.8,
            cursor = "cross",
            background = theme.color.default.dynamic.background,
            size = {
                width = 350,
                height = 150
            },
            icon = {
                size = 45,
                hollow = false,
                thickness = 4,
                shape = gears.shape.circle,
                foreground = theme.color.default.dynamic.foreground
            },
            arcbar = {
                size = 32,
                opacity = 0.8,
                thickness = 5,
                icon = {
                    font_size = "XS",
                    foreground = theme.color.default.dynamic.foreground
                }
            },
            actions = {
                radius = 5,
                font_size = "S",
                foreground = theme.color.default.dynamic.foreground,
                size = {
                    width = 70,
                    height = 28
                },
                space = {
                    spacing = 4,
                    margins = mysc.margins(0, 12)
                }
            },
            text = {
                app = {
                    font_size = "S",
                    foreground = theme.color.default.dynamic.foreground
                },
                title = {
                    font_size = "S",
                    foreground = theme.color.default.dynamic.foreground
                },
                message = {
                    font_size = "S",
                    foreground = theme.color.default.dynamic.foreground
                },
                scroll = {
                    fps = 60,
                    speed = 75,
                    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth
                }
            }
        },
        width = 600,
        radius = 30,
        opacity = 0.8,
        enabled = true,
        visible = true,
        cursor = "cross",
        --> widget reset resets this timeout so this value must be lower
        timeout = 4,

        color = {
            icon = theme.color.default.dynamic.color1,
            logo = theme.color.default.dynamic.color1,
            awesome = theme.color.default.dynamic.color1,
            background = theme.color.default.dynamic.background
        }
    }
}
-- =========================================================>
--> Define desktop taskbar raven calendar widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.calendar = {
    default = {
        timeout = 5,
        enabled = true,
        cursor = "cross",
        color = theme.color.default.dynamic.background,
        icon_color = theme.color.accents


    }
}
-- =========================================================>
--> Define desktop taskbar raven calendar notes widget properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
theme.notes = {
    default = {
        cursor = "cross",
        width = 800,
        height = 500,
        color = theme.color.default.dynamic.background,
        spacing = 25,
        margin = 25,
        history = 10
    }
}

-- =========================================================>
--> Define desktop wallpaper properties:
-- =========================================================>
-->> Uses screen-specific crush with default precedence
-- =========================================================>
--explain poitner system

-->> Wallpaper configuration
theme.wallpaper = {
    file = "", --> file fallback in case wallpaper is not found
    -->> Default wallpaper configuration
    default = {
        enabled = true,
        mode = "static"
    },
    --1 = 2 --> Pointer system
    -->> Wallpaper mode-specific configuration
    mode = {
        static = {
            file = nil, --> File gets priority over folder
            reuse = false,
            random = true,
            pywall = true,
            timeout = 500,--5 * 60, -- Seconds
            folder = wallpaper_path,
            extensions = {"jpg", "jpeg", "svg", "png"},
            honor = {
                padding = false,
                workarea = false
            }
        },
        dynamic = {
            -- define
        }
    }
}
--assert more than one file in slideshow modes

theme.cursor = {
    button = "hand2"
}


local backmodes = {-- dont like name
    fallback = {
        theme.tag,
    --},
    --crushback = {
        theme.color,
        theme.client,

        theme.notification,

        theme.session,

        theme.taskbar,
        theme.raven,
        theme.terminal,
        theme.taglist,
        theme.shadow,
        theme.systray,
        theme.layoutbox,
        theme.clock,
        theme.naught,
        theme.calendar,
        theme.notes
    },
    fontback = {
        theme.fonts.main,
        theme.fonts.icon
    },
    wallback = {
        theme.wallpaper
    }
}

for func,sections in next, backmodes do
    for _,section in next, sections do
        table[func](section)
    end
end

-- =========================================================>
--> Translation
-- =========================================================>


-- =========================================================>
return theme
