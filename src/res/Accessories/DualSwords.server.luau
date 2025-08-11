local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ClassAttackLib = require(ServerScriptService.HarukaServer.Library.ClassAttackLib)

local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script



Add(AccessoryUniversal.RegisterEnemyOnHit(script, event, char, function(targeting, attacker, dmgProps)
    if dmgProps.Attacker ~= "ClassAttacks" then return end


    local result = HarukaLib:RollLoot({
        ["Dual"] = 15,
        ["None"] = 100 - 15
    })
    if result == "Dual" then
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = dmgProps.DMG,
            DMGType = "Physical",
            Attacker = "DualSwords"
        })
    end
end))

AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)