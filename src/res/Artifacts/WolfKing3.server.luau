
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ArtifactUniversal = require(ReplicatedStorage.HarukaRes.Artifacts.ArtifactUniversal)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local StatusLib = require(ServerScriptService.HarukaServer.Services.StatusLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")

local function _giveATK()
    local maxHealth = char.Humanoid.MaxHealth :: number
    local health = char.Humanoid.Health :: number

    if health <= maxHealth / 2 then
        if char.EffectList:FindFirstChild("WolfHowl") then return end

        StatusLib:Boost("WolfHowl", char, {
            Duration = 12,
            Ex = 25,
            Power = 0,
            TrueEffectId = "CriChance"
        })
    end
end
Add(HarukaLib:Hydrate(char.Humanoid, {
    ["Prop-Health"] = _giveATK,
    ["Prop-MaxHealth"] = _giveATK
}))

ArtifactUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)