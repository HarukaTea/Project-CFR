
local abyss = {}


export type AbyssTeamJSON = {
    [string]: {
        Level: number,
        EnvironmentBonus: number
    }
}


abyss[1] = {
    Icon = "rbxassetid://107792957022135",
    Team = {
        KingSlime = {
            Level = 75,
            EnvironmentBonus = 2
        },
        BlueSlime = {
            Level = 45,
            EnvironmentBonus = 2
        }
    }
}

abyss[2] = {
    Icon = "rbxassetid://138540677700873",
    Team = {
        QueenBee = {
            Level = 99,
            EnvironmentBonus = 3
        },
        Bee = {
            Level = 60,
            EnvironmentBonus = 3
        },
    }
}

abyss[3] = {
    Icon = "rbxassetid://17543155439",
    Team = {
        CrimsonSlime = {
            Level = 125,
            EnvironmentBonus = 4
        },
        PurpleSlime = {
            Level = 100,
            EnvironmentBonus = 4
        }
    }
}

abyss[4] = {
    Icon = "rbxassetid://90390582857611",
    Team = {
        HardmodeWolf = {
            Level = 150,
            EnvironmentBonus = 5
        },
        SpikeFox = {
            Level = 125,
            EnvironmentBonus = 5
        },
    }
}


abyss[5] = {
    Icon = "rbxassetid://95284011272925",
    Team = {
        Sylvarion = {
            Level = 200,
            EnvironmentBonus = 6
        }
    }
}


abyss[6] = {
    Icon = "rbxassetid://16483654080",
    Team = {
        LavaWolf = {
            Level = 300,
            EnvironmentBonus = 10
        },
        SpikeFox = {
            Level = 200,
            EnvironmentBonus = 10
        }
    }
}


return abyss