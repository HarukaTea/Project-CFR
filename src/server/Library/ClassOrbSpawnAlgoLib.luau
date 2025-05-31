--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ClassOrbSpawnAlgoLib = {}


ClassOrbSpawnAlgoLib.Chain = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("ChainOrb")
end

ClassOrbSpawnAlgoLib.Burst = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("BurstOrb")

    local result, _, _ = HarukaLib:RollLoot({
        Arrow = 50,
        None = 50
    })

    if result == "Arrow" then
        spawnCallback("ArrowOrb")
    end
end

ClassOrbSpawnAlgoLib.Reverberation = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("ReverberationOrb")


    local result, _, _ = HarukaLib:RollLoot({
        Echo = 25,
        None = 100 - 25
    })


    if result == "Echo" then
        spawnCallback("EchoOrb")
    end
end

ClassOrbSpawnAlgoLib.Flow = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("FlowOrb")
end


ClassOrbSpawnAlgoLib.Rise = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("RiseOrb")
end



return ClassOrbSpawnAlgoLib
