local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)


local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script



Add(AccessoryUniversal.RegisterEnemyOnHit(script, event, char, function(targeting, attacker, dmgProps)
    if dmgProps.AttackType ~= "ClassAttacks" then return end

    char.Humanoid:TakeDamage(math.ceil(char.Humanoid.MaxHealth * 0.05))
end))


AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)
