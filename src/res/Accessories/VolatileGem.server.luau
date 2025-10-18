--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ClassAttackLib = require(ServerScriptService.HarukaServer.Library.ClassAttackLib)

local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyStatusApplied"
event.Parent = script

local event2 = Instance.new("BindableEvent")
event2.Name = "EnemyStatusRemoved"
event2.Parent = script


Add(AccessoryUniversal.RegisterStatusApplied(script, event, char, function(targeting, attacker, statusProps)
    ClassAttackLib._DealDamageToEnemy(char, targeting, {
        DMG = math.ceil(ClassAttackLib._CalDMG("Magic", char) * 0.15),
        DMGType = "Magic",
        Attacker = "VolatileGem"
    })
end))
Add(AccessoryUniversal.RegisterEnemyStatusRemoved(script, event2, char, function(targeting, attacker, statusProps)
    ClassAttackLib._DealDamageToEnemy(char, targeting, {
        DMG = math.ceil(ClassAttackLib._CalDMG("Magic", char) * 0.05),
        DMGType = "Magic",
        Attacker = "VolatileGem"
    })
end))



AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)