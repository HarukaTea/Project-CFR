--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local CAPatternTex = require(RepS.HarukaShared.UIAtlas.Components.CAPatternTex)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    IsChatShown: Fusion.Value,

    ChoiceList: Fusion.Value,
    Dialogue: Fusion.Value,
    MaxUTFShown: Fusion.Value,

    Speaker: Fusion.Value,
    NPCId: Fusion.Value,
    IsTypewriting: Fusion.Value,

    ProcessedToNextDialogueSignal: RBXScriptSignal,
})

    local absDialogueSize = Fusion.Value(scope, Vector2.zero)


    return Components.Frame(scope, {
        Name = "ExploringChatView",

        [Children] = {
            Components.Frame(scope, {
                Name = "Shade",
                BackgroundColor3 = Color3.fromRGB(),
                BackgroundTransparency = 0,
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.fromScale(1, 5.5),
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
                Size = UDim2.fromScale(1, 5.5),
                ZIndex = 0,

                [Children] = {
                    CAPatternTex(scope, {
                        Transparency = 0.95,
                        TileSize = UDim2.fromScale(0.03, 0.15),

                        [Children] = {
                            Components.UIGradient(scope, {
                                Rotation = -90,
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 0),
                                    NumberSequenceKeypoint.new(0.7, 1),
                                    NumberSequenceKeypoint.new(1, 1)
                                })
                            })
                        }
                    })
                }
            }),

            Components.TextLabel(scope, {
                Name = "Speaker",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -1.8),
                Size = UDim2.fromScale(0.6, 0.55),
                TextColor3 = Color3.fromRGB(255, 231, 187),
                RichText = true,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `<u>{use(props.Speaker)}</u>`
                end)
            }),
            Components.TextLabel(scope, {
                Name = "Dialogue",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -1),
                Size = UDim2.fromScale(0.6, 1.05),
                RichText = true,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                TextScaled = false,

                [Fusion.Out("AbsoluteSize")] = absDialogueSize,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return HarukaLib:RichTextify(use(props.Dialogue))
                end),
                TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(absDialogueSize).Y / (47 / 25)
                end),
                MaxVisibleGraphemes = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.MaxUTFShown)
                end)
            }),

            Components.ImageLabel(scope, {
                Name = "Triangle",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.2),
                Rotation = 90,
                Size = UDim2.fromScale(0.5, 0.5),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                ImageTransparency = 0.1,
                ImageColor3 = Color3.fromRGB(255, 231, 187),

                Image = "rbxassetid://140381962250989",

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(props.IsTypewriting)
                end)
            })
        }
    })
end