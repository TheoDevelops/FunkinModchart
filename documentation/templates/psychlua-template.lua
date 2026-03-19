--[[
    A recreation of 'The Mirin Template' environment
    for Psych-lua, using FunkinModchart'.

    Script by TheoDev.
]]--


-- aux functions
function run(str)
    runHaxeCode(str)
end

function parseParams(str)
    local result = {}
    local matches = {}
    
    -- is regex the best way to do this ???
    -- i used regex generator cus idk how to make them ngl
    for num, char in str:gmatch("%s*(%d+)%s*,%s*([a-zA-Z])%s*") do
        table.insert(matches, num)
        table.insert(matches, char)
    end
    
    if #matches % 2 ~= 0 then return {} end
    
    for i = 1, #matches, 2 do
        local num = tonumber(matches[i])
        local char = matches[i + 1]
        
        print(num)
        
        if not num or #char ~= 1 then return {} end
        table.insert(result, {num, char})
    end
    
    return result
end
-- setup funkin modchart manager
addHaxeLibrary('modchart.Manager')
run([[
    var funkinModchart:Manager;
    funkinModchart = new Manager();
    add(funkinModchart);

    setVar("funkinModchart", funkinModchart);
]])

-- modchart "functions"
local __ease = {
    plyr = -1,
    field = -1
}
__ease.__call = function (self, args)
    local beat, len, ease_fn, percent, mod = args[1], args[2], args[3], args[4], args[5]

    local mods = parseParams(percent);

    for _, pair in ipairs(mods) do
        local perc = pair[1]
        local mod = pair[2]

        run('getVar("funkinModchart").ease(' .. mod .. ', ' .. tostring(beat) .. ', ' .. tostring(len) .. ')')
    end
end

-- setup meta-tables
setmetatable(__ease, __ease)

return {
    ease = __ease
}