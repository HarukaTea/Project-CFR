--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

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

    Mana: Fusion.Value,
    MaxMana: Fusion.Value,

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
                Scale = 0.9
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
                                Size = UDim2.fromScale(0.1, 0.5),
                                ZIndex = 0,
                            }),

                            HPBar(scope, {
                                HP = props.HP,
                                MaxHP = props.MaxHP,

                                Shield = props.Shield,
                                MaxShield = props.MaxShield,

                                IsHPRecovering = props.IsHPRecovering,
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
                                Size = UDim2.fromScale(1, 0.5),

                                Position = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    local state = false
                                    for _, passive: { any } in props.EquippingPassives do
                                        if ItemBook:GetItemInfo(use(passive.ItemId)) then
                                            state = true
                                            break
                                        end
                                    end

                                    if state then
                                        return UDim2.fromScale(-0.1, -2.2)
                                    else
                                        return UDim2.fromScale(-0.1, -1.5)
                                    end
                                end),

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
                            }),


                            Components.Frame(scope, {
                                Name = "ManaSection",
                                AnchorPoint = Vector2.xAxis,
                                Position = UDim2.fromScale(1, -1.15),

                                [Children] = {
                                    Components.Frame(scope, {
                                        Name = "Main",
                                        BackgroundTransparency = 0,
                                        AnchorPoint = Vector2.one,
                                        Position = UDim2.fromScale(1, 0.9),

                                        Size = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            local val = props.EquippingPassives[3]
                                            if ItemBook:GetItemInfo(use(val.ItemId)) then
                                                return UDim2.fromScale(0.775, 0.9)
                                            else
                                                return UDim2.fromScale(0.885, 0.9)
                                            end
                                        end),

                                        [Children] = {
                                            Components.RoundUICorner(scope),

                                            Components.Frame(scope, {
                                                Name = "CornerTex",
                                                BackgroundTransparency = 0,
                                                AnchorPoint = Vector2.zero,
                                                Position = UDim2.fromScale(0, 0),
                                                Size = UDim2.fromScale(0.1, 0.5),
                                                ZIndex = 0,
                                            }),
                                            Components.Frame(scope, {
                                                Name = "CornerTex",
                                                BackgroundTransparency = 0,
                                                AnchorPoint = Vector2.one,
                                                Position = UDim2.fromScale(1, 1),
                                                Size = UDim2.fromScale(0.1, 0.5),
                                                ZIndex = 0,
                                            }),

                                            Components.TextLabel(scope, {
                                                Name = "ManaStats",
                                                Position = UDim2.fromScale(0.05, 0.1),
                                                Size = UDim2.fromScale(0.9, 0.4),
                                                RichText = true,
                                                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                                                TextColor3 = Color3.fromRGB(0, 255, 255),
                                                TextXAlignment = Enum.TextXAlignment.Left,

                                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                    local mana = use(props.Mana)
                                                    local maxMana = use(props.MaxMana)

                                                    if mana > maxMana then mana = maxMana end

                                                    return `{mana}<font color="#9f9f9f"> / {maxMana}</font>`
                                                end)
                                            }),

                                            Components.Frame(scope, {
                                                Name = "ManaBar",
                                                BackgroundTransparency = 0,
                                                BackgroundColor3 = Color3.new(),
                                                AnchorPoint = Vector2.zero,
                                                Position = UDim2.fromScale(0.05, 0.6),
                                                Size = UDim2.fromScale(0.9, 0.2),

                                                [Children] = {
                                                    Components.RoundUICorner(scope),

                                                    Components.Frame(scope, {
                                                        Name = "Bar",
                                                        AnchorPoint = Vector2.zero,
                                                        Position = UDim2.fromScale(0, 0),
                                                        BackgroundTransparency = 0,
                                                        BackgroundColor3 = Color3.fromRGB(30, 144, 255),
                                                        ZIndex = 2,

                                                        Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                            local mana, maxMana = use(props.Mana) :: number, use(props.MaxMana) :: number
                                                            local x = mana / maxMana

                                                            if x ~= x then x = 0 end
                                                            x = math.clamp(x, 0, 1)

                                                            return UDim2.fromScale(x, 1)
                                                        end), AssetBook.TweenInfos.half),

                                                        [Children] = {
                                                            Components.RoundUICorner(scope)
                                                        }
                                                    }),
                                                    Components.Frame(scope, {
                                                        Name = "BarFade",
                                                        AnchorPoint = Vector2.zero,
                                                        Position = UDim2.fromScale(0, 0),
                                                        BackgroundTransparency = 0,
                                                        BackgroundColor3 = Color3.fromRGB(30, 144, 255),

                                                        Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                            local mana, maxMana = use(props.Mana) :: number, use(props.MaxMana) :: number
                                                            local x = mana / maxMana

                                                            if x ~= x then x = 0 end
                                                            x = math.clamp(x, 0, 1)

                                                            return UDim2.fromScale(x, 1)
                                                        end), AssetBook.TweenInfos.one),

                                                        [Children] = {
                                                            Components.RoundUICorner(scope)
                                                        }
                                                    })
                                                }
                                            })
                                        }
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
