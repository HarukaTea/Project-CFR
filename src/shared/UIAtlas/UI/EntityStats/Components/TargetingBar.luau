--!nocheck

local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local EntityBook = require(RepS.HarukaShared.Library.EntityBook)


local Children = Fusion.Children


return function(scope: Fusion.Scope, props: {
    Targeting: ObjectValue,
    TargetingEnemy: Fusion.Value
})
    if not ClientLib:IsCharValid(props.Targeting.Value) then return nil end

    local targeting = props.Targeting.Value :: Model

    if not EntityBook[targeting.Name] then return nil end


    local function Value(val: any): Fusion.Value
        return Fusion.Value(scope, val)
    end
    local level = Value(1)

    table.insert(scope, HarukaLib:Hydrate(targeting, {
        ["Attr-Level"] = function(val: number)
            level:set(val)
        end
    }))

    local uniqueId = HttpService:GenerateGUID(false)


    local bar = Components.Frame(scope, {
        Name = "Targeting_"..uniqueId,
        Size = UDim2.fromScale(0.32, 0.6),
        BackgroundTransparency = 0,

        [Children] = {
            Components.RoundUICorner(scope),

            Components.Frame(scope, {
                Name = "CornerTex",
                BackgroundTransparency = 0,
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(0.1, 0.5)
            }),

            Components.Frame(scope, {
                Name = "TitleSection",

                [Children] = {
                    Components.UIListLayout(scope, {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0.03, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }),

                    Components.PaddingFrame(scope, "ZZZ"),

                    Components.IconImageLabel(scope, {
                        Size = UDim2.fromScale(1.2, 1.2),
                        LayoutOrder = 3,

                        Image = EntityBook[targeting.Name].Icon,

                        [Children] = {
                            Components.UIStroke(scope, {
                                Thickness = 3,
                                Color = Components.WHITE_COLOR,

                                [Children] = {
                                    Components.UIGradient(scope, {
                                        Transparency = NumberSequence.new({
                                            NumberSequenceKeypoint.new(0, 0),
                                            NumberSequenceKeypoint.new(0.998, 0),
                                            NumberSequenceKeypoint.new(0.999, 1),
                                            NumberSequenceKeypoint.new(1, 1)
                                        })
                                    })
                                }
                            })
                        }
                    }),

                    Components.TextLabel(scope, {
                        Name = "EnemyLevel",
                        LayoutOrder = 2,
                        Size = UDim2.fromScale(0, 0.8),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Components.WHITE_COLOR,
                        AutomaticSize = Enum.AutomaticSize.X,
                        TextColor3 = Components.BLACK_COLOR,

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `Lv.{use(level)}`
                        end),

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.UIPadding(scope, {
                                PaddingTop = UDim.new(0.05, 0),
                                PaddingBottom = UDim.new(0.05, 0),
                                PaddingLeft = UDim.new(0.05, 0),
                                PaddingRight = UDim.new(0.05, 0)
                            })
                        }
                    }),

                    Components.TextLabel(scope, {
                        Name = "EnemyName",
                        LayoutOrder = 1,
                        Size = UDim2.fromScale(0, 0.8),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        AutomaticSize = Enum.AutomaticSize.X,
                        RichText = true,

                        Text = EntityBook[targeting.Name].Name,

                        [Children] = {
                            Components.UIPadding(scope, {
                                PaddingTop = UDim.new(0.05, 0),
                                PaddingBottom = UDim.new(0.05, 0),
                                PaddingLeft = UDim.new(0.05, 0),
                                PaddingRight = UDim.new(0.05, 0)
                            })
                        }
                    })
                }
            }),
        }
    })


    local absoluteEffectListSize = Value(Vector2.zero)
    local absoluteAmount = Value(Vector2.zero)
    local bar2 = Components.Frame(scope, {
        Name = "Targeting_"..uniqueId.."_EffectList",
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.fromScale(1, 0.4),

        [Fusion.Out("AbsoluteSize")] = absoluteEffectListSize,

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(absoluteAmount).X > 0
        end),

        [Children] = {
            Components.Frame(scope, {
                Name = "EffectList",

                [Children] = {
                    Components.UIGridLayout(scope, {
                        CellSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local y = use(absoluteEffectListSize).Y

                            return UDim2.fromOffset(y, y)
                        end),
                        SortOrder = Enum.SortOrder.Name,
                        StartCorner = Enum.StartCorner.TopRight,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,

                        [Fusion.Out("AbsoluteCellCount")] = absoluteAmount,
                    }),
                }
            }),
        }
    })


    --// track effect list
    ClientLib:TrackEffectListToUI({
        Target = targeting,
        Scope = scope,
        GuiContainer = bar2
    })


    local humanoid = targeting.Humanoid :: Humanoid
    local function _updateHealth()
        local x = humanoid.Health / humanoid.MaxHealth

        if x ~= x then x = 0 end
        x = math.clamp(x, 0, 0.998)

        local result = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(x, 0),
            NumberSequenceKeypoint.new(x + 0.001, 1),
            NumberSequenceKeypoint.new(1, 1)
        })
        HarukaLib:Tween(bar.TitleSection.Icon.UIStroke.UIGradient, AssetBook.TweenInfos.half, { Transparency = result })
    end
    table.insert(scope, HarukaLib:Hydrate(targeting.Humanoid, {
        ["Prop-Health"] = _updateHealth,
        ["Prop-MaxHealth"] = _updateHealth,
    }))


    return {
        bar, bar2
    }
end
