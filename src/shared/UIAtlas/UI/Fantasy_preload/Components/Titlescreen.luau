
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    SlotUISignal: RBXScriptSignal,
    CutsceneUISignal: RBXScriptSignal
}) : ScreenGui

    local isShown = Fusion.Value(scope, true)

    table.insert(scope, props.CutsceneUISignal:Connect(function()
        isShown:set(true)
    end))
    table.insert(scope, props.SlotUISignal:Connect(function()
        isShown:set(false)
    end))

    local isSelecting = Fusion.Value(scope, false)

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
                })
            }
        },
    })


    return UI
end