local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local ArtifactUniversal = require(ReplicatedStorage.HarukaRes.Artifacts.ArtifactUniversal)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)


local added = false


Add(HarukaLib:Hydrate(plr.EquippingItems.Weapon1, {
    ["Prop-Value"] = function(weapon: string)
        weapon = weapon or ""
        if not ItemBook:GetItemInfo(weapon) then
            added = false
            HarukaLib:AddAttr(char, "MagicExPower", -0.35)
            return
        end

        local info = ItemBook:GetItemInfo(weapon)
        if string.find(info.ItemId, "Staff") and not added then
            added = true
            HarukaLib:AddAttr(char, "MagicExPower", 0.35)

        elseif not string.find(info.ItemId, "Staff") and added then
            added = false
            HarukaLib:AddAttr(char, "MagicExPower", -0.35)
        end
    end
}))



ArtifactUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)