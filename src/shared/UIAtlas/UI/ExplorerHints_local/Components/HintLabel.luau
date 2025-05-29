--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    Text: string,
    LayoutOrder: number,
})
    return Components.TextLabel(scope, {
        Name = "HintLabel",
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromScale(0, 0),
        BackgroundTransparency = 0,
        LayoutOrder = props.LayoutOrder,

        RichText = true,
        Text = props.Text,
        TextScaled = false,
        TextWrapped = false,

        TextSize = 19,

        [Children] = {
            Components.UICorner(scope, { CornerRadius = UDim.new(0, 4) }),

            Components.UIPadding(scope, {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
            }),
        },
    })
end