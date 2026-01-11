
local RepS = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService")
local SocialService = game:GetService("SocialService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    SlotUISignal: BindableEvent,
    CutsceneUISignal: BindableEvent
}) : ScreenGui


    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local isShown = Value(true)

    table.insert(scope, props.CutsceneUISignal.Event:Connect(function()
        isShown:set(true)
    end))
    table.insert(scope, props.SlotUISignal.Event:Connect(function()
        isShown:set(false)
    end))

    local isSelecting = Value(false)
    local isSelectingGroupFrame = Value(false)
    local isSelectingEventFrame = Value(false)


    local HAS_EVENT = true
    local EVENT_ID = "6946626955529421520"

    if game.GameId ~= AssetBook.CFUniverseId_Main then
        EVENT_ID = "6325041198050050620"
    end


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "OuterTitlescreen",
        DisplayOrder = 233,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
            return use(isShown)
        end),

    }, {
        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "PressAnyKey",
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 0,
                    Position = UDim2.fromScale(0.5, -0.2),
                    Size = UDim2.fromScale(0.5, 0.7),

                    BackgroundColor3 = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                        return if use(isSelecting) then Components.WHITE_COLOR else Components.BLACK_COLOR
                    end), Components.DefaultTween),

                    [Children] = {
                        Components.UIGradient(scope, {
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(0.25, 0),
                                NumberSequenceKeypoint.new(0.75, 0),
                                NumberSequenceKeypoint.new(1, 1)
                            })
                        }),

                        Components.TextLabel(scope, {
                            Name = "Tip",
                            Text = "PRESS HERE TO PLAY",

                            TextColor3 = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                                return if use(isSelecting) then Color3.new() else Components.WHITE_COLOR
                            end), Components.DefaultTween),

                            [Children] = {
                                Components.UIPadding(scope, {
                                    PaddingLeft = UDim.new(0.15, 0),
                                    PaddingBottom = UDim.new(0.15, 0),
                                    PaddingRight = UDim.new(0.15, 0),
                                    PaddingTop = UDim.new(0.15, 0),
                                })
                            }
                        }),


                        Components.HoverImageButton(scope, {
                            [Fusion.OnEvent("MouseEnter")] = function()
                                isSelecting:set(true)
                            end,
                            [Fusion.OnEvent("MouseLeave")] = function()
                                isSelecting:set(false)
                            end,

                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                props.SlotUISignal:Fire()
                            end
                        })
                    }
                }),

                Components.ImageLabel(scope, {
                    Name = "Logo",
                    AnchorPoint = Vector2.yAxis,
                    Position = UDim2.fromScale(0.01, 0.715),
                    Size = UDim2.fromScale(0.175, 1.475),
                    Image = "rbxassetid://86695323694537",
                    ScaleType = Enum.ScaleType.Fit
                }),

                Components.Frame(scope, {
                    Name = "GroupJoinFrame",

                    [Children] = {
                        Components.Frame(scope, {
                            Name = "Group",
                            AnchorPoint = Vector2.one,
                            Position = UDim2.fromScale(0.99, 0.5),
                            Size = UDim2.fromScale(0.2, 2),
                            BackgroundTransparency = 0,

                            [Children] = {
                                Components.UICorner(scope, {
                                    CornerRadius = UDim.new(0.1, 0)
                                }),
                                Components.ScaledUIStroke(scope, {
                                    Thickness = 0.035,

                                    Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(isSelectingGroupFrame)
                                    end)
                                }),

                                Components.HoverImageButton(scope, {
                                    [Fusion.OnEvent("MouseEnter")] = function()
                                        isSelectingGroupFrame:set(true)
                                    end,
                                    [Fusion.OnEvent("MouseLeave")] = function()
                                        isSelectingGroupFrame:set(false)
                                    end,

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        pcall(function()
                                            GroupService:PromptJoinAsync(16912246)
                                        end)
                                    end
                                }),

                                Components.ImageLabel(scope, {
                                    Name = "GroupIcon",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    Position = UDim2.fromScale(0.05, 0.5),
                                    Size = UDim2.fromScale(0.7, 0.7),
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                    Image = "rbxassetid://74364175030818",

                                    [Children] = {
                                        Components.UICorner(scope, {
                                            CornerRadius = UDim.new(0.2, 0)
                                        })
                                    }
                                }),

                                Components.TextLabel(scope, {
                                    Name = "Tip",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    Position = UDim2.fromScale(0.385, 0.5),
                                    Size = UDim2.fromScale(0.55, 0.9),
                                    Text = "CLICK HERE TO JOIN THE GROUP!",

                                    [Children] = {
                                        Components.UIPadding(scope, {}),
                                    }
                                }),

                                Components.Frame(scope, {
                                    Name = "Awards",
                                    AnchorPoint = Vector2.new(0.5, 0),
                                    Position = UDim2.fromScale(0.5, -0.5),
                                    Size = UDim2.fromScale(1, 0.4),

                                    [Children] = {
                                        Components.UIListLayout(scope, {
                                            FillDirection = Enum.FillDirection.Horizontal,
                                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                            VerticalAlignment = Enum.VerticalAlignment.Center,
                                        }),

                                        Components.IconImageLabel(scope, {
                                            Image = "rbxassetid://18421784947"
                                        }),
                                        Components.TextLabel(scope, {
                                            Name = "Title",
                                            AutomaticSize = Enum.AutomaticSize.X,
                                            Size = UDim2.fromScale(0, 1),
                                            Text = "REWARDS",

                                            [Children] = {
                                                Components.UIPadding(scope, {
                                                    PaddingLeft = UDim.new(0, 12),
                                                    PaddingRight = UDim.new(0, 12),
                                                    PaddingTop = UDim.new(0.15, 0),
                                                    PaddingBottom = UDim.new(0.15, 0),
                                                }),
                                                Components.ScaledTextUIStroke(scope, {
                                                    Thickness = 0.1
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
        },

        TopProps = {
            [Children] = {
                Fusion.Computed(scope, function(_, scope: Fusion.Scope)
                    if not HAS_EVENT then return nil end

                    return Components.Frame(scope, {
                        Name = "EventsFrame",

                        [Children] = {
                            Components.Frame(scope, {
                                Name = "Event",
                                AnchorPoint = Vector2.xAxis,
                                Position = UDim2.fromScale(0.99, 0.5),
                                Size = UDim2.fromScale(0.25, 2.25),
                                BackgroundTransparency = 0,

                                [Children] = {
                                    Components.UICorner(scope, {
                                        CornerRadius = UDim.new(0.1, 0)
                                    }),
                                    Components.ScaledUIStroke(scope, {
                                        Thickness = 0.035,

                                        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return use(isSelectingEventFrame)
                                        end)
                                    }),

                                    Components.HoverImageButton(scope, {
                                        Image = "rbxassetid://91130779564139",
                                        ScaleType = Enum.ScaleType.Crop,

                                        [Fusion.OnEvent("MouseEnter")] = function()
                                            isSelectingEventFrame:set(true)
                                        end,
                                        [Fusion.OnEvent("MouseLeave")] = function()
                                            isSelectingEventFrame:set(false)
                                        end,

                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            pcall(function()
                                                SocialService:PromptRsvpToEventAsync(EVENT_ID)
                                            end)
                                        end,

                                        [Children] = {
                                            Components.UICorner(scope, {
                                                CornerRadius = UDim.new(0.1, 0)
                                            }),
                                        }
                                    }),

                                    Components.TextLabel(scope, {
                                        Name = "Tip",
                                        AnchorPoint = Vector2.new(0.5, 1),
                                        Position = UDim2.fromScale(0.5, 1.3),
                                        Size = UDim2.fromScale(1, 0.25),
                                        Text = "CHECK OUR EVENTS!",

                                        [Children] = {
                                            Components.ScaledTextUIStroke(scope, {
                                                Thickness = 0.1
                                            })
                                        }
                                    })
                                }
                            }),
                        }
                    })
                end)
            }
        }
    })


    return UI
end