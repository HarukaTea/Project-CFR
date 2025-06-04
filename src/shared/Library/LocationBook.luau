
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


return {
    PrimisField = {
        Name = "Primis Field",
        Desc = "",

        Music = "MapleStory_1",
        MusicVolume = 0.5,
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

        Music = "StepInEDITH",
        MusicVolume = 0.5,
        CombatMusic = "KeterLibrary",
        CombatMusicVolume = 1,

        LightingInfo = defaultLighting,
        ClockTime = 14,

        RainLevel = 0,
    },

    CorruptedCavern = {
        Name = "Corrupted Cavern",
        Desc = "",

        Music = "MapleStory_2",
        MusicVolume = 0.5,
        CombatMusic = "KeterLibrary",
        CombatMusicVolume = 1,

        LightingInfo = defaultLighting,
        ClockTime = 0,
    },

    EursidaLake = {
        Name = "Eursida Lake",
        Desc = "",

        Music = "Fareland",
        MusicVolume = 1.7,
        CombatMusic = "Magic!",
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
        CombatMusic = "Magic!",
        CombatMusicVolume = 0.5,

        LightingInfo = defaultLighting,
        ClockTime = 14,

        RainLevel = 0,
    },

    Highlands = {
        Name = "Highlands",
        Desc = "",

        Music = "FF_BiaoLi",
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
        CombatMusic = "KeterLibrary",
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
        CombatMusic = "KeterLibrary",
        CombatMusicVolume = 1,

        LightingInfo = {},
        ClockTime = 0,

        RainLevel = 0,
    }
}