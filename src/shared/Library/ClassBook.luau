--!nocheck

return {
	Chain = {
		Icon = "rbxassetid://80163543853288",
		Color = Color3.fromHex('#ffeaa7'),
        Type = "DMG",

        Desc = "As a <yellow>Chain</font> class, deal high damage by building <red>Combos</font>. <br/>Gain <red>Combos</font> by touching <yellow>Orbs</font>. <br/>Your <red>Combo</font> resets immediately upon landing.<br/>Not recommended for beginners.",
        Hint = "Build more combos!",

        Skills = {
            UltSkillIcon = "rbxassetid://80904500184652",
        },


        BaseStats = {
            OrbBounce = 210
        }
	},


    Burst = {
		Icon = "rbxassetid://76032666495313",
		Color = Color3.fromHex('#7bed9f'),
		Type = "DMG",

        Desc = "The <green>Burst</font> class deals high damage based on the number of <green>Arrows</font> you have. <br/>Touching a bow-shaped Orb instantly spawns an <green>Arrow Orb</font> on the field. <br/>Touching an <green>Arrow Orb</font> grants you an Arrow. <br/>Recommended for beginners.",
        Hint = "Collect more Arrows!",

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

        Desc = "<purple>Flow</font> class damage scales with your Flow amount. <br/>Each hit builds 35% Flow, culminating in a devastating burst and a <red>Burn</font> effect once Full Flow is achieved. <br/>Not ideal for new players.",
        Hint = "",

        Skills = {
            UltSkillIcon = "rbxassetid://79241468928508"
        },


        BaseStats = {
            MaxMana = 300,
        }
    },


    Reverberation = {
        Icon = "rbxassetid://120613067089872",
        Color = Color3.fromHex('#34ace0'),
		Type = "DMG",

        Desc = "",
        Hint = "",


        Skills = {
            UltSkillIcon = "rbxassetid://117298958380190",
            UltSkillWithoutRecolor = true
        },


        BaseStats = {
            SpeedCombat = 40
        }
    },

    Rise = {
        Icon = "rbxassetid://120613067089872",
        Color = Color3.fromHex('#34ace0'),
		Type = "DMG",

        Desc = "",
        Hint = "",


        Skills = {
            UltSkillIcon = "rbxassetid://117298958380190",
            UltSkillWithoutRecolor = true
        },


        BaseStats = {
            MaxHealth = 1599,
        }
    },


    Furioso = {
        Icon = "rbxassetid://128714575176870",
        Color = Color3.fromHex('#ffffff'),
        Type = "Magic",

        Desc = "",
        Hint = "",

        Skills = {
            UltSkillIcon = "rbxassetid://118519686473047",
            UltSkillWithoutRecolor = true
        },

        BaseStats = {
            ShockingChance = 10
        }
    }
}
