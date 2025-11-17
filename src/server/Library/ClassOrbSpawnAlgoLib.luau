
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)



export type ClassOrbSpawnCallback = (spawnCallback: (orbName: string) -> nil) -> nil


local ClassOrbSpawnAlgoLib = {} :: {
    [string]: ClassOrbSpawnCallback
}


ClassOrbSpawnAlgoLib.Chain = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("ChainOrb")
end

ClassOrbSpawnAlgoLib.Burst = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("BurstOrb")
    spawnCallback("ArrowOrb")
end

ClassOrbSpawnAlgoLib.Reverberation = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("ReverberationOrb")


    local result = HarukaLib:RollLoot({
        EchoSharpOrb = 50,
        EchoFlatOrb = 50
    })
    spawnCallback(result)
end

ClassOrbSpawnAlgoLib.Flow = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("FlowOrb")
    spawnCallback("CatalystOrb")
end


ClassOrbSpawnAlgoLib.Furioso = function(spawnCallback: (orbName: string) -> nil)

end


ClassOrbSpawnAlgoLib.Execution = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("ExecutionOrb")
end


return ClassOrbSpawnAlgoLib