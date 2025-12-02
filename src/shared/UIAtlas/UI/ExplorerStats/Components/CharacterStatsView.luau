
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

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


    HalloweenCandy: Fusion.Value<number>,
    Gold: Fusion.Value<number>,
})

    return Components.Frame(scope, {
        Name = "CharacterStats",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),

        [Children] = {
            Components.UIScale(scope, {
                Scale = 0.9
            }),

            Components.Frame(scope, {
                Name = "Div",
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(0.015, -1),
                Size = UDim2.fromScale(0.33, 1),

                [Children] = {
                    ClassSlot(scope, {
                        Class = props.Class,
                        EquippingPassives = props.EquippingPassives,
                        EquippingItems = props.EquippingItems,
                    }),


                    Components.Frame(scope, {
                        Name = "Main",
                        AnchorPoint = Vector2.xAxis,
                        Position = UDim2.fromScale(1, -0.1),
                        Size = UDim2.fromScale(0.9, 1),

                        [Children] = {
                            Components.RoundUICorner(scope),

                            Components.Frame(scope, {
                                Name = "DMGStats",
                                AnchorPoint = Vector2.zero,
                                Size = UDim2.fromScale(1, 0.5),
                                Position = UDim2.fromScale(-0.1, -1.65),

                                [Children] = {
                                    Components.UIListLayout(scope, {
                                        Padding = UDim.new(0.25, 0),
                                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                    }),


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