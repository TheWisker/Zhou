-- =========================================================>
--  [Test] Dir Library:
-- =========================================================>

-->> Load library dynamically
local load, e = package.loadlib("./dir.so", "luaopen_dir")

-->> Check for errors when interpreting the library
if (not load) then
   return error("Error when loading dynamic dir library:", e) --> Proper tail call
end

-->> Loading the library into Lua
load()

print("_-----------------------------------------_")
-->> Check the 'ls' function
local folder, comp = dir.ls("/"), {}
for _,filename in next, folder do
    print(filename)
end

print("_-----------------------------------------_")
-->> Check the 'ils' function
for filename in dir.ils("/") do
    print(filename)
    comp[(#comp) + 1] = filename
end

print("_-----------------------------------------_")
-->> Check the predictability of both 'ls' and 'ils' functions
local teq = function(t1, t2)
    --> Cautious check
    if ((#t1) ~= (#t2)) then
        return false
    end

    local matches = 0
    --> I know this is not really efficient
    for _,v1 in next, t1 do
        for _,v2 in next, t2 do
            if (v1 == v2) then
                matches = (matches + 1)
            end
        end
    end

    --> I am really paranoid and I also like symmetry
    return (matches == (#t1)) and (matches == (#t2))
end

print(
    "Have the functions 'ls' and 'ils' returned the same results?",
    (teq(folder, comp) and "yes" or "no")
)


print("_-----------------------------------------_")
-->> Check the 'has' function
print(
    "Has the path '/' the folder 'etc'?",
    (dir.has("/", "etc") and "yes" or "no")
)
