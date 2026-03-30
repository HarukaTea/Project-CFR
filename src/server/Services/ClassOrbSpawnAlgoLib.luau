
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
end

ClassOrbSpawnAlgoLib.Flow = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("FlowOrb")
end

ClassOrbSpawnAlgoLib.Furioso = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("FuriosoOrb")
end

ClassOrbSpawnAlgoLib.Execution = function(spawnCallback: (orbName: string) -> nil)
    spawnCallback("ExecutionOrb")
end

return ClassOrbSpawnAlgoLib