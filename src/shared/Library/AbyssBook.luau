
local AbyssBook = {}


export type AbyssTeamJSON = {
    MobId: string,
    Level: number,
    EnvironmentBonus: number
}

AbyssBook.TeamConfigs = {
    {
        MobId = "Bee",
        Level = 100,
        EnvironmentBonus = 2
    },
    {
        MobId = "QueenBee",
        Level = 125,
        EnvironmentBonus = 2
    }
}


AbyssBook.Modifiers = {
    "HealthBoost1", "ATKBoost1", "HealthBoost2", "BurnInflict"
}
AbyssBook.ModifierIcons = {
    HealthBoost1 = "rbxassetid://82533036327440",
    ATKBoost1 = "rbxassetid://73625576595509",
    HealthBoost2 = "rbxassetid://107792957022135",
    BurnInflict = "rbxassetid://18857805491"
}
AbyssBook.ModifierInfo = {
    HealthBoost1 = "Enemy Health +50%",
    HealthBoost2 = "Enemy Health +100%",

    ATKBoost1 = "Enemy Damage +50%",
    BurnInflict = "Enemy's attack will inflict Burn"
}





return AbyssBook