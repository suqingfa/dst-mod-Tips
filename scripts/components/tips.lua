local Tips = Class(function(self, inst)
    self.inst = inst
    self.onreceivefn = nil
    self.sendjson = {autolist = {}, manuallist = {}}
    self.json = {autolist = {}, manuallist = {}}
    self.net_json = net_string(inst.GUID, "tips.json", "tipsevent")

    inst:ListenForEvent("tipsevent", function()
        self.json = json.decode(self.net_json:value())
        if self.onreceivefn ~= nil then
            self:onreceivefn(self.json)
        end
    end)
end)

function Tips:SetReceiveFn(fn)
    self.onreceivefn = fn
end

function Tips:SetAutoValue(k, v)
    self.sendjson.autolist[k] = v
end

function Tips:GetAutoValue(k)
    return self.json.autolist[k]
end

function Tips:SetManualValue(k, v)
    self.sendjson.manuallist[k] = v
end

function Tips:GetManuakValue(k)
    return self.json.manuallist[k]
end

function Tips:Send()
    local jsonstr = json.encode(self.sendjson)
    self.net_json:set(jsonstr)
    self.net_json:set_local(jsonstr)
    self.sendjson = {autolist = {}, manuallist = {}}
end

return Tips