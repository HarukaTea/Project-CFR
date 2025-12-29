
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script


script:SetAttribute("ReqDestroyingEvent", true)


local function _giveATK()
    local maxHealth = char.Humanoid.MaxHealth :: number
    local health = char.Humanoid.Health :: number

    char:SetAttribute("BloodSpellbookBonus", health > math.ceil(maxHealth * 0.05))
end
Add(HarukaLib:Hydrate(char.Humanoid, {
    ["Prop-Health"] = _giveATK,
    ["Prop-MaxHealth"] = _giveATK
}))


Add(AccessoryUniversal.RegisterEnemyOnHit(script, event, char, function(targeting, attacker, dmgProps)
    if dmgProps.Attacker ~= "ClassAttacks" then return end

    if not char:GetAttribute("BloodSpellbookBonus") then return end

    local dmg = math.ceil(char.Humanoid.MaxHealth * 0.05)

    char.Humanoid:TakeDamage(dmg)
    char.PlayerGotHit:Fire(char.Name, dmg, "Health")
end))

AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)
