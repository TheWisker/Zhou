-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                       RULE - CLIENT
-- =========================================================>
----> AwesomeWM Client Rules
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local require = require
-- =========================================================>
local awful = require("awful")
local ruled = require("ruled")
-- =========================================================>
--  [Imports] Utils:
-- =========================================================>
local mysc = require("util.mysc")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local next = next
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {}
-- =========================================================>
--  [Rules] Clients:
-- =========================================================>
---> Table containing client rules:
-- =========================================================>
this.rules = {
    {
        rule = {},
        id = "global",
        properties = {
            raise = true,
            shape = mysc.shape("rounded_rect", 15),
            screen = awful.screen.preferred,
            focus = awful.client.focus.filter,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },
    {
        id = "titlebars",
        rule_any = {
            type = {"normal", "dialog"}
        },
        properties = {
            titlebars_enabled = false
        }
    }
}
-- =========================================================>
--  [Functions] Rule - Client:
-- =========================================================>
---> Attaches our client rules to ruled.client:
-- =========================================================>
function this:attach()
    -->> Append all rules in one call
    return ruled.client.append_rules(
        self.rules
    ) --> Proper tail call
end
-- =========================================================>
---> Detaches our client rules from ruled.client:
-- =========================================================>
function this:detach()
    -->> Loop trough all rules
    for _,rule in next, self.rules do
        --> We have to do it one by one as
        --> there is no general method, unlike when appending
        ruled.client.remove_rule(rule)
    end
end
-- =========================================================>
--  [Signal] Rule - Client:
-- =========================================================>
---> Connects the rule request petition to attach our rules:
-- =========================================================>
ruled.client.connect_signal(
    "request::rules",
    function()
        return this:attach() --> Proper tail call
    end
)
-- =========================================================>
return this
