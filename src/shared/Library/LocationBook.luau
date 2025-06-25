
local defaultLighting = {
    Ambient = Color3.fromRGB(159, 159, 159),
    Brightness = 1.599,
    EnvironmentDiffuseScale = 0,
    EnvironmentSpecularScale = 0,
    OutdoorAmbient = Color3.fromRGB(241, 242, 246),
    ExposureCompensation = 0.15,
    FogColor = Color3.fromRGB(116, 185, 255),
    FogEnd = 1599,
    FogStart = 59
}
local tundraLighting = {
    Ambient = Color3.fromRGB(),
    Brightness = 2,
    EnvironmentDiffuseScale = 0,
    EnvironmentSpecularScale = 0,
    OutdoorAmbient = Color3.fromRGB(128, 128, 128),
    ExposureCompensation = 0.15,
    FogColor = Color3.fromRGB(0, 196, 255),
    FogEnd = 350,
    FogStart = 0
}


local book = {
    PrimisField = {
        Name = "Primis Field",
        Desc = "",

        Music = "Fareland",
        MusicVolume = 1.7,
        CombatMusic = "Conquesting",
        CombatMusicVolume = 0.7,

        LightingInfo = {
            Ambient = Color3.fromRGB(180, 180, 180),
            Brightness = 2,
            EnvironmentDiffuseScale = 0,
            EnvironmentSpecularScale = 0,
            OutdoorAmbient = Color3.fromRGB(199, 199, 199),
            ExposureCompensation = 0.15,
            FogColor = Color3.fromRGB(116, 185, 255),
            FogEnd = 1599,
            FogStart = 59
        },
        ClockTime = 2,

        RainLevel = 5
    },

    InitusBay = {
        Name = "Initus Bay",
        Desc = "",

        Music = "Fareland",
        MusicVolume = 1.7,
        CombatMusic = "KetherLibrary",
        CombatMusicVolume = 1,

        LightingInfo = defaultLighting,
        ClockTime = 14,

        RainLevel = 0,
    },

    CorruptedCavern = {
        Name = "Corrupted Cavern",
        Desc = "",

        Music = "Nest",
        MusicVolume = 0.6,
        CombatMusic = "KetherLibrary",
        CombatMusicVolume = 1,

        LightingInfo = defaultLighting,
        ClockTime = 0,
    },

    EursidaLake = {
        Name = "Eursida Lake",
        Desc = "",

        Music = "Fareland",
        MusicVolume = 1.7,
        CombatMusic = "ComplexDreams",
        CombatMusicVolume = 0.5,

        LightingInfo = defaultLighting,
        ClockTime = 14,

        RainLevel = 0,
    },

    EursidaRiver = {
        Name = "Eursida River",
        Desc = "",

        Music = "Fareland",
        MusicVolume = 1.7,
        CombatMusic = "ComplexDreams",
        CombatMusicVolume = 0.5,

        LightingInfo = defaultLighting,
        ClockTime = 14,

        RainLevel = 0,
    },

    ThyrsusWoods = {
        Name = "Thyrsus Woods",
        Desc = "",

        Music = "Fareland",
        MusicVolume = 1.7,
        CombatMusic = "ComplexDreams",
        CombatMusicVolume = 0.5,

		LightingInfo = {
			Ambient = Color3.fromRGB(115, 115, 115),
			Brightness = 1.5,
			EnvironmentDiffuseScale = 0,
			EnvironmentSpecularScale = 0,
			OutdoorAmbient = Color3.fromRGB(177, 177, 177),
			ExposureCompensation = 0.15,
			FogColor = Color3.fromRGB(13, 127, 98),
			FogEnd = 400,
			FogStart = 100
		},
        ClockTime = 0,

        RainLevel = 0.7,
    },

    Highlands = {
        Name = "Highlands",
        Desc = "",

        Music = "StepInEDITH",
        MusicVolume = 0.5,
        CombatMusic = "CantoBattleB1",
        CombatMusicVolume = 0.5,

        LightingInfo = defaultLighting,
        ClockTime = 12,

        RainLevel = 0,
    },

    VenatorVillage = {
        Name = "Venator Village",
        Desc = "",

        Music = "StepInEDITHV3",
        MusicVolume = 1,
        CombatMusic = "KetherLibrary",
        CombatMusicVolume = 0.5,

        LightingInfo = defaultLighting,
        ClockTime = 12,

        RainLevel = 0,
    },




    EmptyMobTestPlace = {
        Name = "Mob Test Dimension",
        Desc = "",

        Music = "StepInEDITHV3",
        MusicVolume = 1.2,
        CombatMusic = "KetherLibrary",
        CombatMusicVolume = 1,

        LightingInfo = {},
        ClockTime = 0,

        RainLevel = 0,
    },
    DungeonTestPlace = {
        Name = "Dungeon Dimension",
        Desc = "",

        Music = "_DUNGEON",
        MusicVolume = 1.2,
        CombatMusic = "_DUNGEON",
        CombatMusicVolume = 1,

        LightingInfo = {},
        ClockTime = 0,

        RainLevel = 0,
    },




    --// Dungeon areas
    TundraLevelD1 = {
        Name = "Unknown Tundra",
        Desc = "",

        Music = "_DUNGEON",
        MusicVolume = 1.2,
        CombatMusic = "_DUNGEON",
        CombatMusicVolume = 1,

        LightingInfo = tundraLighting,
        ClockTime = 0,

        RainLevel = 0,
    }
}
book.TundraLevelD2 = book.TundraLevelD1
book.TundraLevelD3 = book.TundraLevelD1
book.TundraLevelD4 = book.TundraLevelD1
book.TundraLevelD5 = book.TundraLevelD1
book.TundraLevelD6 = book.TundraLevelD1


return book
