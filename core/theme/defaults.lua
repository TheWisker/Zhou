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
function theme:colors_refresh()
    -->> Use of dynamic table modification gate
    return self.color.dynamic(
        signal.notification.assert(
            --> Uses loadfile to ensure the file gets loaded from scratch
            loadfile(symlink_path .. "colors.lua")
        )() --> Call the returned function to load the file
    ) --> Proper tail call
end



--bling
theme.flash_focus_start_opacity = 0.8 -- the starting opacity
theme.flash_focus_step = 0.005         -- the step of animation




-- =========================================================>
--  [Theme] Behaviour:
-- =========================================================>
--> Define specific apps for each category:
-- =========================================================>
theme.exec = {
    pywall = "wal -nq -i ",
    compositor = {
        on = "picom --daemon",
        off = "pkill picom"
    },
    app = {
        terminal = "kitty",
        browser = "firefox",
        filemanager = "dolphin",
        screenshot = "flameshot gui",
        launcher = "rofi -modes drun,window,filebrowser,run -show drun"
    },
    audio = {
        next = "playerctl next",
        mute = "playerctl volume 0",
        prev = "playerctl previous",
        pause = "playerctl play-pause",
        volume_up = "playerctl volume +0.05",
        position_up = "playerctl position +5",
        volume_down = "playerctl volume -0.05",
        position_down = "playerctl position -5"
    },
    session = {
        lock = "light-locker -l",
        sleep = "systemctl sleep",
        restart = "systemctl reboot",
        suspend = "systemctl suspend",
        shutdown = "systemctl poweroff",
        hibernate = "systemctl hibernate",
        switch = "dm-tool switch-to-greeter"
    },
    startup = {
        "kitty --session=./sessions/startup.conf"
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
        --awful.layout.suit.max,
        --awful.layout.suit.magnifier,
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
            gap = 10,
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
            gap = 10,
            index = 1,
            name = "Alpha",
            selected = true,
            gap_single_client = true,
            master_width_factor = 10,
            layouts = theme.layout.default,
            layout = awful.layout.suit.tile,
            master_fill_policy = "master_width_factor",
            --icon = gears.color.recolor_image(icon_path .. "arrow/left.svg", "#6A67C9")
        },
        {
            gap = 10,
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
            gap = 10,
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
            gap = 10,
            index = 4,
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
            gap = 10,
            index = 5,
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
            gap = 10,
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
            gap = 10,
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
            gap = 10,
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
            gap = 10,
            index = 4,
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
            gap = 10,
            index = 5,
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
theme.icon_theme = "Amy"
-- =========================================================>
--> Define some styling parameters:
-- =========================================================>
theme.maximized_hide_border = false
theme.fullscreen_hide_border = true
theme.maximized_honor_padding = true
-- =========================================================>
--> Define screen spacing for widgets:
-- =========================================================>
theme.spacing = 10
-- =========================================================>
--> Define font's names and sizes for each function:
-- =========================================================>
theme.fonts = {
    -->> Font used in all text
    main = {
        name = "Iosevka Nerd Font",
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
        name = "Font Awesome 6 Free",
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
theme.color = {
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
        terminal = {
            duration = 1/2, -- Seconds
            easing = rubato.bouncy
        },
        taskbar = {
            duration = 1/5, -- Seconds
            easing = rubato.bouncy
        },
        systray = {
            duration = 1/2, -- Seconds
            easing = rubato.bouncy
        },
        taglist = {
            duration = 1/4, -- Seconds
            easing = rubato.bouncy
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
        --> Player icons
        player = {
            play = "",
            pause = "",
            forward = "",
            backward = ""
        },
        --> Session icons
        session = {
            exit = "",
            lock = "",
            sleep = "",
            switch = "",
            restart = "",
            suspend = "",
            shutdown = "",
            hibernate = ""
        }
    },
    --> Image file icons
    image = {
        --> Do not disturb icon
        dnd = icon_path .. "dnd.svg",
        --> Awesome icon
        awesome = icon_path .. "awesome.svg",
        --> Redlight icon
        redlight = icon_path .. "redlight.svg",
        --> Raven icon
        raven = icon_path .. "widgets/raven.svg",
        --> Notification icon
        notification = "",
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
--> Client styling and configuration
-- =========================================================>
theme.client = {
    autofocus = true, --> Whether to automatically focus a client on hover
    shape = mysc.shape("rounded_rect", 20), --> Shape of the client
    snap = { --> Configuration for client snap action
        gap = 10, --> Gap, in pixels, to leave when snapping
        thickness = 8, --> Thickness, in pixels, of the snap preview borders
        color = theme.color.dynamic.color1, --> Color of the snap preview
        shape = mysc.shape("rounded_rect", 20) --> Shape of the snap preview
    },
    border = { --> Configuration for client dynamic border
        thickness = 4, --> Thickness, in pixels, for the client's border
        color = { --> Colors for the client's border based on client's state
            urgent = theme.color.dynamic.color2, --> Color for urgent state
            focused = theme.color.dynamic.color1, --> Color for focused state
            floating = theme.color.dynamic.color3, --> Color for floating state
            normal = theme.color.dynamic.background --> Color for normal state
        }
    }
}
-- =========================================================>
--  [Theme] Widgets:
-- =========================================================>
--> Define general and style-specific notification props:
-- =========================================================>
theme.notification = {
    radius = 12, --> Radius, in pixels, for the notification
    opacity = 0.8, --> Opacity of the notification and its background
    cursor = "cross", --> Cursor to use when hovering over the notification
    position = "top_right", --> Position for the notifications
    background = theme.color.dynamic.background,
    size = { --> Configuration for the notification size
        width = 350, --> Max width, in pixels
        height = 200 --> Max height, in pixels
    },
    icon = { --> Configuration for the app icon
        size = 45, --> Size, in pixels, of the app icon
        thickness = 4, --> Thickness, in pixels, of the app icon
        hollow = false, --> Whether the app icon fram should be hollow
        shape = gears.shape.circle, --> Shape for the app icon
        foreground = theme.color.dynamic.foreground --> Color of the text, of the subicon, as it is a text icon
    },
    arcbar = { --> Configuration for the arcbar
        size = 32, --> Size, in pixels, of the arcbar
        opacity = 0.8, --> Opacity of the arcbar and its background
        thickness = 5, --> Thickness, in pixels, of the arcbar
        icon = { --> Configuration for the arcbar's close button icon
            font_size = "XS", --> Size of the text font as it is a text icon
            foreground = theme.color.dynamic.foreground --> Color of the text as it is a text icon
        }
    },
    actions = { --> Configuration for the actions
        radius = 5, --> Radius, in pixels, for the actions
        font_size = "S", --> Size of the text font
        foreground = theme.color.dynamic.foreground, --> Color of the text
        size = { --> Configuration for the actions's size
            width = 70, --> Width, in pixels, of the actions
            height = 38 --> Height, in pixels, of the actions
        },
        space = { --> Configuration for the actions's spaces
            spacing = 4, --> Spacing, in pixels, between the actions
            margins = mysc.margins(0, 12) --> Margins, in pixels, of the actions
        }
    },
    text = { --> Configuration for the notification's text
        app = { --> Configuration for the application name
            font_size = "S", --> Size of the text font
            foreground = theme.color.dynamic.foreground --> Color of the text
        },
        title = { --> Configuration for the notification title
            font_size = "S", --> Size of the text font
            foreground = theme.color.dynamic.foreground --> Color of the text
        },
        message = { --> Configuration for the notification message
            font_size = "S", --> Size of the text font
            foreground = theme.color.dynamic.foreground --> Color of the text
        },
        scroll = { --> Configuration for the text scroll
            fps = 60, --> Framerate for the scroll animation
            speed = 75, --> Speed of the scroll animation
            step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth
        }
    },
    style = { --> Configuration for different styles of notifications
        default = { --> Default style
            bg = {
                {0, theme.color.dynamic.color1},
                {0.25, theme.color.dynamic.color4},
                {0.75, theme.color.dynamic.color3},
                {1, theme.color.dynamic.color2}
            }
        },
        error = { --> Error style
            timeout = 0,
            resident = false,
            urgency = "critical",
            category = "awesome.event.error"
        }
    }
}
-- =========================================================>
--> Define desktop session screen popup properties:
-- =========================================================>
theme.session = { -->>
    spacing = 50, --> Spacing, in pixels, between the session buttons
    opacity = 0.8, --> Opacity of the session and its background
    cursor = "cross", --> Cursor to use when hovering over the session
    background = theme.color.dynamic.background, --> Color for the session background
    buttons = { --> Configuration for the session buttons
        size = 165, --> Size, in pixels, for the buttons
        thickness = 8, --> Thickness, in pixels, for the buttons borders
        font_size = 75, --> Size of the text font as it is a text icon
        shape = gears.shape.circle, --> Shape of the buttons
        color = { --> Configuration for the colors of the session
            accent = theme.color.dynamic.color1, --> Accent color for when hovering over the buttons
            background = theme.color.static.widget, --> Foreground color for the buttons
            foreground = theme.color.dynamic.color2 --> Background color for the buttons
        }
    }
}
-- =========================================================>
--> Define desktop cheatsheet screen popup properties:
-- =========================================================>
theme.cheatsheet = { -->>
    margin = 20, --> Margin, in pixels, between sections
    thickness = 6, --> Thickness, in pixels, for the cheatsheet's border
    opacity = 0.85, --> Opacity of the cheatsheet and its background
    font_size = "M", --> Size of the text font
    desc_font_size = "S", --> Size of the description text font
    shape = mysc.shape("rounded_rect", 20), --> Shape of the cheatsheet
    color = { --> Configuration for the colors of the cheatsheet
        accent = theme.color.dynamic.color1, --> Color for the cheatsheet border and etc
        foreground = theme.color.dynamic.foreground, --> Color for the cheatsheet foreground
        background = theme.color.dynamic.background, --> Color for the cheatsheet background
        mod_foreground = theme.color.dynamic.color2 --> Color for the cheatsheet modifiers foreground
    }
}
-- =========================================================>
--> Define desktop taskbar widget properties:
-- =========================================================>
theme.taskbar = {
    height = 30, --> Height, in pixels, of the taskbar
    spacing = 5, --> Spacing, in pixels, between taskbar widgets
    padding = 6, --> Internal taskbar padding, in pixels, that adds to the height
    margins = 0, --> External taskbar margins, in pixels, that do not add to the height
    opacity = 0.8, --> Opacity of the taskbar and its background
    visible = true, --> Taskbar default visibility
    stretch = true, --> Whether to stretch the taskbar to the edges
    cursor = "cross",  --> Cursor to use when hovering over the taskbar
    position = "bottom", --> Position, top or bottom, of the taskbar
    shape = gears.shape.rectangle, --> Shape for the taskbar
    color = theme.color.dynamic.background, --> Color of the taskbar
    awesome = { --> Configuration for the awesome logo in the taskbar
        radius = 5, --> Radius, in pixels, of the clip shape of the awesome logo
        opacity = 0.6, --> Opacity for the awesome logo
        color = theme.color.dynamic.color1, --> Color of the awesome logo
        margins = mysc.margins(5, 0) --> Margins, in pixels, around the awesome logo
    },
    progressbar = { --> Configuration for the progressbar integrated in the taskbar
        height = 2, --> Height, in pixels, for the progressbar
        opacity = 0.8, --> Opacity for the progressbar
        color = theme.color.dynamic.color1, --> Color of the progressbar
        shape = mysc.shape("rounded_rect", 8), --> Shape of the progressbar
        background = theme.color.static.transparent --> Background color for the progressbar
    },
}
-- =========================================================>
--> Define desktop taskbar raven sidebar widget properties:
-- =========================================================>
theme.raven = {
    width = 350, --> Width, in pixels, for the raven
    radius = 50, --> Radius, in pidexls, for the corners
    timeout = 4, --> Timeout, in seconds, to autohide
    opacity = 0.8, --> Opacity for the raven
    visible = true, --> Whether to be initially visible
    title = { --> Raven title configuration
        font_size = 45, --> Font size for the title
        color = theme.color.dynamic.foreground --> Color for the title
    },
    color = { --> Raven color configuration
        evoker = theme.color.dynamic.color1, --> Evoker button color
        background = theme.color.dynamic.background --> Raven background color
    }
}
-- =========================================================>
--> Define desktop taskbar player widget properties:
-- =========================================================>
theme.player = { -->>
    cover = {
        shape = gears.shape.circle,
    },
    buttons = {
        shape = gears.shape.circle,
        font_size = "S",
        color = theme.color.dynamic.color1
    },
    tooltip = {
        gaps = 6,
        delay = 0.5,
        margins = 8,
        timeout = 2,
        opacity = 0.6,
        font_size = "S",
        shape = gears.shape.rounded_bar,
        background = theme.color.dynamic.background,
        foreground = theme.color.dynamic.foreground,
        format = function(txt)
            return text.bold(
                text.capitalize(txt)
            ) --> Proper tail call
        end
    }
}
-- =========================================================>
--> Define desktop taskbar terminal widget properties:
-- =========================================================>
theme.terminal = {
    size = 400,
    timeout = 5,
    history = 250,
    enabled = true,
    --> Supported shells: bash or zsh.
    completion_shell = "bash",
    prompt = {
        font_size = "XS",
        prefix = "Execute: ",
        ellipsize = "middle"
    },
    color = {
        icon = theme.color.dynamic.color1,
        cursor = theme.color.dynamic.color1,
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
                    table.get_dynamic(theme.color.dynamic.foreground)
                )
            ) --> Proper tail call
        end,
        command = function(txt)
            return text.italic(txt) --> Proper tail call
        end
    }
}
-- =========================================================>
--> Define desktop taskbar taglist widget properties:
-- =========================================================>
theme.taglist = {
    enabled = true,
    swap_sides = true,
    shape = gears.shape.rounded_bar,
    color = theme.color.static.widget,
    filter = awful.widget.taglist.filter.all,
    focused = {
        enabled = true,
        color = theme.color.dynamic.color1
    },
    tag = {
        height = 8,
        shape = gears.shape.rounded_bar,
        color = {
            empty = theme.color.dynamic.color0,
            normal = theme.color.dynamic.color1,
            urgent = theme.color.dynamic.color2,
            volatile = theme.color.dynamic.color4
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
                theme.color.dynamic.color1
            ) --> Proper tail call
        end
    }
}
-- =========================================================>
--> Define desktop taskbar taglist shadow widget properties:
-- =========================================================>
theme.shadow = {
    radius = 10, --> Radius, in pixels, for the edges of the shadow
    timeout = 2, --> Timeout, in seconds, for hiding the shadow
    spacing = 25, --> Spacing, in pixels, between the shadow and the edges of the screen
    opacity = 0.9, --> Opacity for the shadow in the preview or their icons
    glimpse = true, --> Whether to glimpse the selected tag on startup
    cursor = "cross", --> Cursor to use when hovering over the shadow
    background = theme.color.dynamic.background, --> Color of the background of the shadow
    icon = { --> Configuration for the tag icon
        size = 60, --> Size, in pixels, for the icon
        shape = gears.shape.circle, --> Shape for the icon's frame
        color = { --> Configuration for the tag icon colors
            sub = theme.color.dynamic.color2, --> Color for sub icon
            main = theme.color.dynamic.color1 --> Color for main icon
        }
    },
    title = { --> Configuration for the tag title
        font_size = "M", --> Font size for the tag title
        color = theme.color.dynamic.foreground, --> Color for the tag title
        format = function(txt) --> Format to apply to the tag title (txt)
            return text.bold(txt) --> Proper tail call
        end
    },
    preview = { --> Configuration for the tag preview
        scale = 1/4, --> Scale, compared to screen, for the preview
        margins = 0, --> Margins, in pixels, around the preview
        show_content = true, --> Whether to show the tag's clients content
        client = { --> Configuration for the preview tag's clients
            radius = 10, --> Radius, in pixels, for the edges of the clients in the preview
            thickness = 2, --> Thickness, in pixels, for the border around the clients in the preview
            opacity = 0.9, --> Opacity for the clients in the preview or their icons
            color = { --> Configuration for the preview tag's clients colors
                border = theme.color.dynamic.color1, --> Color of the border around the clients in the preview
                background = theme.color.dynamic.background --> Color of the background of the clients in the preview
            }
        }
    }
}
-- =========================================================>
--> Define desktop taskbar systray widget properties:
-- =========================================================>
theme.systray = {
    size = 400, --> Max width, in pixels
    timeout = 5, --> Timeout, in seconds, to automatically hide
    icon = { --> Systray icon configuration
        size = 20, --> Size, in pixels, for the icon
        opacity = 0.8, --> Opacity for the icon
        color = theme.color.dynamic.color1 --> Color for the icon
    }
}
-- =========================================================>
--> Define desktop taskbar layoutbox widget properties:
-- =========================================================>
theme.layoutbox = {
    margins = mysc.margins(5, 8),
    favourite = awful.layout.suit.floating,
    color = {
        icon = theme.color.dynamic.color1,
        fg = theme.color.dynamic.foreground,
        bg = theme.color.dynamic.background,
        flash = theme.color.dynamic.foreground
    },
    tooltip = {
        gaps = 6,
        delay = 0.25,
        margins = 8,
        timeout = 0.5,
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
-- =========================================================>
--> Define desktop taskbar clock widget properties:
-- =========================================================>
theme.clock = {
    refresh = 1, --> Timeout, in seconds, between clock refreshes
    timeout = 4, --> Timeout, in seconds, to automatically set first timezone
    margins = mysc.margins(2, 8),
    timezones = {
        "Europe/Madrid",
        "America/Montevideo",
        "Asia/Tokyo"
    },
    color = {
        fg = theme.color.dynamic.foreground,
        bg = theme.color.dynamic.background,
        flash = theme.color.dynamic.foreground
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
-- =========================================================>
--> Define desktop taskbar raven calendar widget properties:
-- =========================================================>
theme.calendar = {
    timeout = 5,
    thickness = 2, --> Thickness, in pixels, for the calendar border
    cursor = "cross",
    color = theme.color.dynamic.color1, --> Color for the calendar border
    buttons = {
        size = 35,
        color = theme.color.dynamic.color1,

    },
    weekcell = {
        names = {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"},
        font_size = "M",
        foreground = theme.color.dynamic.foreground --> Foreground color for weekcell
    },
    daycell = {
        size = 25,
        font_size = "S",
        background = theme.color.dynamic.color1, --> Background color for current daycell
        foreground = theme.color.dynamic.foreground --> Foreground color for daycell
    }
}
-- =========================================================>
--> Define desktop wallpaper properties:
-- =========================================================>
theme.wallpaper = { -->> Wallpaper configuration
    file = nil, --> Path to single static wallpaper which gets priority over folder
    reuse = false, --> Whether a switch can set the same wallpaper
    random = true, --> Select randomly or sequentially
    pywall = true, --> Whether colors should be updated according to the wallpaper of the primary screen (requires pywall)
    timeout = 500, --> Timeout in seconds for switching the wallpaper automatically with 0 disabling this feature
    extend = false, --> Whether to extend the wallpaper to all the screens or simply set the same wallpaper for each one
    cursor = "cross", --> Cursor to use when hovering over the desktop background
    folder = wallpaper_path, --> Path to folder from where wallpapers are searched for non-recursively
    extensions = {"jpg", "jpeg", "svg", "png"}, --> Extensions for the wallpapers in the wallpaper folder
    honor = {
        padding = false,
        workarea = false
    }
}
--assert more than one file in slideshow modes

theme.cursor = {
    button = "hand2"
}
-- =========================================================>
--> Set xback metamethod to specific theme tables:
-- =========================================================>
table.fallback(theme.tag)
table.fontback(theme.fonts.main)
table.fontback(theme.fonts.icon)
-- =========================================================>
return theme
