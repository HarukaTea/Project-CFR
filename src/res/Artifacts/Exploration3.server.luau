
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local ArtifactUniversal = require(ReplicatedStorage.HarukaRes.Artifacts.ArtifactUniversal)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local StatusLib = require(ServerScriptService.HarukaServer.Library.StatusLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")

local trueBefore = false


Add(HarukaLib:Hydrate(char, {
    ["Attr-IsInCombat"] = function(state: boolean)
        if state and trueBefore == false then
            trueBefore = true
        elseif state == false and trueBefore == true then
            trueBefore = false

            if not ServerLib.IsCharValid(char) then return end
            StatusLib.HealPercentage(char, 30)
        end
    end
}))


ArtifactUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)