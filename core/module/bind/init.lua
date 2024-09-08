-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                           BIND
-- =========================================================>
----> AwesomeWM Global & Client Bindings
-- =========================================================>
--  [Imports] Bind:
-- =========================================================>
local require = require
-- =========================================================>
local mouse = require("module.bind.mouse")
local keyboard = require("module.bind.keyboard")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Functions] Bind:
-- =========================================================>
---> Binds our mouse and key bindings to awful:
-- =========================================================>
function this.bind(v)
    -->> Bind mousebindings for bindspace (v)
    mouse:bind(v)
    -->> Bind keybindings for bindspace (v)
    return keyboard:bind(v) --> Proper tail call
end
-- =========================================================>
---> Unbinds our mouse and key bindings from awful:
-- =========================================================>
function this.unbind(v)
    -->> Unbind mousebindings for bindspace (v)
    mouse:unbind(v)
    -->> Unbind keybindings for bindspace (v)
    return keyboard:unbind(v) --> Proper tail call
end
-- =========================================================>
return this
