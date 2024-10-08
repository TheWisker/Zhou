-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                           KEYS
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local lower = string.lower
local setmetatable = setmetatable
-- =========================================================>
--  [Return] Keys:
-- =========================================================>
---> Table with keys associated with their name or code:
-- =========================================================>
return setmetatable(
    {
-- =========================================================>
        MOD = "Mod4",
-- =========================================================>
        SHIFT = "Shift",
        LSHIFT = "Shift_L",
        RSHIFT = "Shift_R",
-- =========================================================>
        CTRL = "Control",
        LCTRL = "Control_L",
        RCTRL = "Control_R",
-- =========================================================>
        ALT = "Mod1",
        ALTGR = "ISO_Level3_Shift",
-- =========================================================>
        TAB = "Tab",
        ESC = "Escape",
-- =========================================================>
        ENTER = "Return",
        BACKSPACE = "BackSpace",
-- =========================================================>
        SPACE = "space", -- why lowercase first?=??
-- =========================================================>
        UP = "Up",
        DOWN = "Down",
        LEFT = "Left",
        RIGHT = "Right",
-- =========================================================>
        NUMLOCK = "Num_Lock",
        CAPSLOCK = "Caps_Lock",
        DESPLOCK = "Scroll_Lock",
-- =========================================================>
        PRINT = "Print",
        PAUSE = "Pause",
-- =========================================================>
        INSERT = "Insert",
        DELETE = "Delete",
-- =========================================================>
        HOME = "Home",
        END = "End",
-- =========================================================>
        NEXT = "Next",
        PRIOR = "Prior",
-- =========================================================>
        LESS = "less",
        GREATER = "greater",
-- =========================================================>
        PLUS = "KP_Add",
        MINUS = "KP_Subtract",
-- =========================================================>
        V_MUTE = "XF86AudioMute",
        V_RAISE = "XF86AudioRaiseVolume",
        V_LOWER = "XF86AudioLowerVolume",
-- =========================================================>
        A_PLAY = "XF86AudioPlay",
        A_STOP = "XF86AudioStop",
        A_NEXT = "XF86AudioNext",
        A_PREV = "XF86AudioPrev",
        A_RECORD = "XF86AudioRecord",
        A_REWIND = "XF86AudioRewind",
-- =========================================================>
        F1 = "F1",
        F2 = "F2",
        F3 = "F3",
        F4 = "F4",
        F5 = "F5",
        F6 = "F6",
        F7 = "F7",
        F8 = "F8",
        F9 = "F9",
        F10 = "F10",
        F11 = "F11",
        F12 = "F12",
-- =========================================================>
        MENU = "Menu",
-- =========================================================>
        REDO = "Redo",
        UNDO = "Undo",
-- =========================================================>
        CANCEL = "Cancel",
        OFF = "XF86PowerOff",
-- =========================================================>
    },
    {
        -->> When indexing by a non-existing key return the key
        __index = function(_, key)
            return lower(key)
        end
    }
)
