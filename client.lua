
local TipsBadge = require "widgets/tipsbadge"

local tips_method = GetModConfigData("tips_method")

local _controls = nil
AddClassPostConstruct("widgets/controls", function(controls)
    _controls = controls
    for _,v in ipairs(_G.autotipslist) do
        controls[v] = controls.containerroot:AddChild(TipsBadge(v))
        controls[v]:Hide()
    end
end)

local function tipsui(inst)
    inst:DoPeriodicTask(1, function()
        if _controls == nil or _controls.top_root == nil then 
            return 
        end
        local hudscale = _controls.top_root:GetScale()
        local screenw_full, screenh_full = _G.TheSim:GetScreenSize()
        local width = screenw_full / hudscale.x
        local height = screenh_full / hudscale.y
        local x = - width / 2 + 100
        local y = height / 2 - 0
        local player = _G.ThePlayer

        if player == nil or player.components.tips == nil then
            return
        end

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

    local desc = ""
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
        params = {"what"},
        paramsoptional = {false},
        vote = false,
        localfn = function(params, caller)
            if caller.components.tips then
                caller.components.tips:GetTime(params.what)
            end
        end
    })
end)