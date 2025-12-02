
export type ClassJSON = {
    Icon: string,
    Color: Color3,
    Type: string,

    Skills: {
        UltSkill_WithoutRecolor: boolean?
    },
    BaseStats: {
        [string]: number
    },

    DevClass: boolean?
}



return {
	Chain = {
		Icon = "rbxassetid://125482694089319",
		Color = Color3.fromHex('#ffeaa7'),
        Type = "DMG",

        Skills = {
        },
        BaseStats = {
            OrbBounce = 210
        }
	},


    Burst = {
		Icon = "rbxassetid://76032666495313",
		Color = Color3.fromHex('#7bed9f'),
		Type = "DMG",

        Skills = {
        },


        BaseStats = {}
    },


    Flow = {
		Icon = "rbxassetid://100313471486816",
		Color = Color3.fromHex('#a29bfe'),
		Type = "Magic",

        Skills = {
        },


        BaseStats = {}
    },


    Reverberation = {
        Icon = "rbxassetid://120613067089872",
        Color = Color3.fromHex('#34ace0'),
		Type = "DMG",

        Skills = {
        },


        BaseStats = {
            SpeedCombat = 40,
            MaxClassUltProgress = 80
        }
    },


    Knight = {
        Icon = "rbxassetid://2965863677",
        Color = Color3.fromHex('#ffffff'),
        Type = "DMG",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {
            MaxHealth = 200
        }
    },


    Furioso = {
        Icon = "rbxassetid://125763677365170",
        Color = Color3.fromHex('#666666'),
        Type = "Magic",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {
            ShockingChance = 10
        }
    },

    Execution = {
        Icon = "rbxassetid://126361803830043",
        Color = Color3.fromHex('#ffffff'),
        Type = "DMG",

        Skills = {
        },

        BaseStats = {
            ShockingChance = 10
        },

        DevClass = true
    },


    Rogue = {
		Icon = "rbxassetid://12284961892",
		Color = Color3.fromHex('#ffffff'),
        Type = "DMG",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {},

        DevClass = true
	},
	Repeater = {
		Icon = "rbxassetid://12190533959",
		Color = Color3.fromHex('#ffffff'),
        Type = "DMG",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {},

        DevClass = true
	},
	Striker = {
		Icon = "rbxassetid://12190535870",
		Color = Color3.fromHex('#ffffff'),
        Type = "DMG",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {},

        DevClass = true
	},
	Alchemist = {
		Icon = "rbxassetid://12236618949",
		Color = Color3.fromHex('#ffffff'),
        Type = "Magic",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {},

        DevClass = true
	},
	Illusionist = {
		Icon = "rbxassetid://15875390788",
		Color = Color3.fromHex('#ffffff'),
        Type = "Magic",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {},

        DevClass = true
	},
    Juggernaut = {
        Icon = "rbxassetid://16654290906",
        Color = Color3.fromHex('#ffffff'),
        Type = "DMG",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {},

        DevClass = true
    },
    Reaper = {
        Icon = "rbxassetid://17667241921",
        Color = Color3.fromHex('#ffffff'),
        Type = "DMG",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {},

        DevClass = true
    },
    WindDancer = {
        Icon = "rbxassetid://18423401512",
        Color = Color3.fromHex('#ffffff'),
        Type = "DMG",

        Skills = {
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {},

        DevClass = true
    },
}