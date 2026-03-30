
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ClassSlot = require(script.Parent.ClassSlot)
local DMGStat = require(script.Parent.DMGStat)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Class: Fusion.Value<string>,

    EquippingPassives: {
        {
            Id: string,
            ItemId: Fusion.Value<string>,
            ItemUniqueId: Fusion.Value<string>,
        }
    },
    EquippingItems: Fusion.Value<{ StringValue }>,

    MinDMG: Fusion.Value<number>,
    MaxDMG: Fusion.Value<number>,
    Magic: Fusion.Value<number>,

    Gold: Fusion.Value<number>
})

    return Fusion.Hydrate(scope, Components:RefUI("CharacterStats_PStats1_1", false, true))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("DivStats_PStats1_1", false))({
                Name = "Div",

                [Children] = {
                    ClassSlot(scope, {
                        Class = props.Class,
                        EquippingPassives = props.EquippingPassives,
                        EquippingItems = props.EquippingItems,
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("MainStats_PStats1_1", false, true))({
                        Name = "Main",

                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("DMGStats_PStats1_1", false, true))({
                                [Children] = {
                                    DMGStat(scope, {
                                        StatId = "DMG",
                                        StatValue = props.MinDMG,
                                        StatValue2 = props.MaxDMG,
                                        LayoutOrder = 2,
                                    }),
                                    DMGStat(scope, {
                                        StatId = "Magic",
                                        StatValue = props.Magic,
                                        LayoutOrder = 1,
                                    }),
                                    DMGStat(scope, {
                                        StatId = "Gold",
                                        StatValue = props.Gold,
                                        LayoutOrder = -1
                                    })
                                }
                            }),
                        }
                    })
                }

            })
        }
    })
end