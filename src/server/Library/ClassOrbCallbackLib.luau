

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


export type ClassOrbSpawnCallback = (orbSymbol: CFrameValue, char: Model) -> nil


local ClassOrbCallbackLib = {} :: {
    [string]: ClassOrbSpawnCallback
}


return ClassOrbCallbackLib