
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local DoTLib = require(ServerScriptService.HarukaServer.Services.DoTLib)


local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script


Add(AccessoryUniversal.RegisterEnemyOnHit(script, event, char, function(targeting, attacker, dmgProps)
    if dmgProps.Attacker ~= "ClassAttacks" then return end

    local result = HarukaLib:RollLoot({
        ["Debuff"] = 5,
        ["NoEffect"] = 100 - 5
    })
    if result == "Debuff" then
        local debuffObj = DoTLib.new({
            Target = targeting,
            Type = "Bleed",
            Duration = 5,
            Creator = char,
            Power = 1,
        })
        debuffObj:Activate()
    end
end))

AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)