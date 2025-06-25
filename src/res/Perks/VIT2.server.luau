local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")

local wait = task.wait


Add(HarukaLib.Clock(5, function()
    local maxHealth = char.Humanoid.MaxHealth

    if char.Humanoid.Health > 0 then
        char.Humanoid.Health += math.ceil(maxHealth * 0.5 / 100)
    end
end))



script.Destroying:Connect(Empty)
char.PlayerDied.Event:Connect(Empty)
