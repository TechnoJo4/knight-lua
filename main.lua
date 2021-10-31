local args = {...}
local first = args[1]

local time = false
if args[3] == "-t" then
    time = true
    args[3] = nil
end

if #args == 2 and first == "-e" or first == "-f" then
    local program, name = args[2], args[2]
    if first == "-f" then
        local f = io.open(program, "rb")
        program = f:read("*a")
        f:close()
    end

    local knight = require("knight.knight")
    if time then
        local s = os.clock()
        knight.exec(program, name)
        local e = os.clock()
        print("time:", e - s)
    else
        knight.exec(program, name)
    end
else
    io.stderr:write("usage: -e 'program' | -f file\n")
    os.exit()
end
