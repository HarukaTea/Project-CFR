
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
            EnvironmentBonus = 1
        },
        BlueSlime = {
            Level = 45,
            EnvironmentBonus = 1
        }
    }
}

abyss[2] = {
    Icon = "rbxassetid://138540677700873",
    Team = {
        QueenBee = {
            Level = 99,
            EnvironmentBonus = 2
        },
        Bee = {
            Level = 60,
            EnvironmentBonus = 2
        },
    }
}

abyss[3] = {
    Icon = "rbxassetid://17543155439",
    Team = {
        CrimsonSlime = {
            Level = 125,
            EnvironmentBonus = 2
        },
        PurpleSlime = {
            Level = 100,
            EnvironmentBonus = 2
        }
    }
}

abyss[4] = {
    Icon = "rbxassetid://90390582857611",
    Team = {
        HardmodeWolf = {
            Level = 150,
            EnvironmentBonus = 3
        },
        SpikeFox = {
            Level = 125,
            EnvironmentBonus = 3
        },
    }
}


abyss[5] = {
    Icon = "rbxassetid://95284011272925",
    Team = {
        Sylvarion = {
            Level = 200,
            EnvironmentBonus = 3
        }
    }
}


return abyss