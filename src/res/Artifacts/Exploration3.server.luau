local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local ArtifactUniversal = require(ReplicatedStorage.HarukaRes.Artifacts.ArtifactUniversal)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local DoTLib = require(ServerScriptService.HarukaServer.Services.DoTLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")

local event = Instance.new("BindableEvent")
event.Name = "PlayerClassUltCasted"
event.Parent = script


local trueBefore = false


Add(HarukaLib:Hydrate(char, {
    ["Attr-IsInCombat"] = function(state: boolean)
        if state and trueBefore == false then
            trueBefore = true
        elseif state == false and trueBefore == true then
            trueBefore = false

            if not ServerLib.IsCharValid(char) then return end

            local healDoT = DoTLib.new({
                Target = char,
                Type = "HealOverTime",
                Creator = char,
                Power = 1,
                Duration = 5
            })
            healDoT:Activate()
        end
    end
}))


ArtifactUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)