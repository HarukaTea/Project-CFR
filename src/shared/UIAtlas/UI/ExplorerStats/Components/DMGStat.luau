--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local udNew = UDim.new

local statIcons = {
    DMG = "rbxassetid://2965862892",
    Magic = "rbxassetid://2965863231"
}

return function (scope: Fusion.Scope, props: {
    StatId: string,

    StatValue: Fusion.Value<number>,
    StatValue2: Fusion.Value<number>?,
})

    return Components.Frame(scope, {
        Name = props.StatId,

        [Children] = {
            Components.UIListLayout(scope, {
                Padding = udNew(0.015, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                FillDirection = Enum.FillDirection.Horizontal,
            }),

            Components.IconImageLabel(scope, {
                Name = "StatIcon_"..props.StatId,
                LayoutOrder = 1,

                Image = statIcons[props.StatId],
            }),
            Components.TextLabel(scope, {
                Name = "StatText_"..props.StatId,
                LayoutOrder = 2,
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    if props.StatId == "DMG" then
                        return HarukaLib:CommaifyNumber(use(props.StatValue)).."-"..HarukaLib:CommaifyNumber(use(props.StatValue2))
                    else
                        return HarukaLib:CommaifyNumber(use(props.StatValue))
                    end
                end),

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 2.5 })
                }
            })
        },
    })
end