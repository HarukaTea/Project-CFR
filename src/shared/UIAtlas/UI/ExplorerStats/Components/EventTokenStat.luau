
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local udNew = UDim.new

local STAT_ICONS = {
    HalloweenCandy = "rbxassetid://101642799593354",
    IceCandy = "rbxassetid://4806921700"
}
local STAT_COLORS = {
    HalloweenCandy = Color3.fromRGB(255, 234, 167),
    IceCandy = Color3.fromRGB(129, 236, 236)
}

return function (scope: Fusion.Scope, props: {
    StatId: string,

    StatValue: Fusion.Value<number>,
    StatValue2: Fusion.Value<number>?,

    LayoutOrder: number,
})

    return Components.Frame(scope, {
        Name = props.StatId,
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.fromScale(0.35, 1),

        [Children] = {
            Components.UIListLayout(scope, {
                Padding = udNew(0.04, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                FillDirection = Enum.FillDirection.Horizontal,
            }),

            Components.IconImageLabel(scope, {
                Name = "StatIcon_"..props.StatId,
                LayoutOrder = 1,

                Image = STAT_ICONS[props.StatId],
            }),
            Components.TextLabel(scope, {
                Name = "StatText_"..props.StatId,
                LayoutOrder = 2,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = STAT_COLORS[props.StatId],

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return HarukaLib:CommaifyNumber(use(props.StatValue))
                end),

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {})
                }
            })
        },
    })
end