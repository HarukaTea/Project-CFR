
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    LevelId: Fusion.Value<string?>,
    LevelStarted: Fusion.Value<boolean>,
    CountdownTime: Fusion.Value<number>
})
    return Components.ImageLabel(scope, {
        Name = "TimerBG_"..(Fusion.peek(props.LevelId) or "/"),
        Size = UDim2.fromScale(0.15, 0.7),
        Image = "rbxassetid://97834064886932",
        ImageColor3 = Color3.fromRGB(),

        Visible = Fusion.Computed(scope, function(use: Fusion.Use)
            return if use(props.LevelId) and use(props.LevelStarted) and use(props.CountdownTime) > 0 then true else false
        end),

        [Children] = {
            Components.UIListLayout(scope, {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),

            Fusion.New(scope, "UIGradient")({
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.15, 0.25),
                    NumberSequenceKeypoint.new(0.5, 0),
                    NumberSequenceKeypoint.new(0.85, 0.25),
                    NumberSequenceKeypoint.new(1, 1)
                })
            }),

            Components.ImageLabel(scope, {
                Name = "Icon",
                Size = UDim2.fromScale(0.7, 0.7),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Image = "rbxassetid://108568405853683",
                LayoutOrder = 1,
            }),
            Components.TextLabel(scope, {
                Name = "Time",
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 1),
                LayoutOrder = 2,
                FontFace = Font.fromName("Roboto", Enum.FontWeight.Bold),

                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    return HarukaLib:NumToTime(use(props.CountdownTime))
                end),

                [Children] = {
                    Components.UIPadding(scope, {
                        PaddingTop = UDim.new(0, 0),
                        PaddingBottom = UDim.new(0, 0),
                    })
                }
            })
        }
    })
end