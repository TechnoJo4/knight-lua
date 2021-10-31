-- gets the directory containing this file, so that we can load other files in
-- the directory. this is useful because the package may be installed anywhere,
-- so `require` is not reliable, and because we need to read the prelude file
local root = debug.getinfo(1, "S").source:match("@?(.+[/\\]).-$")
assert(root, "could not get module root")

-- load all files
local emit = loadfile(root .. "emit.lua")()
local parse = loadfile(root .. "parse.lua")()

local prelude do
    local f = io.open(root .. "prelude.lua")
    prelude = f:read("*a")
    f:close()
end

-- get lua globals (used in emit and prelude)
local luaglobal = {}
for k,v in pairs(_G) do 
    luaglobal[k] = true
end
_G.LuaGlobals = luaglobal

local function compile(code, noprelude)
    code = emit(parse.parse(parse.stream(code)))

    if noprelude then
        return code
    end

    return prelude .. code
end

local function exec(code, name)
    name = name or code
    return load(compile(code), name, "t")()
end

_G.Eval = exec

return {
    -- expose individual libraries
    emit = emit,
    parse = parse,

    -- helper functions
    compile = compile,
    exec = exec
}
