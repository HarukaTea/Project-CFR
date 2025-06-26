local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local function onDropped()
    local maxHealth = char.Humanoid.MaxHealth :: number

    local resist = maxHealth / 200
    resist = math.floor(resist)

    local trueResist = 0.5 * resist
    trueResist = math.min(10, trueResist)

    char:SetAttribute("DMGResistByVIT", trueResist)
end

Add(HarukaLib:Hydrate(char.Humanoid, {
    ["Prop-MaxHealth"] = onDropped
}))



script.Destroying:Connect(Empty)
char.PlayerDied.Event:Connect(Empty)
