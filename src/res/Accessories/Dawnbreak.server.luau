
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ClassAttackLib = require(ServerScriptService.HarukaServer.Services.ClassAttackLib)
local ServerLib = require(ServerScriptService.HarukaServer.Services.ServerLib)

local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")

local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script

Add(AccessoryUniversal.RegisterEnemyOnHit(script, event, char, function(targeting, attacker, dmgProps)
    if dmgProps.Attacker ~= "ClassAttacks" then return end

    local recreation = HarukaLib:RollLoot({
        Dawn = 0.33550336,
        None = 100
    })
    if recreation == "Dawn" then
        ClassAttackLib:DealDamageToEnemy(char, targeting, {
            DMG = 33550336,
            DMGType = "DMG",
            Attacker = "Dawnbreak"
        })

        ServerLib:ShowText(char, "DAWN!", Color3.fromRGB(255, 0, 0))
    end
end))

AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)