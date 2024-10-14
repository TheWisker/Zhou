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
    this:import("notif", "module.notif")
    this:import("client", "module.client")
    this:import("desktop", "module.desktop")
    this.package.notif:reset(...)
    this.package.client:reset(...)
    this.package.desktop.reset(...) --> Proper tail call
end

-- =========================================================>
--> Shows the hotkey help popup for AwesomeWM:
-- =========================================================>
function this.awesome.help()
    this:import("cheatsheet", "module.desktop.cheatsheet")

    return this.package.cheatsheet.cheatsheet.actions.show() --> Proper tail call
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
--  [Functions] Taskbar Signals:
-- =========================================================>
this.taskbar = {}
-- =========================================================>
--> Toggle screen's taskbar or all taskbars:
-- =========================================================>
function this.taskbar.toggle(s)
    this:import("taskbar", "module.desktop.taskbar")
    if (s) then
        this.package.taskbar.taskbars[s.index].actions.toggle()
    else
        for _,taskbar in next, this.package.taskbar.taskbars do
            taskbar.actions.toggle()
        end
    end
end
-- =========================================================>
--> Set taskbar's progressbar position:
-- =========================================================>
function this.taskbar.position(pos, s)
    this:import("taskbar", "module.desktop.taskbar")
    if (s) then
        this.package.taskbar.taskbars[s.index].actions.position(pos)
    else
        for _,taskbar in next, this.package.taskbar.taskbars do
            taskbar.actions.position(pos)
        end
    end
end
-- =========================================================>
--  [Functions] Volume Signals:
-- =========================================================>
this.volume = {}
-- =========================================================>
--> Show the volume popup:
-- =========================================================>
function this.volume.show()
    this:import("volume", "module.desktop.volume")

end
-- =========================================================>
--> Hide the volume popup:
-- =========================================================>
function this.volume.hide()
    this:import("volume", "module.desktop.volume")

end
-- =========================================================>
--  [Functions] Shadow Signals:
-- =========================================================>
this.shadow = {}
-- =========================================================>
--> Show the shadow popup for tag (tag):
-- =========================================================>
function this.shadow.show(tag)
    this:import("shadow", "module.desktop.shadow")
    -->> Shadow guard
    if (this.package.shadow.shadow) then
        return this.package.shadow.shadow.actions.show(tag) --> Proper tail call
    end
end
-- =========================================================>
--> Hide the shadow popup:
-- =========================================================>
function this.shadow.hide()
    this:import("shadow", "module.desktop.shadow")
    -->> Shadow guard
    if (this.package.shadow.shadow) then
        return this.package.shadow.shadow.actions.hide() --> Proper tail call
    end
end
-- =========================================================>
--  [Functions] Session Signals:
-- =========================================================>
this.session = {}
-- =========================================================>
--> Show the session menu:
-- =========================================================>
function this.session.show()
    this:import("session", "module.desktop.session")
    return this.package.session.session.actions.show() --> Proper tail call
end
-- =========================================================>
--> Hide the session menu:
-- =========================================================>
function this.session.hide()
    this:import("session", "module.desktop.session")
    return this.package.session.session.actions.hide() --> Proper tail call
end
-- =========================================================>
--  [Functions] Wallpaper Signals:
-- =========================================================>
this.wallpaper = {}
-- =========================================================>
--> Retrieves the current wallpaper in use:
-- =========================================================>
function this.wallpaper.get()
    this:import("wallpaper", "module.desktop.wallpaper")
    return this.package.wallpaper.wallpaper.wallpaper
end
-- =========================================================>
--> Sets the next wallpaper:
-- =========================================================>
function this.wallpaper.next()
    this:import("wallpaper", "module.desktop.wallpaper")
    return this.package.wallpaper.wallpaper.actions.set(
        this.package.wallpaper.wallpaper.actions.get()
    ) --> Proper tail call
end
-- =========================================================>
--> Toggles the wallpaper timer, if any:
-- =========================================================>
function this.wallpaper.pause()
    this:import("wallpaper", "module.desktop.wallpaper")
    local timer = this.package.wallpaper.wallpaper.timer
    if (timer) then
        if (timer.started) then
            return timer:stop() --> Proper tail call
        else
            return timer:start() --> Proper tail call
        end
    end
end
-- =========================================================>
return this
