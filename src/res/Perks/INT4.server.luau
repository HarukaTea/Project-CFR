local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")

local wait = task.wait


local isSet = false
local isInCD = false


local thread: thread = nil


local function onDropped()
    local mana = char:GetAttribute("Mana") or 100 :: number
    local maxMana = char:GetAttribute("MaxMana") or 100 :: number

    if mana < maxMana * 0.3 and not isSet and not isInCD then
        isSet = true
        isInCD = true

        HarukaLib:AddAttr(char, "MagicExPower", 0.08)

        thread = task.spawn(function()
            wait(5)
            HarukaLib:AddAttr(char, "MagicExPower", -0.08)
        end)
        Add(task.delay(15, function()
            isInCD = false
        end))
    elseif mana >= maxMana * 0.3 and isSet then
        isSet = false
        HarukaLib:AddAttr(char, "MagicExPower", -0.08)

        if thread then task.cancel(thread) end
    end
end

Add(HarukaLib:Hydrate(char, {
    ["Attr-Mana"] = onDropped,
    ["Attr-MaxMana"] = onDropped
}))



script.Destroying:Connect(Empty)
char.PlayerDied.Event:Connect(Empty)
