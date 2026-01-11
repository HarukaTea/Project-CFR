
export type EntityJSON = {
    Name: string,
    Icon: string,
    Tier: number,
    BaseSpeed: number,
    EnvironmentBonus: number,
    Species: string,
    Drops: {[string]: number},
    BadgeId: number?,
    IsBoss: boolean?,
    Tag: string?,
}

return {
    VARIANTS = {
        SlimePart1 = { "GreenSlime", "WheatSlime", "BlueSlime", "LapisSlime" },
        SlimePart2 = { "PurpleSlime", "EvolvedGreenSlime" },
        WolfPart1 = { "SpikeWolf", "ThornWolf", "NeedleWolf" }
    },

    --// Bee species
    Bee = {
        Name = "Bee",
        Icon = "rbxassetid://86944111865792",

        BaseSpeed = 15,
        EnvironmentBonus = 1,

        Species = "Bee",

        Drops = {
            BeeStinger = 65,
            GHoneyWings = 35,
            EarthBow = 3
        }
    },
    QueenBee = {
        Name = "Queen Bee",
        Icon = "rbxassetid://138540677700873",

        BaseSpeed = 0,
        EnvironmentBonus = 2,

        BadgeId = 2491246281240652,

        IsBoss = true,
        Species = "Bee",
        Tag = "The Hive Matriarch",

        Drops = {
            BeeStinger = 60,
            GHoneyWings = 30,
            HoneyArmor2 = 4,
            HoneyGreaves = 4,
            HoneyHeadgear = 4
        }
    },

    --// Slime species
    GreenSlime = {
        Name = "Green Slime",
        Icon = "rbxassetid://127989665826507",

        BaseSpeed = 10,
        EnvironmentBonus = 1,

        Species = "Slime",

        Drops = {
            SlimeGel = 65,
            SlimeCore = 35,
            DivineBlade = 3
        }
    },
    WheatSlime = {
        Name = "Wheat Slime",
        Icon = "rbxassetid://95488531429137",

        BaseSpeed = 10,
        EnvironmentBonus = 1,

        Species = "Slime",

        Drops = {
            SlimeGel = 65,
            SlimeCore = 35,
            DivineBlade = 3
        }
    },
    BlueSlime = {
        Name = "Blue Slime",
        Icon = "rbxassetid://16483649460",

        BaseSpeed = 10,
        EnvironmentBonus = 1,

        Species = "Slime",

        Drops = {
            SlimeGel = 65,
            SlimeCore = 35,
            DivineBlade = 3
        }
    },
    LapisSlime = {
        Name = "Lapis Slime",
        Icon = "rbxassetid://16483649287",

        BaseSpeed = 10,
        EnvironmentBonus = 1,

        Species = "Slime",

        Drops = {
            SlimeGel = 65,
            SlimeCore = 35,
            DivineBlade = 3
        }
    },
    PurpleSlime = {
        Name = "Purple Slime",
        Icon = "rbxassetid://18859513334",

        BaseSpeed = 10,
        EnvironmentBonus = 1,

        Species = "Slime",

        Drops = {
            SlimeGel = 65,
            SlimeCore = 35,
            DivineBlade = 3
        }
    },
    EvolvedGreenSlime = {
        Name = "Evolved Slime",
        Icon = "rbxassetid://127989665826507",

        BaseSpeed = 10,
        EnvironmentBonus = 1,

        Species = "Slime",

        Drops = {
            SlimeGel = 65,
            SlimeCore = 35,
            DivineBlade = 3
        }
    },
    KingSlime = {
        Name = "King Slime",
        Icon = "rbxassetid://127989665826507",

        BaseSpeed = 0,
        EnvironmentBonus = 2,

        IsBoss = true,
        Species = "Slime",
        Tag = "The King of Slimes",

        Drops = {
            SlimeGel = 65,
            SlimeCore = 35,
            SlimeKingCrown = 3,
        }
    },
    CrimsonSlime = {
        Name = "Crimson Slime",
        Icon = "rbxassetid://17543155439",

        BaseSpeed = 0,
        EnvironmentBonus = 2,

        BadgeId = 4040961258983736,

        Species = "Slime",
        IsBoss = true,
        Tag = "Core of Corruption",

        Drops = {
            CrimsonSlimeCore = 92,
            CrimsonSlimeFang = 8,
        }
    },

    --// Fox species
    SpikeFox = {
        Name = "Spike Fox",
        Icon = "rbxassetid://83984279260426",

        BaseSpeed = 20,
        EnvironmentBonus = 1,

        Species = "Fox",

        Drops = {
            SpikyFur = 65,
            SpikyQuills = 35,
            ForestStaff = 3
        }
    },
    SpikeWolf = {
        Name = "Spike Wolf",
        Icon = "rbxassetid://84531227101465",

        BaseSpeed = 25,
        EnvironmentBonus = 1,

        Species = "Fox",

        Drops = {
            SpikyFur = 65,
            SpikyQuills = 35,
            ForestStaff = 3
        }
    },
    ThornWolf = {
        Name = "Thorn Wolf",
        Icon = "rbxassetid://84531227101465",

        BaseSpeed = 25,
        EnvironmentBonus = 1,

        Species = "Fox",

        Drops = {
            SpikyFur = 65,
            SpikyQuills = 35,
            ForestStaff = 3
        }
    },
    NeedleWolf = {
        Name = "Needle Wolf",
        Icon = "rbxassetid://84531227101465",

        BaseSpeed = 25,
        EnvironmentBonus = 1,

        Species = "Fox",

        Drops = {
            SpikyFur = 65,
            SpikyQuills = 35,
            ForestStaff = 3
        }
    },
    IceWolf = {
        Name = "Ice Wolf",
        Icon = "rbxassetid://18857836675",

        BaseSpeed = 25,
        EnvironmentBonus = 1,

        Species = "Fox",

        Drops = {
            SpikyFur = 65,
            SpikyQuills = 35,
            ForestStaff = 3
        }
    },
    HardmodeWolf = {
        Name = "Hardmode Wolf",
        Icon = "rbxassetid://90390582857611",

        BaseSpeed = 0,
        EnvironmentBonus = 2,

        BadgeId = 467703311828658,

        IsBoss = true,
        Species = "Fox",
        Tag = "The Dire Howler",

        Drops = {
            BlackFur = 90,
            WinterHowl = 4,
            WolfKingAxe = 4,
            BlackWolfNecklace = 4
        }
    },

    --// Dragon species
    LeafDragon = {
        Name = "Leaf Dragon",
        Icon = "rbxassetid://105149911325359",

        BaseSpeed = 0,
        EnvironmentBonus = 2,

        IsBoss = true,
        Species = "Dragon",
        Tag = "The Forest Guardian",

        Drops = {
            DragonScale = 65,
            DragonFang = 10
        }
    },

    --// Risk of Rain 2 species
    Sylvarion = {
        Name = "Sylvarion",
        Icon = "rbxassetid://95284011272925",

        BaseSpeed = 0,
        EnvironmentBonus = 2,

        IsBoss = true,
        Species = "RiskRain",
        Tag = "The Forest Guardian",

        Drops = {
            DragonScale = 65,
            DragonFang = 10
        }
    }
}