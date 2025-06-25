local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local ClassAttackLib = require(ServerScriptService.HarukaServer.Library.ClassAttackLib)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script



Add(event.Event:Connect(function(targeting: Model, attacker: Model, dmgProps: {
    DMG: number,
    Attacker: string,

    DMGType: string,
})
    if script == nil then return end
    if script.Parent == nil then return end
    if attacker ~= char then return end
    if not dmgProps then return end
    if not dmgProps.DMG then return end
    if not dmgProps.Attacker then return end
    if dmgProps.Attacker ~= "ClassAttacks" then return end

    if not dmgProps.DMGType then return end


    if dmgProps.DMGType == "Physical" then
        local bonusDMG = char.Humanoid.MaxHealth * 0.01
        bonusDMG = math.floor(bonusDMG)

        local dmg = ClassAttackLib:_CalDMG("Physical", char, {
            ForceDMG = bonusDMG
        })

        ClassAttackLib:_DealDamageToEnemy(char, targeting, {
            DMG = dmg,
            DMGType = "Physical",
            Attacker = "VITBonusAttack"
        })
    end
end))



script.Destroying:Connect(Empty)
char.PlayerDied.Event:Connect(Empty)
