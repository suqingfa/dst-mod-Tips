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

local function findentity(prefabname)
    for k,v in pairs(_G.Ents) do
        if v.prefab == prefabname then
            return v
        end
    end
end

local function getupvalue(fn, name)
    for i=1,100 do
        local k, v = _G.debug.getupvalue(fn, i)
        if k == nil then
            return
        end
        if k == name then
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

    local time = data and data[t.timetowhat]
    time = time and math.floor(time)
    return time or nil
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

    local time = t.adjusttimefn and t.adjusttimefn(time, timer) or time
    time = time and math.floor(time)
    return time or nil
end

local function getdefaultposition(t, time)
    if time and time > 0 then
        return
    end

    local ent = _G.c_findnext(t.prefab or t.name)
    if ent ~= nil then
        return ent:GetPosition():__tostring()
    end
end

local tips_list = {
    {
        name = "hound",
        aliases = {"hd", "wm", "worm"},
        gettimefn = gettimespawner, 
        getptfn = function() end,
        spawner = "hounded",
        timetowhat = "timetoattack",
    },

    {
        name = "deerclops",
        aliases = {"dc"},
        gettimefn = gettimespawner, 
        getptfn = getdefaultposition,
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
        getptfn = getdefaultposition, 
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
        getptfn = getdefaultposition,
        spawner = "klaussackspawner", 
        timetowhat = "timetorespawn",
    },

    {
        name = "malbatross",
        aliases = {"mt"},
        gettimefn = gettimespawner, 
        spawner = "malbatrossspawner", 
        timetowhat = "_time_until_spawn",
        getptfn = function(t, time)
            if time and time > 0 then
                return
            end

            if _G.TheWorld == nil or _G.TheWorld.components.malbatrossspawner == nil then
                return
            end

            local fn = _G.TheWorld.components.malbatrossspawner.OnUpdate

            local _activemalbatross = getupvalue(fn, "_activemalbatross")
            if _activemalbatross ~= nil then
                return _activemalbatross:GetPosition():__tostring()
            end

            local _shuffled_shoals_for_spawning = getupvalue(fn, "_shuffled_shoals_for_spawning")
            if _shuffled_shoals_for_spawning ~= nil then
                local max_shoals_to_test = math.ceil(#_shuffled_shoals_for_spawning * 0.25)
                local pt = {}
                for i,v in ipairs(_shuffled_shoals_for_spawning) do
                    table.insert(pt, v:GetPosition():__tostring())
                    if i == max_shoals_to_test then
                        break
                    end
                end
                return pt
            end
        end
    },

    {
        name = "toadstool",
        aliases = {"tt"},
        gettimefn = gettimespawner, 
        spawner = "toadstoolspawner", 
        timetowhat = "timetorespawn",
        getptfn = function(t, time)
            if time and time > 0 then
                return
            end
            for i=1,_G.c_countprefabs("toadstool_cap", true) do
                local toadstool_cap = _G.c_findnext("toadstool_cap")
                if toadstool_cap and toadstool_cap:HasToadstool() then
                    return toadstool_cap:GetPosition():__tostring()
                end
            end
        end
    },


    {
        name = "antlion",
        aliases = {"al"},
        gettimefn = gettimeleft, 
        getptfn = getdefaultposition, 
        prefab = "antlion", 
        timer = {"rage"},
    },

    {
        name = "dragonfly",
        aliases = {"df"},
        gettimefn = gettimeleft, 
        getptfn = getdefaultposition, 
        prefab = "dragonfly_spawner", 
        timer = {"regen_dragonfly"},
    },

    {
        name = "atrium_gate",
        aliases = {"ag"},
        gettimefn = gettimeleft, 
        getptfn = getdefaultposition,
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
        getptfn = getdefaultposition,
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


AddPlayerPostInit(function(player)
    player:AddComponent("tips")
end)

-- auto
autotipslist = {"hound", "antlion", "bearger", "deerclops"}
function AutoTips()
    local times = {}
    for _,v in ipairs(autotipslist) do
        local t = tips_list[tips_index[v]]
        local time = t:gettimefn()
        if time ~= nil and time > 0 then
            times[v] = time
        end
    end

    for _,player in pairs(_G.AllPlayers) do
        if player.components.tips then
            for k,v in pairs(times) do
                player.components.tips:SetAutoValue(k, {time = v})
            end
            player.components.tips:Send()
        end
    end
end

AddPrefabPostInit("world", function(inst)
    if SERVER then
        AutoTips()
        inst:DoPeriodicTask(1, AutoTips)
    end
end)

-- manual
AddModRPCHandler("Tips", "Time", function(inst, index)
    local t = tips_list[index]
    if t == nil then
        return
    end

    local time = t:gettimefn()
    local pt = t:getptfn(time)
    if inst.components.tips then
        inst.components.tips:SetManualValue(t.name, {time = time, pt = pt})
    end
end)

function SendRPC(what)
    local index = tips_index[what]
    if index then
        print(index)
        SendModRPCToServer(MOD_RPC.Tips.Time, index)
    end
end