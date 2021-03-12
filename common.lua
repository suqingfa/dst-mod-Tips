_G = GLOBAL
_G.setmetatable(env, {
    __index = function(t, k)
        return _G.rawget(t, k) or _G.rawget(_G, k)
    end
})

function GetConfig(name)
    return GetModConfigData(name)
end

function SetConfig(name, value)
    local mod = KnownModIndex.savedata.known_mods[modname]
    local options = mod.modinfo.configuration_options

    local saved = false

    for k,v in pairs(options) do
        if v.name == name then
            v.saved = value
            saved = true
            break
        end
    end

    if not saved then
        table.insert(options, {name = name, saved = value})
    end

    KnownModIndex:SaveConfigurationOptions(function()end, modname, options, true)
end


function GetUpValue(fn, name)
    for i=1,100 do
        local k, v = debug.getupvalue(fn, i)
        if k == nil then
            return
        elseif k == name then
            return v
        end
    end
end

function SetUpValue(fn, name, value)
    for i=1,100 do
        local k, v = debug.getupvalue(fn, i)
        if k == nil then
            return
        elseif k == name then
            debug.setupvalue(fn, i, value)
        end
    end
end

function IsHUDScreen()
    local screen = TheFrontEnd:GetActiveScreen()
    return screen and screen.name == "HUD"
end
IsInGame = IsHUDScreen

function Say(...)
    return ThePlayer and ThePlayer.components.talker and ThePlayer.components.talker:Say(...)
end
