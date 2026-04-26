local attributes = {}

attributes.orb = {
    "orbSpawnRate",
    "orbSpawnCount",
}

attributes.health = {
    "maxHealthPercent",
    "maxHealthFlat",
    "healthRegenInterval",
    "healthRegenFlat",
    "healthRegenPercent",
    "healthRegenCooldown",
}

attributes.damage = {
    "meleeDamage",
    "rangedDamage",
    "magicDamage",
}

attributes.crit = {
    "critChance",
    "critMulti",
}

attributes.defense = {
    "defenseFlatValue",
    "defensePercentValue",
}

attributes.shield = {
    "maxShield",
    "shieldRegenInterval",
    "shieldRegenFlat",
    "shieldRegenPercent",
    "shieldRegenCooldown",
}

attributes.mana = {
    "maxMana",
    "manaRegenFlatPerOrb",
    "manaRegenPercentPerOrb",
}

return table.freeze(attributes)