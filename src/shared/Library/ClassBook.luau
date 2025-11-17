
export type ClassJSON = {
    Icon: string,
    Color: Color3,
    Type: string,

    Skills: {
        UltSkillIcon: string,
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
            UltSkillIcon = "rbxassetid://2965862892",
            UltSkill_WithoutRecolor = true
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
            UltSkillIcon = "rbxassetid://2965863905",
            UltSkill_WithoutRecolor = true
        },


        BaseStats = {}
    },


    Flow = {
		Icon = "rbxassetid://100313471486816",
		Color = Color3.fromHex('#a29bfe'),
		Type = "Magic",

        Skills = {
            UltSkillIcon = "rbxassetid://2965863231",
            UltSkill_WithoutRecolor = true
        },


        BaseStats = {}
    },


    Reverberation = {
        Icon = "rbxassetid://120613067089872",
        Color = Color3.fromHex('#34ace0'),
		Type = "DMG",

        Skills = {
            UltSkillIcon = "rbxassetid://121488236607929",
        },


        BaseStats = {
            SpeedCombat = 40,
            MaxClassUltProgress = 80
        }
    },


    Knight = {
        Icon = "rbxassetid://2965863677",
        Color = Color3.fromHex('#ffeaa7'),
        Type = "DMG",

        Skills = {
            UltSkillIcon = "rbxassetid://2965863677",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {
            MaxHealth = 200
        }
    },


    Furioso = {
        Icon = "rbxassetid://128714575176870",
        Color = Color3.fromHex('#ffffff'),
        Type = "Magic",

        Skills = {
            UltSkillIcon = "rbxassetid://118519686473047",
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
            UltSkillIcon = "rbxassetid://114059978330713",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {
            ShockingChance = 10
        }
    },


    Rogue = {
		Icon = "rbxassetid://12284961892",
		Color = Color3.fromRGB(255, 170, 255),
        Type = "DMG",

        Skills = {
            UltSkillIcon = "rbxassetid://0",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {}
	},
	Repeater = {
		Icon = "rbxassetid://12190533959",
		Color = Color3.fromRGB(65, 179, 255),
        Type = "DMG",

        Skills = {
            UltSkillIcon = "rbxassetid://0",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {}
	},
	Striker = {
		Icon = "rbxassetid://12190535870",
		Color = Color3.fromRGB(253, 148, 44),
        Type = "DMG",

        Skills = {
            UltSkillIcon = "rbxassetid://0",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {}
	},
	Alchemist = {
		Icon = "rbxassetid://12236618949",
		Color = Color3.fromRGB(43, 188, 93),
        Type = "Magic",

        Skills = {
            UltSkillIcon = "rbxassetid://0",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {}
	},
	Illusionist = {
		Icon = "rbxassetid://15875390788",
		Color = Color3.fromRGB(0, 255, 252),
        Type = "Magic",

        Skills = {
            UltSkillIcon = "rbxassetid://0",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {}
	},
    Juggernaut = {
        Icon = "rbxassetid://16654290906",
        Color = Color3.fromRGB(253, 148, 44),
        Type = "DMG",

        Skills = {
            UltSkillIcon = "rbxassetid://0",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {}
    },
    Reaper = {
        Icon = "rbxassetid://17667241921",
        Color = Color3.fromRGB(163, 39, 39),
        Type = "DMG",

        Skills = {
            UltSkillIcon = "rbxassetid://0",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {}
    },
    WindDancer = {
        Icon = "rbxassetid://18423401512",
        Color = Color3.fromHex('#70a1ff'),
        Type = "DMG",

        Skills = {
            UltSkillIcon = "rbxassetid://0",
            UltSkill_WithoutRecolor = true
        },

        BaseStats = {}
    },
}