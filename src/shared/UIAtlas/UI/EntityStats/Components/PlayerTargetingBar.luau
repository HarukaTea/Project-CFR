
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local EntityBook = require(RepS.HarukaShared.Library.EntityBook)


local Pinia = require(script.Parent.Parent.Pinia)


local Children = Fusion.Children


local ORDER = 1


return function(scope: Fusion.Scope, props: {
    Targeting: ObjectValue,

    TargetingEnemy: Fusion.Value<ObjectValue>,
    TargetArrowPos: Fusion.Value<UDim2>
}, self: Pinia.Self) : Frame
    if not ClientLib:IsCharValid(props.Targeting.Value) then return nil end

    local targeting = props.Targeting.Value :: Model

    if not EntityBook[targeting.Name] then return nil end


    ORDER += 2
    if ORDER > math.huge - 1 then
        ORDER = 1
    end


    local function Value<T>(val: T): Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local absContentSize = Value(Vector2.zero)


    local bar = Components.Frame(scope, {
        Name = targeting.Name,
        Size = UDim2.fromScale(0.32, 0.6),
        LayoutOrder = ORDER,

        [Children] = {
            Components.RoundUICorner(scope),

            Components.Frame(scope, {
                Name = "CornerTex",
                BackgroundTransparency = 0,
                AnchorPoint = Vector2.xAxis,
                Size = UDim2.fromScale(0.1, 0.5),
                ZIndex = 0,

                Position = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local sizeCon = use(absContentSize).X
                    sizeCon = math.clamp(sizeCon, 15, 999)
                    sizeCon += 8

                    return UDim2.new(1.05, sizeCon * -1, 0, 0)
                end)
            }),

            Components.Frame(scope, {
                Name = "BG",
                BackgroundColor3 = Components.BLACK_COLOR,
                BackgroundTransparency = 0,
                AnchorPoint = Vector2.xAxis,
                Position = UDim2.fromScale(1, 0),

                Size = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local sizeCon = use(absContentSize).X
                    sizeCon = math.clamp(sizeCon, 15, 999)
                    sizeCon += 8

                    return UDim2.new(0.05, sizeCon, 1, 0)
                end),

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.TextLabel(scope, {
                        Name = "IsTargeting",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.fromScale(1.3, 1.3),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        FontFace = Font.fromName("RobotoMono", Enum.FontWeight.Bold),
                        Text = ">",

                        Position = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(props.TargetArrowPos)
                        end),
                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(props.TargetingEnemy) == props.Targeting.Value
                        end),

                        [Children] = {
                            Components.ScaledTextUIStroke(scope, {
                                Thickness = 0.059
                            })
                        }
                    })
                }
            }),

            Components.Frame(scope, {
                Name = "TitleSection",

                [Children] = {
                    Components.UIListLayout(scope, {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0.03, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,

                        [Fusion.Out("AbsoluteContentSize")] = absContentSize,
                    }),

                    Components.PaddingFrame(scope, "ZZZ"),

                    Components.HoverImageButton(scope, {
                        Name = "Icon",
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Color3.fromRGB(),
                        Size = UDim2.fromScale(1.2, 1.2),
                        LayoutOrder = 3,

                        Image = EntityBook[targeting.Name].Icon,

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            self.ForceSwitchTargetFunc(targeting)
                        end,

                        [Children] = {
                            Components.RoundUICorner(scope),

                            Components.ScaledUIStroke(scope, {
                                Thickness = 0.1,

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

                        Text = `Lv.{targeting:GetAttribute("Level")}`,

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.UIPadding(scope, {
                                PaddingTop = UDim.new(0.05, 0),
                                PaddingBottom = UDim.new(0.05, 0),
                                PaddingLeft = UDim.new(0, 5),
                                PaddingRight = UDim.new(0, 5)
                            })
                        }
                    }),

                    Components.TextLabel(scope, {
                        Name = "EnemyName",
                        LayoutOrder = 1,
                        Size = UDim2.fromScale(0, 0.8),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        AutomaticSize = Enum.AutomaticSize.X,

                        Text = EntityBook[targeting.Name].Name,

                        [Children] = {
                            Components.UIPadding(scope, {
                                PaddingTop = UDim.new(0.05, 0),
                                PaddingBottom = UDim.new(0.05, 0),
                                PaddingLeft = UDim.new(0, 4),
                                PaddingRight = UDim.new(0, 4),
                            })
                        }
                    })
                }
            }),
        }
    })


    local bar2 = Components.Frame(scope, {
        Name = targeting.Name.."_EffectList",
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.fromScale(1, 0.4),
        LayoutOrder = ORDER + 1,
        Visible = false,

        [Children] = {
            Components.Frame(scope, {
                Name = "EffectList",

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.01, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                    })
                }
            }),
        }
    })


    --// track effect list
    ClientLib:TrackEffectListToUI({
        Target = targeting,
        Scope = scope,
        GuiContainer = bar2,
        EffectContainer = bar2.EffectList
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
        HarukaLib:Tween(
            bar.TitleSection.Icon.UIStroke.UIGradient,
            AssetBook.TweenInfos.half,
            { Transparency = result }
        )
    end
    table.insert(scope, HarukaLib:Hydrate(targeting.Humanoid, {
        ["Prop-Health"] = _updateHealth,
        ["Prop-MaxHealth"] = _updateHealth,
    }))


    return {
        bar, bar2
    }
end