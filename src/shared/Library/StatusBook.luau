
export type BoostDataJSON = {
    Icon: string,
    Color: Color3,

    IconColor: Color3?
}


return {
    --// Boosts
    JumpPowerBoost = {
        Icon = "rbxassetid://4821548100",
        Color = Color3.new(1, 1, 1)
    },
    SpeedBoost = {
        Icon = "rbxassetid://4824421210",
        Color = Color3.new(1, 1, 1)
    },
    ATKBoost = {
        Icon = "rbxassetid://2965862892",
        Color = Color3.fromRGB(255, 100, 100)
    },
    MagicBoost = {
        Icon = "rbxassetid://2965863231",
        Color = Color3.fromHex('#a29bfe')
    },
    OrbBounceBoost = {
        Icon = "rbxassetid://4821548100",
        Color = Color3.new(1, 1, 1)
    },
    OrbSpawnTimeBoost = {
        Icon = "rbxassetid://82541180063318",
        Color = Color3.fromHex('#7bed9f'),
    },
    HealthBoost = {
        Icon = "rbxassetid://104142948728530",
        Color = Color3.fromHex('#7bed9f'),
        IconColor = Color3.fromHex('#2ed573')
    },


    --// custom effects
    ReverberationBoost = {
        Icon = "rbxassetid://120613067089872",
        Color = Color3.fromHex('#34ace0'),
    },
    BurstUltBoost = {
        Icon = "rbxassetid://76032666495313",
		Color = Color3.fromHex('#7bed9f'),
        IconColor = Color3.fromHex('#7bed9f')
    },
    ComboUltBoost = {
        Icon = "rbxassetid://125482694089319",
		Color = Color3.fromHex('#ffeaa7'),
        IconColor = Color3.fromHex('#ffeaa7')
    },
    FlowUltBoost = {
        Icon = "rbxassetid://100313471486816",
		Color = Color3.fromHex('#a29bfe'),
        IconColor = Color3.fromHex('#a29bfe')
    },


    --// special
    FireEmblemBoost = {
        Icon = "rbxassetid://74588474308433",
        Color = Color3.fromRGB(255, 0, 0),
    },
    WolfHowlBoost = {
        Icon = "rbxassetid://73146024586376",
        Color = Color3.fromHex('#ffeaa7'),
        IconColor = Color3.fromHex('#ffeaa7')
    },



    --// Debuffs
    BurnDebuff = {
        Icon = "rbxassetid://74588474308433",
        Color = Color3.fromRGB(255, 0, 0),
    },
    BleedDebuff = {
        Icon = "rbxassetid://101337562500575",
        Color = Color3.fromHex('#c0392b'),
    },
    BloodButcheredDebuff = {
        Icon = "rbxassetid://129041452735731",
        Color = Color3.fromHex('#c0392b'),
    },
    PoisonDebuff = {
        Icon = "rbxassetid://137874332790885",
        Color = Color3.fromHex('#845ef7'),
    },
    ShockingDebuff = {
        Icon = "rbxassetid://106465902273177",
        Color = Color3.fromHex('#ffeaa7'),
        IconColor = Color3.fromHex('#ffeaa7')
    },
    FreezingDebuff = {
        Icon = "rbxassetid://115865570364586",
        Color = Color3.fromHex('#81ecec'),
        IconColor = Color3.fromHex('#81ecec')
    },


    --// special custom
    ReverberationEchoDebuff = {
        Icon = "rbxassetid://120613067089872",
        Color = Color3.fromHex('#34ace0'),
    },
    FlowMarkDebuff = {
        Icon = "rbxassetid://100313471486816",
		Color = Color3.fromHex('#a29bfe'),
        IconColor = Color3.fromHex('#a29bfe')
    }
}