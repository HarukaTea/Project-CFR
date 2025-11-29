
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
    local stack = 0

    for _, effSymbol: StringValue in char.EffectList:GetChildren() do
        if effSymbol.Name == "FireEmblem" then
            stack += 1
        end
    end
    if stack >= 3 then return end

    StatusLib:Boost("FireEmblem", char, {
        Duration = 10,
        Ex = 10,
        Power = 0,

        TrueEffectId = "BurnChance"
    })
end))


ArtifactUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)