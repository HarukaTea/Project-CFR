--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local ArtifactUniversal = require(ReplicatedStorage.HarukaRes.Artifacts.ArtifactUniversal)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)


script:SetAttribute("ReqDestroyingEvent", true)

local added = false


Add(HarukaLib:Hydrate(plr.EquippingItems.Weapon1, {
    ["Prop-Value"] = function(weapon: string)
        weapon = weapon or ""

        local info = ItemBook:GetItemInfo(weapon)
        if not info and added then
            added = false
            char:SetAttribute("_PRIVATE_Crimson3", false)


            HarukaLib:AddAttr(char, "MagicExPower", -0.35)
            return
        end

        local hasStaff = string.find(info.ItemId, "Staff")
        if hasStaff and not added then
            added = true
            char:SetAttribute("_PRIVATE_Crimson3", true)


            HarukaLib:AddAttr(char, "MagicExPower", 0.35)

        elseif not hasStaff and added then
            added = false
            char:SetAttribute("_PRIVATE_Crimson3", false)


            HarukaLib:AddAttr(char, "MagicExPower", -0.35)
        end
    end
}))



ArtifactUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)