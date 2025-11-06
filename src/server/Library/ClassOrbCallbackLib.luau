

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


export type ClassOrbSpawnCallback = (orbSymbol: CFrameValue, char: Model) -> nil


local ClassOrbCallbackLib = {} :: {
    [string]: ClassOrbSpawnCallback
}


ClassOrbCallbackLib.Reverberation = function(orbSymbol: CFrameValue, char: Model)
    local orbAttributes = orbSymbol:GetAttributes()
    local RNG = Random.new()

    if orbAttributes.OrbId ~= "ReverberationOrb" then return end

    orbSymbol:SetAttribute("ReverberationPitch", RNG:NextInteger(1, 9))
end


return ClassOrbCallbackLib