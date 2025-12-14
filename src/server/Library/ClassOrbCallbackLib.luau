
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)



export type ClassOrbData = {
    UniqueId: string,
    OrbId: string,
    OrbStyle: string,
    OrbSubStyle: string?,
    OrbDuration: number,
    OrbLocation: CFrame,
    Owner: string
}

export type ClassOrbSpawnCallback = (orbData: ClassOrbData, char: Model) -> nil





local ClassOrbCallbackLib = {} :: {
    [string]: ClassOrbSpawnCallback
}


return ClassOrbCallbackLib