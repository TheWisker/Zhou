-- =========================================================>

--   ▀▀▀██ █ █ █▀█ █ █ ▀ █▀▀   █▀█ █ █ █▀▀ █▀▀ █▀█ █▄█ █▀▀
--   ▄█▀▀  █▀█ █ █ █ █   ▀▀█   █▀█ █▄█ █▀▀ ▀▀█ █ █ █ █ █▀▀
--   ▀▀▀▀▀ ▀ ▀ ▀▀▀ ▀▀▀   ▀▀▀   ▀ ▀ ▀ ▀ ▀▀▀ ▀▀▀ ▀▀▀ ▀ ▀ ▀▀▀

-- =================== @author TheWisker ===================>
-- ============== https://github.com/TheWisker =============>
-- =========================================================>
--                            IO
-- =========================================================>
----> AwesomeWM I/O Utilities
-- =========================================================>
--  [Imports] Awesome:
-- =========================================================>
local gfs = require("gears").filesystem
-- =========================================================>
--  [Imports] Signal:
-- =========================================================>
local signal = require("module.signal")
-- =========================================================>
--  [Imports] Optimization:
-- =========================================================>
local open = io.open
local rename = os.rename
local delete = os.remove
-- =========================================================>
--  [Table] This:
-- =========================================================>
local this = {files = setmetatable({}, {__mode = "kv"})}
-- =========================================================>
--  [Functions] IO:
-- =========================================================>
--> Opens the file at (o) and saves it in a weak table:
-- =========================================================>
function this:open(o)
    if not self.files[o] then
        gfs.make_parent_directories(o)
        self.files[o] = signal:assert(open(o, "w+"))
    end
    return self.files[o]
end
-- =========================================================>
--> Closes the file at (o) removing it from the weak table:
-- =========================================================>
function this:close(o)
    if self.files[o] then
        self.files[o]:close()
        self.files[o] = nil
    end
end
-- =========================================================>
--> Writes (t) to the file at (o):
-- =========================================================>
function this:write(o, t)
    local file = self:open(o)
    return signal:assert(
        file:write(t) == file,
        "Could not read file: " .. o
        --actions???
    )
end
-- =========================================================>
--> Reads the file at (o) with mode (m):
-- =========================================================>
function this:read(o, m)
    if self.exists(o) then
        --> If mode is "a" it cannot fail
        m = m or "a"
        return signal:assert(
            self:open(o):read(m)
        )
    end
    return ""
end
-- =========================================================>
--> Renames the file/directory at (o) to (n):
-- =========================================================>
function this:rename(o, n)
    self:close(o)
    if self.exists(o) then
        signal:assert(rename(o, n))
    end
    return n
end
-- =========================================================>
--> Deletes the file/directory at (o):
-- =========================================================>
function this:delete(o)
    self:close(o)
    if self.exists(o) then
        signal:assert(delete(o))
    end
    return o
end
-- =========================================================>
--> Checks if the file/directory at (o) exists:
-- =========================================================>
function this.exists(o)
    return gfs.is_dir(o) or
        gfs.file_readable(o) or
        gfs.file_executable(o)
end
-- =========================================================>
--> Loads the C package 'dir' library:
-- =========================================================>
-->> Needed as Lua does not have any native list directory
-->> capabilities except for reading console commands outputs
-- =========================================================>
local dir = assert(
    package.loadlib(
        gfs.get_configuration_dir() .. "/lib/dir/dir.so",
        "luaopen_dir"
    )
)()
-- =========================================================>
--> Returns a table with all the files/directories in (o):
-- =========================================================>
function this.ls(o)
    return signal:assert(dir.ls(o))
end
-- =========================================================>
--> Returns a iterator for all the files/directories at (o):
-- =========================================================>
function this.ils(o)
    local ils = signal:assert(dir.ils(o))
    return function(...)
        return ils(...)
    end
end
-- =========================================================>
--> Checks if the directory (o) has the file (c):
-- =========================================================>
function this.has(o, c)
    return signal:assert(dir.has(o, c))
end
-- =========================================================>
return this
