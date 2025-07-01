--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ClassSlot = require(script.Parent.ClassSlot)
local HPBar = require(script.Parent.HPBar)
local DMGStat = require(script.Parent.DMGStat)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Class: Fusion.Value,

    EquippingPassives: { any },
    EquippingItems: { any },

    HP: Fusion.Value,
    MaxHP: Fusion.Value,

    Shield: Fusion.Value,
    MaxShield: Fusion.Value,

    IsHPRecovering: Fusion.Value,

    MinDMG: Fusion.Value,
    MaxDMG: Fusion.Value,
    Magic: Fusion.Value
})

    return Components.Frame(scope, {
        Name = "CharacterStats",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),

        [Children] = {
            Components.UIScale(scope, {
                Scale = 0.95
            }),

            Components.Frame(scope, {
                Name = "Div",
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(0.015, -0.2),
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
                        BackgroundTransparency = 0,

                        [Children] = {
                            Components.RoundUICorner(scope),

                            Components.Frame(scope, {
                                Name = "CornerTex",
                                BackgroundTransparency = 0,
                                AnchorPoint = Vector2.xAxis,
                                Position = UDim2.fromScale(1, 0),
                                Size = UDim2.fromScale(0.1, 0.5)
                            }),

                            HPBar(scope, {
                                HP = props.HP,
                                MaxHP = props.MaxHP,

                                Shield = props.Shield,
                                MaxShield = props.MaxShield,

                                IsHPRecovering = props.IsHPRecovering,
                            }),


                            Components.Frame(scope, {
                                Name = "EffectList",
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.fromScale(1.1, -0.9),
                                Size = UDim2.fromScale(0.875, 0.7),

                                [Children] = {
                                    Components.UIListLayout(scope, {
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        Padding = UDim.new(0.015, 0),
                                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                                        SortOrder = Enum.SortOrder.Name,
                                    })
                                }
                            }),


                            Components.TextLabel(scope, {
                                Name = "HPStats",
                                Position = UDim2.fromScale(0.15, 0.1),
                                Size = UDim2.fromScale(0.8, 0.4),
                                RichText = true,
                                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                                TextXAlignment = Enum.TextXAlignment.Left,

                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return `{use(props.HP)}<font color="#9f9f9f"> / {use(props.MaxHP)}</font>`
                                end)
                            }),
                            Components.TextLabel(scope, {
                                Name = "ShieldStats",
                                Position = UDim2.fromScale(0.15, 0.1),
                                Size = UDim2.fromScale(0.8, 0.4),
                                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                                TextXAlignment = Enum.TextXAlignment.Right,
                                TextColor3 = Color3.fromRGB(255, 234, 167),

                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(props.Shield)
                                end)
                            }),


                            Components.Frame(scope, {
                                Name = "DMGStats",
                                AnchorPoint = Vector2.zero,
                                Position = UDim2.fromScale(-0.1, -2.2),
                                Size = UDim2.fromScale(1, 0.5),

                                [Children] = {
                                    Components.UIListLayout(scope, {
                                        Padding = UDim.new(0.25, 0),
                                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                        SortOrder = Enum.SortOrder.Name
                                    }),

                                    DMGStat(scope, {
                                        StatId = "DMG",
                                        StatValue = props.MinDMG,
                                        StatValue2 = props.MaxDMG,
                                    }),

                                    DMGStat(scope, {
                                        StatId = "Magic",
                                        StatValue = props.Magic,
                                    })
                                }
                            })
                        }
                    })
                }

            })
        }
    })
end
