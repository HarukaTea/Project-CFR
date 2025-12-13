
local AbyssBook = {}


export type AbyssTeamJSON = {
    MobId: string,
    Level: number,
    EnvironmentBonus: number
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
        MobId = "HardmodeWolf",
        Level = 125
    },
    {
        MobId = "SpikeFox",
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
        MobId = "QueenBee",
        Level = 125
    },
    {
        MobId = "Bee",
        Level = 100
    },
}
AbyssBook.TeamConfigs[5] = {
    {
        MobId = "Sylvarion",
        Level = 125
    },
    {
        MobId = "SpikeWolf",
        Level = 100
    }
}

AbyssBook.TeamConfigIcons = {
    "rbxassetid://127989665826507",
    "rbxassetid://90390582857611",
    "rbxassetid://17543155439",
    "rbxassetid://138540677700873",
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





return AbyssBook