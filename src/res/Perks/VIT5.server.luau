local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")

local wait = task.wait


local thread

local isSet = false
local isInCD = false


local function onDropped()
    local health = char.Humanoid.Health :: number
    local maxHealth = char.Humanoid.MaxHealth :: number

    if health < maxHealth * 0.5 and not isSet and not isInCD then
        isSet = true
        isInCD = true

        thread = HarukaLib.Clock(2, function()
            if char.Humanoid.Health > 0 then
                char.Humanoid.Health += math.ceil(char.Humanoid.MaxHealth * 0.01)
            end
        end)
        Add(task.delay(30, function()
            isInCD = false
        end))
    elseif health >= maxHealth * 0.5 and isSet then
        isSet = false

        if thread then thread() end
    end
end
Add(HarukaLib:Hydrate(char.Humanoid, {
    ["Prop-Health"] = onDropped,
    ["Prop-MaxHealth"] = onDropped
}))



script.Destroying:Connect(Empty)
char.PlayerDied.Event:Connect(Empty)
