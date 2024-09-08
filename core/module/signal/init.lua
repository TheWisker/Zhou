-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                          SIGNAL
-- =========================================================>
----> AwesomeWM Signal Dispatcher
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local require = require
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {package = setmetatable({}, {__mode = "v"})}
-- =========================================================>
--  [Functions] Signal:
-- =========================================================>
--> Imports (package) to this.package.(id) if not present:
-- =========================================================>
-->> This method of importing packages evades circular
-->> importation conflicts for almost every possible case
-- =========================================================>
function this:import(id, package)
    self.package[id] = self.package[id] or require(package)
end
-- =========================================================>
--  [Functions] Awesome Signals:
-- =========================================================>
this.awesome = {}
-- =========================================================>
--> Resets the configuration without restarting AwesomeWM:
-- =========================================================>
function this.awesome.reset(...)
    this:import("desktop", "module.desktop")
    this:import("notif", "module.notif")
    this:import("client", "module.client")
    this.package.notif:reset(...)
    this.package.client:reset(...)
    return this.package.desktop.reset(...) --> Proper tail call
end
-- =========================================================>
--  [Functions] Notification Signals:
-- =========================================================>
this.notification = {}
-- =========================================================>
--> Sends a notification with the desired parameters:
-- =========================================================>
function this.notification.notify(...)
    this:import("notif", "module.notif")
    return this.package.notif.notify(...) --> Proper tail call
end
-- =========================================================>
--> Usual lua assert that sends error notification on error:
-- =========================================================>
function this.notification.assert(...)
    this:import("notif", "module.notif")
    return this.package.notif:assert(...) --> Proper tail call
end
-- =========================================================>
--  [Functions] Volume Signals:
-- =========================================================>
this.volume = {}
-- =========================================================>
function this.volume.show()
    this:import("volume", "module.desktop.volume")

end
-- =========================================================>
--  [Functions] Shadow Signals:
-- =========================================================>
this.shadow = {}
-- =========================================================>
--> Open the shadow popup for tag (tag):
-- =========================================================>
function this.shadow.show(tag)
    this:import("shadow", "module.desktop.shadow")
    -->> Shadow guard
    if (this.package.shadow.shadows[tag.screen.index]) then
        return this.package.shadow.shadows[tag.screen.index].actions.open(tag) --> Proper tail call
    end
end
-- =========================================================>
--> Close the shadow popup:
-- =========================================================>
function this.shadow.hide(tag)
    this:import("shadow", "module.desktop.shadow")
    -->> Shadow guard
    if (this.package.shadow.shadows[tag.screen.index]) then
        return this.package.shadow.shadows[tag.screen.index].actions.close() --> Proper tail call
    end
end
-- =========================================================>
--  [Functions] Exitscreen Signals:
-- =========================================================>
this.exitscreen = {}
-- =========================================================>
function this.exitscreen.show()
    this:import("exitscreen", "module.desktop.exitscreen")

end
-- =========================================================>
function this.exitscreen.hide()
    this:import("exitscreen", "module.desktop.exitscreen")

end
-- =========================================================>
--  [Functions] Wallpaper Signals:
-- =========================================================>
this.wallpaper = {}
-- =========================================================>
--> Retrieves the current wallpaper in use for screen (s):
-- =========================================================>
function this.wallpaper.get(s)
    this:import("wallpaper", "module.desktop.wallpaper")
    return this.package.wallpaper.wallpapers[s.index].wallpaper
end
-- =========================================================>
--> Sets the next wallpaper for screen (s):
-- =========================================================>
function this.wallpaper.next(s)
    this:import("wallpaper", "module.desktop.wallpaper")
    return this.package.wallpaper.wallpapers[s.index].actions.set(
        this.package.wallpaper.wallpapers[s.index].actions.get()
    ) --> Proper tail call
end
-- =========================================================>
--> Toggles the wallpaper timers, if any, for screen (s):
-- =========================================================>
function this.wallpaper.pause(s)
    this:import("wallpaper", "module.desktop.wallpaper")
    if (this.package.wallpaper.wallpapers[s.index].timer) then
        if (this.package.wallpaper.wallpapers[s.index].timer.started) then
            return this.package.wallpaper.wallpapers[s.index].timer:stop() --> Proper tail call
        else
            return this.package.wallpaper.wallpapers[s.index].timer:start() --> Proper tail call
        end
    end
end
-- =========================================================>
return this
