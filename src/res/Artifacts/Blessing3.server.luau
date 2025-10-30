
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


Add(ArtifactUniversal.RegisterClassUltCasted(script, event, char, function(target, caster, ultMetaData)
    StatusLib.HealPercentage(char, 20)
end))


ArtifactUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)