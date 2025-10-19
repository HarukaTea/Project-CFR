--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script



Add(AccessoryUniversal.RegisterEnemyOnHit(script, event, char, function(targeting, attacker, dmgProps)
    if dmgProps.Attacker ~= "ClassAttacks" then return end
    if char:FindFirstChild("Northerner3ArtifactCooldown") then return end

    local symbol = Instance.new("BoolValue")
    symbol.Name = "Northerner3ArtifactCooldown"
    symbol.Value = true
    symbol.Parent = char
    Debris:AddItem(symbol, 2.5)


    HarukaLib:AddAttr(char, "ClassUltProgress", math.ceil(char:GetAttribute("MaxClassUltProgress") * 0.1))
end))

AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)