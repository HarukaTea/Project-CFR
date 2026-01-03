
local AbyssBook = {}


export type AbyssTeamJSON = {
    MobId: string,
    Level: number
}

AbyssBook.TeamConfigs = {}
AbyssBook.TeamConfigs[1] = {
    {
        MobId = "KingSlime",
        Level = 125
    },
    {
        MobId = "BlueSlime",
        Level = 100
    }
}
AbyssBook.TeamConfigs[2] = {
    {
        MobId = "QueenBee",
        Level = 125
    },
    {
        MobId = "Bee",
        Level = 100
    }
}
AbyssBook.TeamConfigs[3] = {
    {
        MobId = "CrimsonSlime",
        Level = 125
    },
    {
        MobId = "PurpleSlime",
        Level = 100
    }
}
AbyssBook.TeamConfigs[4] = {
    {
        MobId = "HardmodeWolf",
        Level = 125
    },
    {
        MobId = "SpikeFox",
        Level = 100
    }
}
AbyssBook.TeamConfigs[5] = {
    {
        MobId = "Sylvarion",
        Level = 125
    },
    {
        MobId = "Bee",
        Level = 100
    }
}

AbyssBook.TeamConfigIcons = {
    "rbxassetid://127989665826507",
    "rbxassetid://138540677700873",
    "rbxassetid://17543155439",
    "rbxassetid://90390582857611",
    "rbxassetid://95284011272925",
}


AbyssBook.Modifiers = {
    "HealthBoost1", "ATKBoost1", "HealthBoost2", "BurnInflict", "BlurEffect", "HealthBoost3",
}
AbyssBook.ModifierInfo = {
    HealthBoost1 = "Enemy Health +50%",
    HealthBoost2 = "Enemy Health +100%",

    ATKBoost1 = "Enemy Damage +50%",
    BurnInflict = "Enemy's attack will inflict Burn",

    BlurEffect = "Makes screen blurry",
    HealthBoost3 = "Enemy Health +150%",
}





AbyssBook.Loots = {}
AbyssBook.Loots[1] = {
    "SlimeGel", "SlimeCore", "BatFangs", "StalkerLeaf",
}
AbyssBook.Loots[2] = {
    "BeeStinger", "GHoneyWings"
}
AbyssBook.Loots[3] = {
    "SlimeGel", "SlimeCore", "CrimsonSlimeCore", "CrimsoniteOre"
}
AbyssBook.Loots[4] = {
    "SpikyFur", "SpikyQuills", "BlackFur"
}
AbyssBook.Loots[5] = {
    "DragonFang", "DragonScale"
}
for index, _ in AbyssBook.Loots do
    table.insert(AbyssBook.Loots[index], "ColdFlame")
    table.insert(AbyssBook.Loots[index], "Gas")
    table.insert(AbyssBook.Loots[index], "Light")
end


AbyssBook.LootsChance = {}
for index, _ in AbyssBook.Loots do
    AbyssBook.LootsChance[index] = {}

    for _, loot: string in AbyssBook.Loots[index] do
        AbyssBook.LootsChance[index][loot] = 10
    end
end




return AbyssBook