
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
    if not ServerLib:IsCharValid(char) then return end
    if not child:IsA("ObjectValue") then return end

    Events.CastItem_S_Response.Fire(plr, {
        SlotId = "Active1",
        CooldownTime = 0
    })
    Events.CastItem_S_Response.Fire(plr, {
        SlotId = "Active2",
        CooldownTime = 0
    })
    Events.CastItem_S_Response.Fire(plr, {
        SlotId = "Active3",
        CooldownTime = 0
    })

    for _, cdSymbol: StringValue in workspace.MapComponents.ItemCDSymbolContainer:GetChildren() do
        if cdSymbol.Name == plr.Name then
            cdSymbol:Destroy()
        end
    end
end))

AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)