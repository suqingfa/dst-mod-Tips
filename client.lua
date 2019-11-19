
local TipsBadge = require "widgets/tipsbadge"

local init = false
AddClassPostConstruct("widgets/controls", function(controls)
    for _,v in ipairs(_G.autotipslist) do
        controls[v] = controls.containerroot:AddChild(TipsBadge(v))
        controls[v]:Hide()
    end

    if init then
        return
    end
    init = true

    _G.TheWorld:DoPeriodicTask(1, function()
        local width, height = _G.TheSim:GetScreenSize()
        local x = - width / 2 + 260
        local y = height / 2 - 40

        if _G.ThePlayer == nil or _G.ThePlayer.components.tips == nil then
            return
        end

        for _,v in ipairs(_G.autotipslist) do
            local time = _G.ThePlayer.components.tips["net_" .. v]:value()
            if time > 0 then
                y = y - 30
                controls[v]:SetPosition(x, y)
                controls[v]:Show()
                controls[v].num:SetString(_G.timetostring(time))
            else
                controls[v]:Hide()
            end
        end
    end)


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
