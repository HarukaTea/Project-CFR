--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    Index: number,
    PlayerName: string,
    Value: number,
    AvatarId: string
})
    return Components.Frame(scope, {
        Name = props.PlayerName,
        BackgroundColor3 = Color3.fromRGB(),
        BackgroundTransparency = if props.Index % 2 == 0 then 0.1 else 0.65,
        Size = UDim2.fromScale(1, 0.1),
        LayoutOrder = props.Index,

        [Children] = {
            Components.UIAspectRatioConstraint(scope, 21.063),

            Components.TextLabel(scope, {
                Name = "PlayerName",
                Position = UDim2.fromScale(0.08, 0),
                Size = UDim2.fromScale(0.3, 1),
                Text = props.PlayerName,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoLocalize = false,

                TextColor3 = if props.Index <= 3 then Color3.fromRGB(255, 255, 0) else Components.WHITE_COLOR,

                [Children] = {
                    Components.UIPadding(scope, {
                        PaddingTop = UDim.new(0.15, 0),
                        PaddingBottom = UDim.new(0.15, 0),
                        PaddingLeft = UDim.new(0, 0),
                        PaddingRight = UDim.new(0, 0)
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "Stat",
                AnchorPoint = Vector2.xAxis,
                Position = UDim2.fromScale(0.98, 0),
                Size = UDim2.fromScale(0.3, 1),
                TextXAlignment = Enum.TextXAlignment.Right,
                Text = `{utf8.char(0xE002)} {props.Value}`,


                [Children] = {
                    Components.UIPadding(scope, {
                        PaddingTop = UDim.new(0.15, 0),
                        PaddingBottom = UDim.new(0.15, 0),
                        PaddingLeft = UDim.new(0, 0),
                        PaddingRight = UDim.new(0, 0)
                    })
                }
            }),

            Components.IconImageLabel(scope, {
                Position = UDim2.fromScale(0.02, 0.5),
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.fromScale(0.8, 0.8),

                Image = props.AvatarId
            })
        }
    })
end