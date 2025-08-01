local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)

local ClassAttackLib = require(ServerScriptService.HarukaServer.Library.ClassAttackLib)
local HarukaDoT = require(ServerScriptService.HarukaServer.Shared.HarukaDoT)

local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)



local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script



Add(AccessoryUniversal.RegisterEnemyOnHit(script, event, char, function(targeting, attacker, dmgProps)
    if dmgProps.Attacker ~= "ClassAttacks" then return end


    local result = HarukaLib:RollLoot({
        ["Execution"] = 2,
        ["None"] = 99
    })
    if result == "Execution" then
        ClassAttackLib:_DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib:_CalDMG("DMG", char, {
                ForceMaxDMG = true
            }) * 3),
            DMGType = "Physical",
            Attacker = "QueenBeeCrown"
        })

        for _, debuff in { "Burn", "Poison", "Bleed" } do
            local debuffObj = HarukaDoT.new({
                Target = targeting,
                Type = debuff,
                Duration = 8,
                Creator = char,
                Power = 2,
            })
            debuffObj:Activate()
        end

        ServerLib:ShowText(char, "EXECUTION!", Color3.fromRGB(255, 0, 0))
        ServerLib:ShowText(targeting, "EXECUTION!", Color3.fromRGB(255, 0, 0))
    end


    local antiHealSymbol = Instance.new("BoolValue")
    antiHealSymbol.Name = "AntiHeal"
    antiHealSymbol.Parent = char
    Debris:AddItem(antiHealSymbol, 8)
end))


AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)
