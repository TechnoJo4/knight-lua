local LIT = "lit"

local funcs = {
    ["`"] = "System", ["!"] = "Not",
    ["+"] = "Plus", ["-"] = "Minus", ["*"] = "Star", ["/"] = "Divide",
    ["%"] = "Modulo", ["^"] = "Power",
    ["<"] = "Less", [">"] = "Greater", ["?"] = "Equal",
    ["&"] = "And", ["|"] = "Or",
    [";"] = "Last", ["="] = "Set"
}

local compile, luafunc

luafunc = function(ast)
    return "(function()return("..compile(ast)..")end)"
end

compile = function(ast)
    local f = ast[1]

    if f == LIT then
        return ast[2]
    elseif f == "V" then -- VALUE
        if type(ast[2]) == "string" then
            return ast[2]
        end

        if ast[2][1] == LIT then
            local name = ast[2][2]:match('^"([_a-z][_a-z0-9]*)"$')
            if name then
                return name
            end
        end
    elseif f == "B" then -- BLOCK
        return luafunc(ast[2])
    elseif f == "C" then -- CALL
        return "("..compile(ast[2])..")()"
    elseif f == "`" then -- System
        local arg = ast[2]
        if arg[1] == "+" then
            local aa = arg[2]
            if aa[1] == LIT and aa[2] == '"cat "' then
                return "U("..compile(arg[3])..")"
            end
        end
    elseif f == "=" then -- Set
        ast[2] = { LIT, ("%q"):format(ast[2]) }
    elseif f == "L" then -- LENGTH
        return "#String("..compile(ast[2])..")"
    elseif f == "W" then -- WHILE
        return "W("..luafunc(ast[2])..","..luafunc(ast[3])..")"
    elseif f == "I" then -- IF
        return "I("..luafunc(ast[2])..","..luafunc(ast[3])..","..luafunc(ast[4])..")"
    end

    local f = funcs[ast[1]] or ast[1]

    for i=2,#ast do
        ast[i] = compile(ast[i])
    end

    return f.."("..table.concat(ast, ",", 2)..")"
end

return function(ast)
    return "return " .. compile(ast)
end
