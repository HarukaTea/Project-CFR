local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local ArtifactUniversal = require(ReplicatedStorage.HarukaRes.Artifacts.ArtifactUniversal)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local StatusLib = require(ServerScriptService.HarukaServer.Library.StatusLib)


local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")

local event = Instance.new("BindableEvent")
event.Name = "PlayerClassUltCasted"
event.Parent = script


Add(ArtifactUniversal.RegisterClassUltCasted(script, event, char, function(target: Model, caster: Model, ultMetaData: ClassUltMetaData)
    if caster:FindFirstChild("QueenBee3ArtifactCooldown") then return end

    local symbol = Instance.new("BoolValue")
    symbol.Name = "QueenBee3ArtifactCooldown"
    symbol.Value = true
    symbol.Parent = caster
    Debris:AddItem(symbol, 11)


    StatusLib.DMGBoost(caster, {
        DMGPower = 0.4,
        DMG = 0,
        Duration = 12
    })
end))


ArtifactUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)