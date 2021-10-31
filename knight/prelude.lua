-- NOTE: to avoid conflicts, prelude-local variables must be invalid as knight
-- variable identifiers. this is done by using PascalCase names of at least 2
-- characters, even if this is unconventional style for lua.

math.randomseed(os.time())

-- contexts
local function Boolean(val)
    local t = type(val)

    if t == "boolean" then
        return val
    elseif t == "number" then
        return val ~= 0
    elseif t == "string" then
        return #val ~= 0
    elseif t == "nil" then
        return false
    end
end

local function Number(val)
    local t = type(val)

    if t == "number" then
        return val
    elseif t == "boolean" then
        return val and 1 or 0
    elseif t == "string" then
        local s = val:match("^[ \t\r\n]*([-+]?[0-9]*)")
        if s == " " or s == "+" or s == "-" then s = "0" end
        return tonumber(s)
    elseif t == "nil" then
        return 0
    end
end

local function String(val)
    local t = type(val)

    if t == "string" then
        return val
    elseif t == "number" then
        return tostring(val)
    elseif t == "boolean" then
        return tostring(val)
    elseif t == "nil" then
        return "null"
    end
end

-- builtins
local function R() -- RANDOM
    return math.random(0, 0x7fff)
end

local function P() -- PROMPT
    return io.read("*l")
end

local function V(name) -- VALUE
    name = String(name)
    if LuaGlobals[name] then
        name = "K_" .. name
    end
    return _G[name]
end

local function E(code) -- EVAL
    return _G.Eval(String(code)) -- provided by knight.lua
end

local function Q(code) -- QUIT
    os.exit(Number(code))
end

local function U(filename) -- USE
    local f = io.open(filename)
    local code = f:read("*a")
    f:close()
    return E(code, filename)
end

local function D(val) -- TODO: DUMP
    local t = type(val)

    if t == "string" then
        val = "String("..val..")"
    elseif t == "number" then
        val = "Number("..tostring(val)..")"
    elseif t == "boolean" then
        val = "Boolean("..tostring(val)..")"
    elseif t == "nil" then
        val = "Null()"
    end

    io.write(val)
    io.flush()
end

local function O(val) -- OUTPUT
    val = String(val)
    if val:sub(-1, -1) == "\\" then
        io.write(val:sub(1, -2))
        io.flush()
    else
        print(val)
    end
end

local function A(val) -- ASCII
    if type(val) == "number" then
        return string.char(val)
    else
        return string.byte(val)
    end
end

local function W(cond, t) -- WHILE
    while Boolean(cond()) do
        t()
    end
end

local function I(cond, t, f) -- IF
    if Boolean(cond()) then
        return t()
    else
        return f()
    end
end

local function G(str, i, len) -- GET
    str, i, len = String(str), Number(i), Number(len)
    return string.sub(str, i+1, i+len)
end

local function S(str, i, len, sub) -- SUBSTITUTE
    str, i, len, sub = String(str), Number(i), Number(len), String(sub)
    return string.sub(str, 1, i) .. sub .. string.sub(str, i+len+1)
end

-- symbolic builtins
local function Last(...) -- ;
    return select(select("#", ...), ...)
end

local function System(cmd) -- `
    local f = io.popen(cmd)
    local c = f:read("*a")
    f:close()
    return c 
end

local function Not(arg) -- !
    return not Boolean(arg)
end

local function Plus(a, b) -- +
    local t = type(a)

    if t == "number" then
        return a + Number(b)
    elseif t == "string" then
        return a .. String(b)
    end
end

local function Minus(a, b) -- -
    return Number(a) + Number(b)
end

local function Star(a, b) -- *
    local t = type(a)
    b = Number(b)

    if t == "number" then
        return a * b
    elseif t == "string" then
        return string.rep(a, b)
    end
end

local function Divide(a, b) -- /
    return math.floor(Number(a) / Number(b))
end

local function Modulo(a, b) -- %
    return Number(a) % Number(b)
end

local function Power(a, b) -- ^
    return math.floor(Number(a) ^ Number(b))
end

local function Less(a, b) -- <
    local t = type(a)

    if t == "number" then
        return a < Number(b)
    elseif t == "string" then
        return a < String(b)
    elseif t == "boolean" then
        return Boolean(b) and not a 
    end
end

local function Greater(a, b) -- >
    return Less(b, a)
end

local function Equal(a, b) -- ?
    return a == b
end

local function And(a, b) -- &
    if Boolean(a) then
        return b
    else
        return a
    end
end

local function Or(a, b) -- |
    if Boolean(a) then
        return a
    else
        return b
    end
end

local function Last(...) -- ;
    return select(select("#", ...), ...)
end

local function Set(name, value) -- =
    _G[name] = value
    return value
end
