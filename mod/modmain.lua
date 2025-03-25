modimport "common"

SERVER = TheNet and TheNet:GetIsServer()
CLINET = TheNet and not TheNet:IsDedicated()

AddModRPCHandler("Tips", "T", function()
end)

if CLINET then
    modimport("client")
end

local entities = {}

AddPrefabPostInitAny(function(inst)
    entities[inst.prefab] = inst
    inst:ListenForEvent("onremove", function()
        if entities[inst.prefab] == inst then
            entities[inst.prefab] = nil
        end
    end)
end)

local function findentity(prefabname)
    return entities[prefabname]
end

local function gettimespawner(t)
    local spawner = TheWorld and t.spawner and TheWorld.components[t.spawner]
    local data = spawner and spawner.OnSave and spawner:OnSave()

    if t.conditionfn and not t.conditionfn(data) then
        return
    end

    local time = data and data[t.timetowhat]
    time = time and math.floor(time)
    if time then
        return time
    end

    local worldsettingstimer = TheWorld and TheWorld.components.worldsettingstimer
    local ent = findentity(t.spawner or t.name)
    if ent ~= nil and ent.components ~= nil and ent.components.worldsettingstimer ~= nil then
        worldsettingstimer = ent.components.worldsettingstimer
    end

    if worldsettingstimer == nil or t.timername == nil then
        return nil
    end

    time = worldsettingstimer:GetTimeLeft(t.timername)
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
    for _, v in ipairs(t.timer) do
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

    local ent = c_findnext(t.prefab or t.name)
    if ent ~= nil then
        return ent:GetPosition():__tostring()
    end
end

local tips_list = {
    {
        name = "hound",
        aliases = { "hd", "wm", "worm" },
        getptfn = function()
        end,
        spawner = "hounded",
        timetowhat = "timetoattack",
    },

    {
        name = "deer",
        aliases = { "dr" },
        spawner = "deerherdspawner",
        timetowhat = "_timetospawn",
        getptfn = function()
            local herdlocation = TheWorld.components.deerherding.herdlocation
            if herdlocation ~= nil and herdlocation:Length() ~= 0 then
                return herdlocation:__tostring()
            end
        end,
    },

    {
        name = "prime_mate",
        aliases = { "pm" },
        getptfn = function()
        end,
        spawner = "piratespawner",
        timetowhat = "nextpiratechance",
    },

    {
        name = "deerclops",
        aliases = { "dc" },
        timername = "deerclops_timetoattack",
        conditionfn = function(data)
            return TheWorld.state.cycles > TUNING.NO_BOSS_TIME and
                    (TUNING.DEERCLOPS_ATTACKS_OFF_SEASON or TheWorld.state.season == "winter")
        end,
    },

    {
        name = "bearger",
        aliases = { "bg" },
        spawner = "beargerspawner",
        timername = "bearger_timetospawn",
        conditionfn = function(data)
            return data and TheWorld.state.isautumn and
                    TheWorld.state.cycles > TUNING.NO_BOSS_TIME and
                    data.numSpawned < data.numToSpawn and
                    (data.lastKillDay == nil or TheWorld.state.cycles - data.lastKillDay > TUNING.NO_BOSS_TIME)
        end
    },

    {
        name = "klaus_sack",
        aliases = { "ks" },
        timername = "klaussack_spawntimer",
    },

    {
        name = "malbatross",
        aliases = { "mt" },
        timername = "malbatross_timetospawn",
        getptfn = function(t, time)
            if time and time > 0 then
                return
            end

            if TheWorld == nil or TheWorld.components.malbatrossspawner == nil then
                return
            end

            local fn = TheWorld.components.malbatrossspawner.OnUpdate

            local _activemalbatross = GetUpValue(fn, "_activemalbatross")
            if _activemalbatross ~= nil then
                return _activemalbatross:GetPosition():__tostring()
            end

            local _shuffled_shoals_for_spawning = GetUpValue(fn, "_shuffled_shoals_for_spawning")
            if _shuffled_shoals_for_spawning ~= nil then
                local max_shoals_to_test = math.ceil(#_shuffled_shoals_for_spawning * 0.25)
                local pt = {}
                for i, v in ipairs(_shuffled_shoals_for_spawning) do
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
        aliases = { "tt" },
        timername = "toadstool_respawntask",
        getptfn = function(t, time)
            if time and time > 0 then
                return
            end
            for i = 1, c_countprefabs("toadstool_cap", true) do
                local toadstool_cap = c_findnext("toadstool_cap")
                if toadstool_cap and toadstool_cap:HasToadstool() then
                    return toadstool_cap:GetPosition():__tostring()
                end
            end
        end
    },

    {
        name = "crabking",
        aliases = { "ck" },
        prefab = "crabking",
        spawner = "crabking_spawner",
        timername = "regen_crabking",
    },

    {
        name = "antlion",
        aliases = { "al" },
        prefab = "antlion",
        spawner = "antlion",
        timername = "rage",
    },

    {
        name = "dragonfly",
        aliases = { "df" },
        prefab = "dragonfly_spawner",
        spawner = "dragonfly_spawner",
        timername = "regen_dragonfly",
    },

    {
        name = "atrium_gate",
        aliases = { "ag" },
        prefab = "atrium_gate",
        gettimefn = function()
            local atrium_gate = findentity("atrium_gate")
            if atrium_gate == nil then
                return nil
            end

            local worldsettingstimer = atrium_gate.components.worldsettingstimer
            if worldsettingstimer == nil then
                return nil
            end

            local time = 0
            if worldsettingstimer:ActiveTimerExists("destabilizedelay") then
                time = worldsettingstimer:GetTimeLeft("destabilizedelay") + TUNING.ATRIUM_GATE_COOLDOWN + TUNING.ATRIUM_GATE_DESTABILIZE_DELAY
            elseif worldsettingstimer:ActiveTimerExists("destabilizing") then
                time = worldsettingstimer:GetTimeLeft("destabilizing") + TUNING.ATRIUM_GATE_COOLDOWN
            elseif worldsettingstimer:ActiveTimerExists("cooldown") then
                time = worldsettingstimer:GetTimeLeft("cooldown")
            end

            return math.floor(time)
        end,
    },

    {
        name = "beequeenhive",
        aliases = { "bh" },
        gettimefn = gettimeleft,
        prefab = "beequeenhive",
        timer = { "hivegrowth1", "hivegrowth2", "hivegrowth" },
        adjusttimefn = function(time, timer)
            if timer == "hivegrowth1" then
                return time + TUNING.BEEQUEEN_RESPAWN_TIME * 2 / 3
            elseif timer == "hivegrowth2" then
                return time + TUNING.BEEQUEEN_RESPAWN_TIME / 3
            end
            return time
        end
    },

    {
        name = "lunarrift_portal",
        aliases = {"lp"},
        prefab = "lunarrift_portal",
        timername = "rift_spawn_timer"
    },

    {
        name = "daywalker",
        aliases = {"dw"},
        prefab = "daywalker",
        gettimefn = function()
            local shard_daywalkerspawner = TheWorld and TheWorld.shard and TheWorld.shard.components.shard_daywalkerspawner
            if shard_daywalkerspawner == nil or shard_daywalkerspawner:GetLocationName() ~= "cavejail" then
                return
            end

            local spawner = TheWorld.components.daywalkerspawner
            if spawner == nil or spawner.days_to_spawn == 0 or spawner.daywalker ~= nil then
                return
            end

            local time = TheWorld.components.worldstate.data.time

            return (spawner.days_to_spawn - time) * TUNING.TOTAL_DAY_TIME
        end
    },

    {
        name = "daywalker2",
        aliases = {"dw2"},
        prefab = "daywalker2",
        gettimefn = function()
            local shard_daywalkerspawner = TheWorld and TheWorld.shard and TheWorld.shard.components.shard_daywalkerspawner
            if shard_daywalkerspawner == nil or shard_daywalkerspawner:GetLocationName() ~= "cavejail" then
                return
            end

            local spawner = TheWorld.components.forestdaywalkerspawner
            if spawner == nil or spawner.days_to_spawn == 0 or spawner.daywalker ~= nil then
                return
            end

            local time = TheWorld.components.worldstate.data.time

            return (spawner.days_to_spawn - time) * TUNING.TOTAL_DAY_TIME
        end
    },
}

for i, v in ipairs(tips_list) do
    if v.gettimefn == nil then
        v.gettimefn = gettimespawner
    end
    if v.getptfn == nil then
        v.getptfn = getdefaultposition
    end
end

tips_index = {}
for i, v in ipairs(tips_list) do
    tips_index[v.name] = i
    for _, alias in ipairs(v.aliases) do
        tips_index[alias] = i
    end
end

AddPlayerPostInit(function(player)
    player:AddComponent("tips")
end)

-- auto
autotipslist = {}
for _, v in ipairs(tips_list) do
    if GetModConfigData(v.name) then
        table.insert(autotipslist, v.name)
    end
end

function AutoTips()
    local times = {}
    for _, v in ipairs(autotipslist) do
        local t = tips_list[tips_index[v]]
        local time = t:gettimefn()
        if time ~= nil and time > 0 then
            times[v] = time
        end
    end

    for _, player in pairs(AllPlayers) do
        if player.components.tips then
            for k, v in pairs(times) do
                player.components.tips:SetAutoValue(k, { time = v })
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
        inst.components.tips:SetManualValue(t.name, { time = time, pt = pt })
    end
end)

function SendRPC(what)
    local index = tips_index[what]
    if index then
        print(index)
        SendModRPCToServer(MOD_RPC.Tips.Time, index)
    end
end