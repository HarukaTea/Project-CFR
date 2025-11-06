
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
            UltSkillIcon = "rbxassetid://80904500184652",
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
            UltSkillIcon = "rbxassetid://119538556978639",
        },


        BaseStats = {
            MaxClassUltProgress = 70
        }
    },


    Flow = {
		Icon = "rbxassetid://100313471486816",
		Color = Color3.fromHex('#a29bfe'),
		Type = "Magic",

        Skills = {
            UltSkillIcon = "rbxassetid://79241468928508",
            UltSkill_WithoutRecolor = true
        },


        BaseStats = {}
    },


    Reverberation = {
        Icon = "rbxassetid://120613067089872",
        Color = Color3.fromHex('#34ace0'),
		Type = "DMG",

        Skills = {
            UltSkillIcon = "rbxassetid://117298958380190",
            UltSkill_WithoutRecolor = true
        },


        BaseStats = {
            SpeedCombat = 40
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
    }
}