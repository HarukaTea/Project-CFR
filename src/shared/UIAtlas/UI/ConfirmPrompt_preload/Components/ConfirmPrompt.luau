
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    ConfirmText: string,
    CancelText: string,
    Hint: string,

    ResultSignal: RBXScriptSignal,
})

    local absTextBGSize = Fusion.Value(scope, Vector2.zero)

    local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ConfirmPrompt",
		DisplayOrder = UIPriorityBook.System,

	}, {
        CenterProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "ConfirmPrompt",
                    Size = UDim2.fromScale(0.5, 8),
                    BackgroundColor3 = Components.BLACK_COLOR,
                    BackgroundTransparency = 0,

                    [Children] = {
                        Components.UICorner(scope, { CornerRadius = UDim.new(0.025, 0) }),

                        Components.ScaledUIStroke(scope, {
                            Color = Color3.fromRGB()
                        }),

                        Components.Frame(scope, {
                            Name = "InnerFakeStroke",
                            Size = UDim2.fromScale(0.95, 0.92),

                            [Children] = {
                                Components.UICorner(scope, { CornerRadius = UDim.new(0.025, 0) }),
                                Components.ScaledUIStroke(scope, {
                                    Thickness = 0.01,
                                    Transparency = 0.7,
                                    Color = Color3.fromRGB(174, 159, 128)
                                }),
                            }
                        }),
                        Components.ImageLabel(scope, {
                            Name = "Emblem",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.45),
                            Size = UDim2.fromScale(0.3, 0.3),
                            SizeConstraint = Enum.SizeConstraint.RelativeYY,
                            Image = "rbxassetid://114332372182764",
                            ImageTransparency = 0.9,
                            ZIndex = 0,
                        }),
                        Components.TextLabel(scope, {
                            Name = "Prompt",
                            AnchorPoint = Vector2.new(0.5, 0),
                            Position = UDim2.fromScale(0.5, 0.07),
                            Size = UDim2.fromScale(0.9, 0.72),
                            TextScaled = false,
                            TextWrapped = true,
                            Text = HarukaLib:RichTextify(props.Hint),
                            RichText = true,

                            TextSize = Fusion.Computed(scope, function(use: Fusion.Use)
                                return math.ceil(use(absTextBGSize).Y / (40 / 27))
                            end),
                        }),
                        Components.Frame(scope, {
                            Name = "BtnsFrame",
                            AnchorPoint = Vector2.new(0.5, 0),
                            Position = UDim2.fromScale(0.5, 0.825),
                            Size = UDim2.fromScale(0.9, 0.11),

                            [Fusion.Out("AbsoluteSize")] = absTextBGSize,

                            [Children] = {
                                Components.UIListLayout(scope, {
                                    Padding = UDim.new(0.025, 0),
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                }),

                                ExecuteButton(scope, {
                                    LayoutOrder = 2,
                                    Size = UDim2.fromScale(0.45, 0.75),
                                    ButtonText = props.ConfirmText,
                                    ButtonType = "Confirm",
                                    ButtonClickFunc = function()
                                        props.ResultSignal:Fire("YES")
                                    end
                                }),
                                ExecuteButton(scope, {
                                    LayoutOrder = 1,
                                    Size = UDim2.fromScale(0.45, 0.75),
                                    ButtonText = props.CancelText,
                                    ButtonType = "Cancel",
                                    ButtonClickFunc = function()
                                        props.ResultSignal:Fire("NO")
                                    end
                                })
                            }
                        })
                    }
                })
            }
        },

        FullProps = {
            BackgroundTransparency = 0.2,
			ZIndex = 0,
			Active = true
        }
    })

    return UI
end