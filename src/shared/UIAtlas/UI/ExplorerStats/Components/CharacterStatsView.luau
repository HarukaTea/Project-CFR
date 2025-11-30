
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local DMGStat = require(script.Parent.DMGStat)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    MinDMG: Fusion.Value<number>,
    MaxDMG: Fusion.Value<number>,
    Magic: Fusion.Value<number>,


    HalloweenCandy: Fusion.Value<number>,
    Gold: Fusion.Value<number>,
})

    return Components.Frame(scope, {
        Name = "CharacterStats",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),

        [Children] = {
            Components.UIScale(scope, {
                Scale = 0.9
            }),

            Components.Frame(scope, {
                Name = "DMGStats",
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(0.015, -0.2),
                Size = UDim2.fromScale(0.33, 0.5),

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.25, 0),
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                    }),

                    DMGStat(scope, {
                        StatId = "DMG",
                        StatValue = props.MinDMG,
                        StatValue2 = props.MaxDMG,
                        LayoutOrder = 2,
                    }),
                    DMGStat(scope, {
                        StatId = "Magic",
                        StatValue = props.Magic,
                        LayoutOrder = 1,
                    }),
                    DMGStat(scope, {
                        StatId = "Gold",
                        StatValue = props.Gold,
                        LayoutOrder = -1
                    })
                }
            }),
        }
    })
end