
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    Index: number,
    PlayerName: string,
    Value: number,
    AvatarId: string,

    IsAbyss: boolean?
})

    local text = `{props.Value}`
    if props.IsAbyss then
        text = HarukaLib:TimeifyNumber(props.Value)
    end


    return Components.Frame(scope, {
        Name = props.PlayerName,
        BackgroundColor3 = Color3.fromRGB(),
        BackgroundTransparency = if props.Index % 2 == 0 then 0.1 else 0.65,
        Size = UDim2.fromScale(1, 0.1),
        LayoutOrder = props.Index,

        [Children] = {
            Components.UIAspectRatioConstraint(scope, 14.042),

            Components.TextLabel(scope, {
                Name = "PlayerName",
                Position = UDim2.fromScale(0.1, 0),
                Size = UDim2.fromScale(0.5, 1),
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
                Name = "ValShow",
                AnchorPoint = Vector2.xAxis,
                Position = UDim2.fromScale(0.95, 0),
                Size = UDim2.fromScale(0.3, 1),
                TextXAlignment = Enum.TextXAlignment.Right,
                Text = text,


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