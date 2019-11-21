local Tips = Class(function(self, inst)
    self.inst = inst

    for _,v in ipairs(autotipslist) do
        self["net_" .. v] = net_float(inst.GUID, "tips." .. v)
    end

    self.index = 0
    self.net_value = net_float(inst.GUID, "tips.value", "tipsevent")

    if TheNet and TheNet:IsDedicated() then
        return
    end

    inst:ListenForEvent("tipsevent", function()
        local name = tips_list[self.index] and tips_list[self.index].name
        local value = self.net_value:value()
        self.index = 0
        if name ~= nil and value > 0 then
            inst.HUD.controls.networkchatqueue:DisplaySystemMessage(name .. " " .. timetostring(value))
        end
    end)
end)

AddModRPCHandler("Tips", "Time", function(inst, index)
    local t = tips_list[index]
    if t == nil then
        return
    end

    local time = t.gettimefn(t)
    if time and inst.components.tips then
        inst.components.tips.net_value:set(time)
    end
end)

function Tips:GetTime(what)
    local index = tips_index[what]
    if index then
        self.index = index
        SendModRPCToServer(MOD_RPC.Tips.Time, index)
    end
end

return Tips