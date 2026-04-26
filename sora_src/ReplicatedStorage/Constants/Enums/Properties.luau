local enum = {}

enum.orb = {
    "orbSpawnRate",
    "orbSpawnCount",
}

enum.health = {
    "maxHealthPercent",
    "maxHealthFlat",
    "healthRegenInterval",
    "healthRegenFlat",
    "healthRegenPercent",
    "healthRegenCooldown",
}

enum.damage = {
    "meleeDamage",
    "rangedDamage",
    "magicDamage",
}

enum.crit = {
    "critChance",
    "critMulti",
}

enum.defense = {
    "defenseFlatValue",
    "defensePercentValue",
}

enum.shield = {
    "maxShield",
    "shieldRegenInterval",
    "shieldRegenFlat",
    "shieldRegenPercent",
    "shieldRegenCooldown",
}

enum.mana = {
    "maxMana",
    "manaRegenFlatPerOrb",
    "manaRegenPercentPerOrb",
}

return table.freeze(enum)