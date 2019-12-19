_G = GLOBAL
TheNet = _G.TheNet
TUNING = _G.TUNING
require = _G.require

SERVER = TheNet and TheNet:GetIsServer()
CLINET = TheNet and not TheNet:IsDedicated()

AddModRPCHandler("Tips", "T", function()end)

if CLINET then 
    modimport("client")
end

if SERVER then 
    modimport("server")
end

_G.timetostring = function (time)
    local day = math.floor(time / TUNING.TOTAL_DAY_TIME)
    time = time - day * TUNING.TOTAL_DAY_TIME
    local minute = math.floor(time / 60)
    time = time - minute * 60
    local second = math.floor(time)

    return string.format("%02d:%02d:%02d", day, minute, second)
end

local function findentity(prefabname)
    for k,v in pairs(_G.Ents) do
        if v.prefab == prefabname then
            return v
        end
    end
end

local function gettimespawner(t)
    local spawner = _G.TheWorld and _G.TheWorld.components[t.spawner]
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
            local deerclops_attackduringoffseason = 
                _G.TheWorld and 
                _G.TheWorld.topology and
                _G.TheWorld.topology.overrides and 
                _G.TheWorld.topology.overrides.deerclops == "always"
            local remainingdaysinseason = _G.TheWorld and _G.TheWorld.state and _G.TheWorld.state.remainingdaysinseason
            return _G.TheWorld.state.cycles > TUNING.NO_BOSS_TIME and  
                   (deerclops_attackduringoffseason or 
                    (_G.TheWorld.state.season == "winter" and 
                        data.timetoattack and
                        remainingdaysinseason and
                        data.timetoattack < (remainingdaysinseason+1) * TUNING.TOTAL_DAY_TIME))
        end,
    },

    {
        name = "bearger",
        aliases = {"bg"},
        gettimefn = gettimespawner, 
        spawner = "beargerspawner",
        timetowhat = "timetospawn",
        conditionfn = function(data)
            return _G.TheWorld.state.isautumn and
                    _G.TheWorld.state.cycles > TUNING.NO_BOSS_TIME and 
                    (data.numSpawned < data.targetnum or 
                    (not data.lastBeargerKillDay or ((_G.TheWorld.state.cycles - data.lastBeargerKillDay) > TUNING.NO_BOSS_TIME)))
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
_G.tips_list = tips_list

tips_index = {}
_G.tips_index = tips_index
for i,v in ipairs(tips_list) do
    tips_index[v.name] = i
    for _,alias in ipairs(v.aliases) do
        tips_index[alias] = i
    end
end

autotipslist = {"hound", "antlion", "bearger", "deerclops"}
_G.autotipslist = autotipslist
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

    for _,palyer in pairs(_G.AllPlayers) do
        if palyer.components.tips then
            for k,v in pairs(times) do
                palyer.components.tips["net_" .. k]:set(v)
            end
        end
    end
end

AddPrefabPostInit("world", function(inst)
    if SERVER then
        AutoTips()
        inst:DoPeriodicTask(GetModConfigData("tick_rate"), AutoTips)
    end
end)

AddPlayerPostInit(function(inst)
    inst:AddComponent("tips")
end)