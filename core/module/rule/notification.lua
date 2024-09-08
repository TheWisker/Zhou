-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                    RULE - NOTIFICATION
-- =========================================================>
----> AwesomeWM Notification Rules
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local ruled = require("ruled")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Rules] Notifications:
-- =========================================================>
---> Table containing notification rules:
-- =========================================================>
this.rules = {
    {
        id = "global",
        rule = { },
        properties = {
            screen = awful.screen.preferred,
            implicit_timeout = 5
        }
    }
}
-- =========================================================>
--  [Functions] Rule - Notification:
-- =========================================================>
---> Attaches our notification rules to ruled.notifications:
-- =========================================================>
function this:attach()
    -->> Append all rules in one call
    return ruled.notification.append_rules(
        self.rules
    ) --> Proper tail call
end
-- =========================================================>
---> Detaches our notification rules from ruled.notifications:
-- =========================================================>
function this:detach()
    -->> Loop trough all rules
    for _,rule in next, self.rules do
        --> We have to do it one by one as
        --> there is no general method, unlike when appending
        ruled.notification.remove_rule(rule)
    end
end
-- =========================================================>
--  [Signal] Rule - Notification:
-- =========================================================>
---> Connects the rule request petition to attach our rules:
-- =========================================================>
ruled.notification.connect_signal(
    "request::rules",
    function()
        return this:attach() --> Proper tail call
    end
)
-- =========================================================>
return this
