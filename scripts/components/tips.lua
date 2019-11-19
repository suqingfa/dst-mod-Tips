local function findentity(prefabname)
    for k,v in pairs(Ents) do
        if v.prefab == prefabname then
            return v
        end
    end
end

local function gettimespawner(t)
    local spawner = TheWorld and TheWorld.components[t.spawner]
    local data = spawner and spawner:OnSave()

    if data and t.conditionfn and not t.conditionfn(data) then
        return
    end

    return data and data[t.timetowhat]
end

local function gettimeleft(t)
    local prefab = findentity(t.prefab)
    if prefab == nil or prefab.components.timer == nil then
        return
    end

    local time
    local timer
    for _,v in ipairs(t.timer) do
        time = prefab.components.timer:TimerExists(v) and
               prefab.components.timer:GetTimeLeft(v)
        if time then
            timer = v
            break
        end
    end

    return t.adjusttimefn and t.adjusttimefn(time, timer) or time
end

local deerclops_attackduringoffseason = 
    TheWorld and 
    TheWorld.topology.overrides and 
    TheWorld.topology.overrides.deerclops == "always"

local tips_list = {
    {
        name = "hound",
        aliases = {"hd", "wm", "worm"},
        gettimefn = gettimespawner, 
        spawner = "hounded",
        timetowhat = "timetoattack",
    },

    {
        name = "deerclops",
        aliases = {"dc"},
        gettimefn = gettimespawner, 
        spawner = "deerclopsspawner",
        timetowhat = "timetoattack",
        conditionfn = function(data)
            return TheWorld.state.cycles > TUNING.NO_BOSS_TIME and  
                   (deerclops_attackduringoffseason or TheWorld.state.season == "winter")
        end,
    },

    {
        name = "bearger",
        aliases = {"bg"},
        gettimefn = gettimespawner, 
        spawner = "beargerspawner",
        timetowhat = "timetospawn",
        conditionfn = function(data)
            return TheWorld.state.isautumn and
                    TheWorld.state.cycles > TUNING.NO_BOSS_TIME and 
                    (data.numSpawned < data.targetnum or 
                    (not data.lastBeargerKillDay or ((TheWorld.state.cycles - data.lastBeargerKillDay) > TUNING.NO_BOSS_TIME)))
        end
    },

    {
        name = "klaus_sack",
        aliases = {"ks"},
        gettimefn = gettimespawner, 
        spawner = "klaussackspawner", 
        timetowhat = "timetorespawn",
    },

    {
        name = "malbatross",
        aliases = {"mt"},
        gettimefn = gettimespawner, 
        spawner = "malbatrossspawner", 
        timetowhat = "_time_until_spawn",
    },

    {
        name = "toadstool",
        aliases = {"tt"},
        gettimefn = gettimespawner, 
        spawner = "toadstoolspawner", 
        timetowhat = "timetorespawn",
    },


    {
        name = "antlion",
        aliases = {"al"},
        gettimefn = gettimeleft, 
        prefab = "antlion", 
        timer = {"rage"},
    },

    {
        name = "dragonfly",
        aliases = {"df"},
        gettimefn = gettimeleft, 
        prefab = "dragonfly_spawner", 
        timer = {"regen_dragonfly"},
    },

    {
        name = "atrium_gate",
        aliases = {"ag"},
        gettimefn = gettimeleft, 
        prefab = "atrium_gate", 
        timer = {"destabilizing", "cooldown"},
        adjusttimefn = function(time, timer)
            if timer == "destabilizing" then
                return time + TUNING.ATRIUM_GATE_COOLDOWN
            end
            return time
        end
    },

    {
        name = "beequeenhive",
        aliases = {"bh"},
        gettimefn = gettimeleft, 
        prefab = "beequeenhive", 
        timer = {"hivegrowth1", "hivegrowth2", "hivegrowth"},
        adjusttimefn = function(time, timer)
            if timer == "hivegrowth1" then
                return time + TUNING.BEEQUEEN_RESPAWN_TIME * 2 / 3
            elseif timer == "hivegrowth2" then
                return time + TUNING.BEEQUEEN_RESPAWN_TIME / 3
            end
            return time
        end
    }
}

tips_index = {}
for i,v in ipairs(tips_list) do
    tips_index[v.name] = i
    for _,alias in ipairs(v.aliases) do
        tips_index[alias] = i
    end
end

autotipslist = {"hound", "antlion", "bearger", "deerclops"}
function AutoTips()
    local times = {}
    for _,v in ipairs(autotipslist) do
        local t = tips_list[tips_index[v]]
        local time = t.gettimefn(t)
        if time then
            times[v] = time
        else
            times[v] = 0
        end
    end

    for _,palyer in pairs(AllPlayers) do
        if palyer.components.tips then
            for k,v in pairs(times) do
                palyer.components.tips["net_" .. k]:set(v)
            end
        end
    end
end

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

local Tips = Class(function(self, inst)
    self.inst = inst

    for _,v in ipairs(autotipslist) do
        self["net_" .. v] = net_float(inst.GUID, "tips." .. v)
    end

    self.index = 0
    self.net_value = net_float(inst.GUID, "tips.value", "tipsevent")

    if TheNet and TheNet:GetIsServer() and TheWorld and TheWorld.AutoTipsTask == nil then
        AutoTips()
        TheWorld.AutoTipsTask = TheWorld:DoPeriodicTask(TIPS_TICK_RATE, AutoTips)
    end

    if TheNet and TheNet:IsDedicated() then
        return
    end

    inst:ListenForEvent("tipsevent", function()
        local name = tips_list[self.index] and tips_list[self.index].name
        local value = self.net_value:value()
        inst.HUD.controls.networkchatqueue:DisplaySystemMessage(name .. " " .. timetostring(value))
    end)
end)

function Tips:GetTime(what)
    local index = tips_index[what]
    if index then
        self.index = index
        SendModRPCToServer(MOD_RPC.Tips.Time, index)
    end
end

return Tips