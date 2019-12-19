TheSim = _G.TheSim
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
    for _,v in ipairs(_G.autotipslist) do
        controls[v] = controls.containerroot:AddChild(TipsBadge(v))
        controls[v]:Hide()
    end
end)

local function tipsui(inst)
    inst:DoPeriodicTask(1, function()        
        local player = _G.ThePlayer

        if player == nil or player.components.tips == nil then
            return
        end

        local x = _position.x
        local y = _position.y
        for _,v in ipairs(_G.autotipslist) do
            local time = player.components.tips["net_" .. v]:value()
            if time > 0 then
                y = y - 30
                _controls[v]:SetPosition(x, y)
                _controls[v]:Show()
                _controls[v].num:SetString(_G.timetostring(time))
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

        for _,v in ipairs(_G.autotipslist) do
            local time = player.components.tips["net_" .. v]:value()
            if time > 0 then
                str = str .. v .. " " .. _G.timetostring(time) .. "\n"
            end
        end

        if #str == 0 then
            return
        end

        if tips_method == 2 and player.components.talker then
            player.components.talker:Say(str)
        elseif tips_method == 3 and player.HUD and player.HUD.controls and player.HUD.controls.networkchatqueue then
            player.HUD.controls.networkchatqueue:DisplaySystemMessage(str)
        end
    end)
end

AddPrefabPostInit("world", function (inst)
    if tips_method == 1 then
        tipsui(inst)
    else
        tipstext(inst)
    end

    local desc = "sx sy"
    for k,v in pairs(_G.tips_index) do
        if #k == 2 then
            desc = desc .. " " .. k
        end
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

            if what == "sx" or what == "sy" then
                local n = tonumber(params.num)
                if n == nil then
                    return
                end

                _position.x = what == "sx" and n or _position.x
                _position.y = what == "sy" and n or _position.y
                SavePosition()
                return
            end

            if caller.components.tips then
                caller.components.tips:GetTime(what)
            end
        end
    })
end)