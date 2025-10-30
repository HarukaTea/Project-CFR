
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script



local function _giveATK()
    local maxHealth = char.Humanoid.MaxHealth :: number
    local health = char.Humanoid.Health :: number

    char:SetAttribute("BloodSpellbookBonus", health > math.ceil(maxHealth * 0.05))
end
Add(HarukaLib:Hydrate(char.Humanoid, {
    ["Prop-Health"] = _giveATK,
    ["Prop-MaxHealth"] = _giveATK
}))



Add(event.Event:Connect(function(targeting: Model, attacker: Model, dmgProps: AccessoryUniversal.DMGPropsMetaData)
    if script == nil then return end
    if script.Parent == nil then return end
    if attacker ~= char then return end
    if not ServerLib.IsCharValid(attacker) then return end
    if not dmgProps then return end
    if not dmgProps.DMG then return end
    if not dmgProps.Attacker then return end
    if dmgProps.Attacker ~= "ClassAttacks" then return end

    if not char:GetAttribute("BloodSpellbookBonus") then return end

    char.Humanoid:TakeDamage(math.ceil(char.Humanoid.MaxHealth * 0.05))
end))


AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)