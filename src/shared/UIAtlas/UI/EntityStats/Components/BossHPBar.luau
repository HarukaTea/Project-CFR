--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local EntityBook = require(RepS.HarukaShared.Library.EntityBook)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    TargetingList: Fusion.Value
})
    return Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)

        local targetingBoss: ObjectValue = nil

        for _, symbol: ObjectValue in use(props.TargetingList) do
            if not ClientLib:IsCharValid(symbol.Value) then continue end
            if not EntityBook[symbol.Value.Name] then continue end

            if EntityBook[symbol.Value.Name].IsBoss then
                targetingBoss = symbol
                break
            end
        end


        if targetingBoss == nil then
            return nil

        elseif targetingBoss then
            local targeting = targetingBoss.Value :: Model

            local entityInfo = EntityBook[targeting.Name]

            local function Value(val: any): Fusion.Value
                return Fusion.Value(scope, val)
            end
            local level = Value(1)
            local HP = Value(100)
            local maxHP = Value(100)
            local DMGMultiplier = Value(100)
            local breakProgress = Value(0)
            local totalBreakProgress = Value(100)


            table.insert(scope, HarukaLib:Hydrate(targeting, {
                ["Attr-Level"] = function(val: number)
                    level:set(val)
                end,
                ["Attr-DMGMultiplier"] = function(val: number)
                    DMGMultiplier:set(val)
                end,
                ["Attr-BreakProgress"] = function(val: number)
                    breakProgress:set(val)
                end,
                ["Attr-TotalBreakProgress"] = function(val: number)
                    totalBreakProgress:set(val)
                end
            }))
            table.insert(scope, HarukaLib:Hydrate(targeting.Humanoid, {
                ["Prop-Health"] = function(newHP: number)
                    HP:set(newHP)
                end,
                ["Prop-MaxHealth"] = function(newMaxHP: number)
                    maxHP:set(newMaxHP)
                end
            }))


            local frame =  Components.Frame(scope, {
                Name = "BossHPBar",
                Size = UDim2.fromScale(0.4, 1),

                [Children] = {
                    Components.IconImageLabel(scope, {
                        Name = "BossIcon",
                        Position = UDim2.fromScale(-0.15, 0),
                        Size = UDim2.fromScale(1.25, 1.25),
                        Image = entityInfo.Icon,

                        [Children] = {
                            Components.ImageLabel(scope, {
                                Name = "HighlightTex",
                                AnchorPoint = Vector2.new(0, 1),
                                ZIndex = 2,
                                Position = UDim2.fromScale(-0.205, 1.18),
                                Size = UDim2.fromScale(0.655, 0.8),
                                Image = "rbxassetid://107834707321540",
                                ImageColor3 = Color3.fromRGB(255, 0, 0),
                            }),
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "EffectList",
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.fromScale(0, 1.7),
                        Size = UDim2.fromScale(0.875, 0.7),

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.015, 0),
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                                SortOrder = Enum.SortOrder.Name,
                            })
                        }
                    }),

                    Components.TextLabel(scope, {
                        Name = "BossName",
                        Size = UDim2.fromScale(1, 0.45),
                        TextXAlignment = Enum.TextXAlignment.Left,

                        Text = entityInfo.Name,

                        [Children] = {
                            Components.TextUIStroke(scope, {
                                Thickness = 2
                            })
                        }
                    }),
                    Components.TextLabel(scope, {
                        Name = "BossTag",
                        Size = UDim2.fromScale(1, 0.45),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
                        TextColor3 = Color3.fromHex('#9f9f9f'),

                        Text = entityInfo.Tag,

                        [Children] = {
                            Components.TextUIStroke(scope, {
                                Thickness = 2
                            })
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "HPBar",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0, 0.65),
                        Size = UDim2.fromScale(1, 0.3),
                        BackgroundTransparency = 0,

                        [Children] = {
                            Components.RoundUICorner(scope),


                            Components.ImageLabel(scope, {
                                Name = "HighlightTex",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                ZIndex = 0,
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(6.5, 6.5),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                Image = "rbxassetid://107834707321540",
                                ImageColor3 = Color3.fromHex('#a29bfe'),
                                ImageTransparency = 0.15,
                            }),

                            Components.Frame(scope, {
                                Name = "Bar",
                                AnchorPoint = Vector2.zero,
                                BackgroundTransparency = 0,
                                Position = UDim2.fromScale(0, 0),
                                ZIndex = 2,

                                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    local HPState, maxHPState = use(HP) :: number, use(maxHP) :: number

                                    local x = HPState / maxHPState
                                    if x ~= x then x = 0 end

                                    x = math.clamp(x, 0, 1)

                                    return UDim2.fromScale(x, 1)

                                end), AssetBook.TweenInfos.half),
                                BackgroundColor3 = Color3.fromRGB(193, 61, 57),

                                [Children] = {
                                    Components.RoundUICorner(scope)
                                }
                            }),
                            Components.Frame(scope, {
                                Name = "BarFade",
                                AnchorPoint = Vector2.zero,
                                BackgroundTransparency = 0,
                                Position = UDim2.fromScale(0, 0),

                                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    local HPState, maxHPState = use(HP) :: number, use(maxHP) :: number

                                    local x = HPState / maxHPState
                                    if x ~= x then x = 0 end

                                    x = math.clamp(x, 0, 1)

                                    return UDim2.fromScale(x, 1)

                                end), AssetBook.TweenInfos.one),
                                BackgroundColor3 = Color3.fromRGB(193, 61, 57):Lerp(Color3.new(), 0.5),

                                [Children] = {
                                    Components.RoundUICorner(scope)
                                }
                            }),

                            Components.TextLabel(scope, {
                                Name = "Stat",
                                AnchorPoint = Vector2.new(0, 0.5),
                                Position = UDim2.fromScale(0, 0.5),
                                Size = UDim2.fromScale(1, 1.5),
                                ZIndex = 3,
                                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),

                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    local HPState, maxHPState = use(HP) :: number, use(maxHP) :: number

                                    local x = HPState / maxHPState
                                    if x ~= x then x = 0 end

                                    x = math.clamp(x, 0, 1)

                                    return string.format("%.1f", x * 100).."%"
                                end),

                                [Children] = {
                                    Components.TextUIStroke(scope, {
                                        Thickness = 2
                                    })
                                }
                            }),

                            Components.TextLabel(scope, {
                                Name = "DamageMultiplier",
                                AnchorPoint = Vector2.new(0, 0.5),
                                Position = UDim2.fromScale(-0.01, 0.5),
                                Size = UDim2.fromScale(1, 1.5),
                                ZIndex = 3,
                                TextColor3 = Color3.fromRGB(255, 255, 127),

                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return `x{use(DMGMultiplier)}%`
                                end),
                                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(DMGMultiplier) > 100
                                end),

                                [Children] = {
                                    Components.TextUIStroke(scope, {
                                        Thickness = 2
                                    })
                                }
                            })
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "BreakBar",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0, 1.3),
                        Size = UDim2.fromScale(1, 0.2),
                        BackgroundTransparency = 0,

                        [Children] = {
                            Components.RoundUICorner(scope),

                            Components.Frame(scope, {
                                Name = "Bar",
                                AnchorPoint = Vector2.zero,
                                BackgroundTransparency = 0,
                                Position = UDim2.fromScale(0, 0),
                                ZIndex = 2,

                                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    local breakState, maxBreakState = use(breakProgress) :: number, use(totalBreakProgress) :: number

                                    local x = (maxBreakState - breakState) / maxBreakState
                                    if x ~= x then x = 0 end

                                    x = math.clamp(x, 0, 1)

                                    return UDim2.fromScale(x, 1)

                                end), AssetBook.TweenInfos.half),
                                BackgroundColor3 = Color3.fromRGB(253, 203, 110),

                                [Children] = {
                                    Components.RoundUICorner(scope)
                                }
                            }),
                            Components.Frame(scope, {
                                Name = "BarFade",
                                AnchorPoint = Vector2.zero,
                                BackgroundTransparency = 0,
                                Position = UDim2.fromScale(0, 0),

                                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    local breakState, maxBreakState = use(breakProgress) :: number, use(totalBreakProgress) :: number

                                    local x = (maxBreakState - breakState) / maxBreakState
                                    if x ~= x then x = 0 end

                                    x = math.clamp(x, 0, 1)

                                    return UDim2.fromScale(x, 1)

                                end), AssetBook.TweenInfos.one),
                                BackgroundColor3 = Color3.fromRGB(253, 203, 110):Lerp(Color3.new(), 0.5),

                                [Children] = {
                                    Components.RoundUICorner(scope)
                                }
                            }),

                            Components.TextLabel(scope, {
                                Name = "Title",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                AutomaticSize = Enum.AutomaticSize.X,
                                Size = UDim2.fromScale(0, 2.1),
                                ZIndex = 3,
                                Text = "BREAK",
                                BackgroundTransparency = 0,
                                BackgroundColor3 = Components.WHITE_COLOR,
                                TextColor3 = Components.BLACK_COLOR,

                                [Children] = {
                                    Components.RoundUICorner(scope),
                                    Components.UIPadding(scope, {
                                        PaddingTop = UDim.new(0, 0),
                                        PaddingBottom = UDim.new(0, 0),
                                        PaddingLeft = UDim.new(0, 12),
                                        PaddingRight = UDim.new(0, 12)
                                    })
                                }
                            }),
                        }
                    })
                }
            })


            --// track effect list
            ClientLib:TrackEffectListToUI({
                Target = targeting,
                Scope = scope,
                GuiContainer = frame
            })


            return frame
        end
    end)


end
