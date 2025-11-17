
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")


Add(char.TargetingList.ChildRemoved:Connect(function(child: ObjectValue)
    if not ServerLib.IsCharValid(char) then return end
    if not child:IsA("ObjectValue") then return end


    --// FIXME: ghostly lantern anti-cheat
end))


AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)