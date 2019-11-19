_G = GLOBAL
TheNet = _G.TheNet
require = _G.require

SERVER = TheNet and TheNet:GetIsServer()
CLINET = TheNet and not TheNet:IsDedicated()

_G.TIPS_TICK_RATE = GetModConfigData("tick_rate")
_G.timetostring = function (time)
    local day = math.floor(time / TUNING.TOTAL_DAY_TIME)
    time = time - day * TUNING.TOTAL_DAY_TIME
    local minute = math.floor(time / 60)
    time = time - minute * 60
    local second = math.floor(time)

    return day .. ":" .. minute .. (second < 10 and ":0" or ":") .. second
end

AddModRPCHandler("Tips", "T", function()end)

AddPlayerPostInit(function(inst)
    inst:AddComponent("tips")
end)

if CLINET then 

    modimport("client")
end

if SERVER then 
    modimport("server")
end