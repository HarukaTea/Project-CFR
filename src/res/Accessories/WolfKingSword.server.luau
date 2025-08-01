local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local HarukaDoT = require(ServerScriptService.HarukaServer.Shared.HarukaDoT)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script



Add(event.Event:Connect(function(targeting: Model, attacker: Model, dmgProps: {
    DMG: number,
    Attacker: string
})
    if script == nil then return end
    if script.Parent == nil then return end
    if attacker ~= char then return end
    if not dmgProps then return end
    if not dmgProps.DMG then return end
    if not dmgProps.Attacker then return end
    if dmgProps.Attacker ~= "ClassAttacks" then return end

    local result = HarukaLib:RollLoot({
        ["Debuff"] = 5,
        ["NoEffect"] = 100 - 5
    })
    if result == "Debuff" then
        local debuffObj = HarukaDoT.new({
            Target = targeting,
            Type = "Bleed",
            Duration = 5,
            Creator = char,
            Power = 1,
        })
        debuffObj:Activate()
    end
end))



script.Destroying:Connect(Empty)
char.PlayerDied.Event:Connect(Empty)
