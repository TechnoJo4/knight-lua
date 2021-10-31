local s_match = string.match

-- string with position and helper functions
local _stream = {
    go = function(s, pos)
        s.pos = pos
        return s.str:sub(pos, pos)
    end,
    match = function(s, pat)
        return s_match(s.str, pat, s.pos)
    end
}

local function stream(str)
    local self = {
        str = str, pos = 1
    }

    if type(str) ~= "string" then
        print("error: cannot parse")
        os.exit()
    end

    for k,v in pairs(_stream) do
        self[k] = v
    end

    return self
end

-- knight functions
local funcs = {
    T = 0, F = 0, N = 0, P = 0, R = 0,

    ["`"] = 1, ["!"] = 1,
    E = 1, B = 1, C = 1, Q = 1, L = 1, D = 1, O = 1, A = 1, V = 1, U = 1,

    ["+"] = 2, ["-"] = 2, ["*"] = 2, ["/"] = 2, ["%"] = 2, ["^"] = 2,
    ["<"] = 2, [">"] = 2, ["?"] = 2, ["&"] = 2, ["|"] = 2,
    [";"] = 2, ["="] = 2, W = 2,

    I = 3, G = 3, S = 4
}

-- token types
local FUN, VAR, STR, NUM = "fun", "var", "str", "num"

local function token(s)
    if s.pos > #s.str then
        print("error: unexpected <eof>")
        os.exit()
    end

    local WHITESPACE = "[ \t\r\n:(){}%[%]]*()"
    local c = s:go(s:match("^"..WHITESPACE))
    while c == "#" do
        c = s:go(s:match("^.-\n" .. WHITESPACE))
    end

    if c >= "0" and c <= "9" then
        local num, pos = s:match("^([0-9]*)()")
        s:go(pos)
        return { NUM, num }
    end

    if c >= "A" and c <= "Z" then
        if not funcs[c] then
            print(("error: function %q does not exist"):format(c))
            os.exit()
        end

        s:go(s:match("^[A-Z_]+()"))
        return { FUN, c, funcs[c] }
    end

    if funcs[c] then
        s.pos = s.pos + 1
        return { FUN, c, funcs[c] }
    end

    if (c >= "a" and c <= "z") or c == "_" then
        local name, pos = s:match("^([_a-z0-9]*)()")
        s:go(pos)
        return { VAR, name }
    end

    if c == "'" or c == '"' then
        local content, pos = s:match("^"..c.."(.-)"..c.."()")
        s:go(pos)
        return { STR, content }
    end

    if c == "" then
        print("error: unexpected <eof>")
    else
        print(("error: unexpected character %q"):format(c))
    end
    os.exit()
end

local LIT = "lit"

local function parse(s, tok)
    if not tok then
        tok = token(s)
    end

    local ttype = tok[1]
    local value = tok[2]

    if ttype == VAR then
        return { "V", value }
    end

    if ttype == STR then
        return { LIT, ("%q"):format(value) }
    end

    if ttype == NUM then
        return { LIT, value }
    end

    if ttype == FUN then
        local arity = tok[3]

        if arity == 0 then
            if value == "T" then
                return { LIT, "true" }
            end

            if value == "F" then
                return { LIT, "false" }
            end

            if value == "N" then
                return { LIT, "nil" }
            end

            return { value }
        end

        if arity == 2 then
            if value == ";" then
                local tbl = { value, parse(s) }

                tok = token(s)

                local i = 3
                while tok[1] == FUN and tok[2] == ";" do
                    tbl[i] = parse(s)
                    tok = token(s)
                    i = i + 1
                end

                tbl[i] = parse(s, tok)

                return tbl
            end

            if value == "=" then
                tok = token(s)
                if tok[1] == VAR then
                    return { value, tok[2], parse(s) }
                end

                print(("error: non-variable first argument to '='"):format(c))
                os.exit()
            end
        end

        local ast = { value }
        for i=2,arity+1 do
            ast[i] = parse(s)
        end
        return ast
    end
end

return {
    parse = parse,
    stream = stream
}
