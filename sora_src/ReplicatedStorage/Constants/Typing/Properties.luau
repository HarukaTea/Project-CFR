local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local Attributes = require(ReplicatedStorage.Constants.Enums.Properties)

export type OrbProperty = "orbSpawnRate" | "orbSpawnCount"

export type HealthProperty = "maxHealthPercent" | "maxHealthFlat" | "healthRegenInterval" | "healthRegenFlat" | "healthRegenPercent" | "healthRegenCooldown"

export type DamageType = "meleeDamage" | "rangedDamage" | "magicDamage"

export type CritProperty = "critChance" | "critMulti"

export type DefenseProperty = "defenseFlatValue" | "defensePercentValue"

export type ShieldProperty = "maxShield" | "shieldRegenInterval" | "shieldRegenFlat" | "shieldRegenPercent" | "shieldRegenCooldown"

export type ManaProperty = "maxMana" | "manaRegenFlatPerOrb" | "manaRegenPercentPerOrb"

export type AllProperties =
    OrbProperty |
    HealthProperty |
    DamageType |
    CritProperty |
    DefenseProperty |
    ShieldProperty |
    ManaProperty

local typing = {}

typing.OrbPropertyT = t.literal(table.unpack(Attributes.orb))
typing.HealthPropertyT = t.literal(table.unpack(Attributes.health))
typing.DamageTypeT = t.literal(table.unpack(Attributes.damage))
typing.CritPropertyT = t.literal(table.unpack(Attributes.crit))
typing.DefensePropertyT = t.literal(table.unpack(Attributes.defense))
typing.ShieldPropertyT = t.literal(table.unpack(Attributes.shield))
typing.ManaPropertyT = t.literal(table.unpack(Attributes.mana))

typing.AllPropertiesT = t.union(
    typing.OrbPropertyT,
    typing.HealthPropertyT,
    typing.DamageTypeT,
    typing.CritPropertyT,
    typing.DefensePropertyT,
    typing.ShieldPropertyT,
    typing.ManaPropertyT
)

return table.freeze(typing)