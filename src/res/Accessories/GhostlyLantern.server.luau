--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)


Add(char.TargetingList.ChildRemoved:Connect(function(child: ObjectValue)
    if not ServerLib.IsCharValid(char) then return end
    if not child:IsA("ObjectValue") then return end


    Events.RequestToCastItem_Response.Fire(plr, {
        SlotId = "Active1",
        CooldownTime = 0
    })
    Events.RequestToCastItem_Response.Fire(plr, {
        SlotId = "Active2",
        CooldownTime = 0
    })
    Events.RequestToCastItem_Response.Fire(plr, {
        SlotId = "Active3",
        CooldownTime = 0
    })
end))


AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)