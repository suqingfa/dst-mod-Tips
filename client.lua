TheSim = _G.TheSim
SpawnPrefab = _G.SpawnPrefab
TUNING = _G.TUNING
tonumber = _G.tonumber
json = _G.json


local TipsBadge = require "widgets/tipsbadge"

local tips_method = GetModConfigData("tips_method")

local _controls = nil
local _position = nil

local filename = "mod_config_data/tips"

local function LoadPosition()
    TheSim:GetPersistentString(filename, function(load_success, str)
        if load_success and #str > 0 then
            local position = json.decode(str)
            if position ~= nil and type(position) == "table" then
                _position = position
                return
            end
        end

        local hudscale = _controls.top_root:GetScale()
        local screenw_full, screenh_full = TheSim:GetScreenSize()
        local width = screenw_full / hudscale.x
        local height = screenh_full / hudscale.y
        _position = {x = -width / 2 + 100, y = height / 2 }
    end)
end

local function SavePosition()
    TheSim:SetPersistentString(filename, json.encode(_position), false)
end

AddClassPostConstruct("widgets/controls", function(controls)
    _controls = controls
    LoadPosition()
    for _,v in ipairs(autotipslist) do
        controls[v] = controls.containerroot:AddChild(TipsBadge(v))
        controls[v]:Hide()
    end
end)

local function timetostring(time)
    local day = math.floor(time / TUNING.TOTAL_DAY_TIME)
    time = time - day * TUNING.TOTAL_DAY_TIME
    local minute = math.floor(time / 60)
    time = time - minute * 60
    local second = math.floor(time)

    return string.format("%02d:%02d:%02d", day, minute, second)
end

local function DisplaySystemMessage(str)
    player = _G.ThePlayer
    if player and player.HUD and player.HUD.controls and player.HUD.controls.networkchatqueue 
        and str and #str > 0 then
        player.HUD.controls.networkchatqueue:DisplaySystemMessage(str)
    end
end

local function tipsui(inst)
    inst:DoPeriodicTask(1, function()        
        local player = _G.ThePlayer

        if player == nil or player.components.tips == nil then
            return
        end

        local x = _position.x
        local y = _position.y
        for _,v in ipairs(autotipslist) do
            local value = player.components.tips:GetAutoValue(v)
            local time = nil
            if value ~= nil then
                time = value.time
            end
            if time ~= nil and time > 0 then
                y = y - 30
                _controls[v]:SetPosition(x, y)
                _controls[v]:Show()
                _controls[v].num:SetString(timetostring(time))
            else
                _controls[v]:Hide()
            end
        end
    end)
end

local function tipstext(inst)
    inst:WatchWorldState("cycles", function()
        local player = _G.ThePlayer
        if player == nil or _G.ThePlayer.components.tips == nil then
            return
        end

        local str = ""

        for _,v in ipairs(autotipslist) do
            local value = player.components.tips:GetAutoValue(v)
            local time = nil
            if value ~= nil then
                time = value.time
            end
            if time ~= nil and time > 0 then
                str = str .. v .. " " .. timetostring(time) .. "\n"
            end
        end

        if #str == 0 then
            return
        end

        if tips_method == 2 and player.components.talker then
            player.components.talker:Say(str)
        elseif tips_method == 3 then
            DisplaySystemMessage(str)
        end
    end)
end

local localfnlist = 
{
    sx = function(params, caller)
        local n = tonumber(params.num)
        if n == nil then
            return
        end
        _position.x = n
        SavePosition()
    end,

    sy = function(params, caller)
        local n = tonumber(params.num)
        if n == nil then
            return
        end
        _position.y = n
        SavePosition()
    end,

    pt = function(params, caller)
        local pt = caller:GetPosition()
        DisplaySystemMessage(pt:__tostring())
    end
}

AddPrefabPostInit("world", function (inst)
    if tips_method == 1 then
        tipsui(inst)
    else
        tipstext(inst)
    end

    local desc = ""
    for k,v in pairs(tips_index) do
        if #k == 2 then
            desc = desc .. " " .. k
        end
    end
    for k,v in pairs(localfnlist) do
        desc = desc .. " " .. k
    end
    AddUserCommand("tips", {
        aliases = {"t"},
        desc = desc,
        prettyname = nil,
        permission = _G.COMMAND_PERMISSION.USER,
        slash = true,
        usermenu = false,
        servermenu = false,
        params = {"what", "num"},
        paramsoptional = {false, true},
        vote = false,
        localfn = function(params, caller)
            local what = params.what

            local localfn = localfnlist[what]
            if localfn ~= nil then
                localfn(params, caller)
                return
            end

            SendRPC(what)
        end
    })
end)

local function miniflare_minimap(pt)
    local s, e = pt:find("[%d-.]+")
    local x = tonumber(pt:sub(s, e))

    s, e = pt:find("[%d-.]+", e + 1)
    local y = tonumber(pt:sub(s, e))

    s, e = pt:find("[%d-.]+", e + 1)
    local z = tonumber(pt:sub(s, e))

    local minimap = SpawnPrefab("miniflare_minimap")
    print("miniflare_minimap: ", pt, x, y, z)
    minimap.Transform:SetPosition(x, y, z)
    minimap:DoTaskInTime(TUNING.MINIFLARE.TIME, function()
        minimap:Remove()
    end)
end

AddPlayerPostInit(function(player)
    player:DoTaskInTime(1, function()
        if player.components.tips == nil then
            return
        end
        player.components.tips:SetReceiveFn(function(inst, json)
            local manuallist = json.manuallist
            local str = ""
            for k,v in pairs(manuallist) do
                if v.time and v.time > 0 then
                    str = string.format("%s\n%s %s", str, k, timetostring(v.time))
                end
                if v.pt then
                    local pt = v.pt 
                    if type(pt) == "string" then
                        miniflare_minimap(pt)
                    elseif type(pt) == "table" then
                        for _,v in ipairs(pt) do
                            miniflare_minimap(v)
                        end
                        pt = _G.json.encode(pt)
                    end
                    str = string.format("%s\n%s %s", str, k, pt)
                end
            end
            DisplaySystemMessage(str)
        end)
    end)
end)