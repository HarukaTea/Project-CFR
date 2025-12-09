
local AbyssBook = {}


export type AbyssTeamJSON = {
    MobId: string,
    Level: number,
}

AbyssBook.TeamConfigs = {
    {
        MobId = "CrimsonSlime",
        Level = 100
    },
    {
        MobId = "KingSlime",
        Level = 100
    }
}


AbyssBook.Modifiers = {
    "HealthBoost1", "ATKBoost1", "HealthBoost2", "BlurEffect", "HealthBoost3", "BurnInflict"
}
AbyssBook.ModifierIcons = {
    HealthBoost1 = "rbxassetid://82533036327440",
    ATKBoost1 = "rbxassetid://73625576595509",
    HealthBoost2 = "rbxassetid://107792957022135",
    BlurEffect = "rbxassetid://131169724812561",
    HealthBoost3 = "rbxassetid://95756938920138",
    BurnInflict = "rbxassetid://18857805491"
}
AbyssBook.ModifierInfo = {
    HealthBoost1 = "Enemy Health +50%",
    HealthBoost2 = "Enemy Health +100%",

    ATKBoost1 = "Enemy Damage +50%",
    BlurEffect = "Makes screen blurry",

    HealthBoost3 = "Enemy Health +150%",
    BurnInflict = "Enemy's attack will inflict Burn"
}





return AbyssBook