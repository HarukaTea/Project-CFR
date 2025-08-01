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


    ClassAttackLib:_DealDamageToEnemy(char, targeting, {
        DMG = dmgProps.DMG,
        DMGType = "Physical",
        Attacker = "VITBonusAttack"
    })
end))



script.Destroying:Connect(Empty)
char.PlayerDied.Event:Connect(Empty)
