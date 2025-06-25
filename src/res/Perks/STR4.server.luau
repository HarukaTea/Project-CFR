local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local isSet = false


local function onDropped()
    local health = char.Humanoid.Health :: number
    local maxHealth = char.Humanoid.MaxHealth :: number

    if health < maxHealth * 0.4 and not isSet then
        isSet = true
        HarukaLib:AddAttr(char, "DMGResistBonusEx", 10)

    elseif health >= maxHealth * 0.4 and isSet then
        isSet = false
        HarukaLib:AddAttr(char, "DMGResistBonusEx", -10)
    end
end

Add(HarukaLib:Hydrate(char.Humanoid, {
    ["Prop-Health"] = onDropped,
    ["Prop-MaxHealth"] = onDropped
}))



script.Destroying:Connect(Empty)
char.PlayerDied.Event:Connect(Empty)
