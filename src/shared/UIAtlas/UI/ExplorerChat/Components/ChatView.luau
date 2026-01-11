
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children



local BL = {
    ["That Bird With A Couple Lines Of Dialogue"] = true
}


return function (scope: Fusion.Scope, props: {
    IsChatShown: Fusion.Value<boolean>,

    ChoiceList: Fusion.Value<{ string }>,
    Dialogue: Fusion.Value<string>,
    MaxUTFShown: Fusion.Value<number>,

    Speaker: Fusion.Value<string>,
    NPCId: Fusion.Value<string>,
    IsTypewriting: Fusion.Value<boolean>,

    GoToNextDialogueSignal: BindableEvent,
    GoToNextDialogueByChoiceSignal: BindableEvent,
    GoSkipDialogueSignal: BindableEvent,
})

    local absDialogueSize = Fusion.Value(scope, Vector2.zero)

    local lastInputType = Components.FusionComponents.useXboxControllerHotInput(scope)
    local key = nil

    key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInputType) :: string

        if input == "Controller" then
            return Components.TextLabel(scope, {
                Name = "KeyTip",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Text = "Y",
                Size = UDim2.fromScale(0.6, 0.6),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Position = UDim2.fromScale(0.54, 0.5),
                BackgroundTransparency = 0,
                BackgroundColor3 = AssetBook.XboxControllerColors.Y,
                TextColor3 = Components.BLACK_COLOR,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(props.IsTypewriting)
                end),

                [Children] = {
                    Components.RoundUICorner(scope),
                }
            })
        else
            return nil
        end
    end)


    return Components.Frame(scope, {
        Name = "ExploringChatView",

        [Children] = {
            Components.Frame(scope, {
                Name = "Shade",
                BackgroundColor3 = Color3.fromRGB(),
                BackgroundTransparency = 0,
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.fromScale(1, 6),
                ZIndex = -1,

                [Children] = {
                    Components.UIGradient(scope, {
                        Rotation = -90,
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1)
                        })
                    })
                }
            }),
            Components.Frame(scope, {
                Name = "Tex",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.fromScale(1, 6),
                ZIndex = 0,

                [Children] = {
                    Components.ImageLabel(scope, {
                        Name = "CAPatternTex",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        ZIndex = 0,

                        Image = "rbxassetid://91666280221875",
                        ImageTransparency = 0.95,

                        ScaleType = Enum.ScaleType.Tile,
                        TileSize = UDim2.fromOffset(40, 40),

                        [Children] = {
                            Components.UIGradient(scope, {
                                Rotation = -90,
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 0),
                                    NumberSequenceKeypoint.new(0.7, 1),
                                    NumberSequenceKeypoint.new(1, 1)
                                })
                            })
                        },
                    })
                }
            }),

            Components.TextLabel(scope, {
                Name = "Speaker",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -2.2),
                Size = UDim2.fromScale(0.6, 0.55),
                TextColor3 = Color3.fromRGB(255, 231, 187),
                RichText = true,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `<u>{use(props.Speaker)}</u>`
                end),

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {
                        Thickness = 0.05
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "Dialogue",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -1.4),
                Size = UDim2.fromScale(0.6, 1.5),
                RichText = true,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                TextScaled = false,

                AutoLocalize = if BL[props.Speaker] then false else true,

                [Fusion.Out("AbsoluteSize")] = absDialogueSize,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.Dialogue)
                end),
                TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(absDialogueSize).Y / (68 / 23)
                end),
                MaxVisibleGraphemes = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.MaxUTFShown)
                end),

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {
                        Thickness = 0.05
                    })
                }
            }),

            Components.ImageLabel(scope, {
                Name = "Triangle",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Rotation = 90,
                Size = UDim2.fromScale(0.5, 0.5),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                ImageTransparency = 0.1,
                ImageColor3 = Color3.fromRGB(255, 231, 187),

                Image = "rbxassetid://140381962250989",

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(props.IsTypewriting)
                end)
            }),

            key,


            Components.TextButton(scope, {
                Name = "SkipBtn",
                BackgroundColor3 = Components.BLUE_COLOR,
                TextColor3 = Components.BLACK_COLOR,
                AnchorPoint = Vector2.one,
                Size = UDim2.fromScale(0.1, 0.55),
                Position = UDim2.fromScale(0.98, 0.5),
                Text = "SKIP",

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.GoSkipDialogueSignal:Fire()
                end,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {
                        PaddingLeft = UDim.new(0, 0),
                        PaddingRight = UDim.new(0, 0),
                    })
                }
            }),

            Components.Frame(scope, {
                Name = "ChoicesFrame",
                ZIndex = 12,
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(0.65, -3),
                Size = UDim2.fromScale(0.3, 0.65),

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.3, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
                    }),


                    Fusion.ForPairs(scope, props.ChoiceList, function(_, scope: Fusion.Scope, index: number, choice: string)

                        local choiceType = "Default"
                        local isSelecting = Fusion.Value(scope, false)


                        if string.find(choice, "ENTERMARKET") then
                            choiceType = "Market"
                            choice = "[Enter Market]"
                        elseif string.find(choice, "ENTERCRAFTING") then
                            choiceType = "Crafting"
                            choice = "[Enter Crafting]"
                        end


                        return index, Components.Frame(scope, {
                            Name = "Choice"..index,
                            BackgroundTransparency = 0,
                            Size = UDim2.fromScale(0.9, 1),
                            LayoutOrder = index,

                            BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                return if use(isSelecting) then Components.WHITE_COLOR else Components.BLACK_COLOR
                            end),

                            [Children] = {
                                Components.RoundUICorner(scope),
                                Components.UIGradient(scope, {
                                    Transparency = NumberSequence.new({
                                        NumberSequenceKeypoint.new(0, 0),
                                        NumberSequenceKeypoint.new(0.5, 0.2),
                                        NumberSequenceKeypoint.new(1, 1)
                                    })
                                }),

                                Components.HoverImageButton(scope, {
                                    [Fusion.OnEvent("MouseEnter")] = function()
                                        isSelecting:set(true)
                                    end,
                                    [Fusion.OnEvent("MouseLeave")] = function()
                                        isSelecting:set(false)
                                    end,
                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        props.GoToNextDialogueByChoiceSignal:Fire(index)
                                    end,
                                }),

                                Components.ImageLabel(scope, {
                                    Name = "Icon",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    Position = UDim2.fromScale(0.03, 0.5),
                                    Size = UDim2.fromScale(0.6, 0.6),
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                    Image = AssetBook.PromptIcons[choiceType],

                                    ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return if use(isSelecting) then Components.BLACK_COLOR else Color3.fromRGB(255, 231, 187)
                                    end),
                                }),
                                Components.TextLabel(scope, {
                                    Name = "ChoiceText",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    Position = UDim2.fromScale(0.12, 0.5),
                                    Size = UDim2.fromScale(1, 0.7),
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    Text = choice,

                                    TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return if use(isSelecting) then Components.BLACK_COLOR else Components.WHITE_COLOR
                                    end),
                                })
                            }
                        })
                    end)
                }
            })
        }
    })
end