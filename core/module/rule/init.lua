-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                           RULE
-- =========================================================>
----> AwesomeWM Client Rules
-- =========================================================>
--  [Imports] Rule:
-- =========================================================>
local require = require
-- =========================================================>
local client = require("module.rule.client")
local notification = require("module.rule.notification")
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Functions] Rule:
-- =========================================================>
---> Attaches all our rules to ruled:
-- =========================================================>
function this.attach()
    -->> Attach rules for notifications
    notification:attach()
    -->> Attach rules for clients
    return client:attach() --> Proper tail call
end
-- =========================================================>
---> Detaches all our rules from ruled:
-- =========================================================>
function this.detach()
    -->> Detach rules for notifications
     notification:detach()
    -->> Detach rules for clients
    return client:detach() --> Proper tail call
end
-- =========================================================>
return this
