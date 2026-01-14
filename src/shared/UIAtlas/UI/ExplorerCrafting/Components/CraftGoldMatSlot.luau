
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    GoldVal: Fusion.Value<number>,
    Amount: number,
})
    local itemInfo = {
        Icon = "rbxassetid://18421784947",
        Name = "Gold",
    }
    local isSelecting = Fusion.Value(scope, false)

    return Fusion.Hydrate(scope, Components:RefUI("CraftMaterialTemplate_ECraft1_1", false, false, {
        "UICorner"
    }))({
        Name = "CraftGoldMatSlot",
        Icon = itemInfo.Icon,
        LayoutOrder = 233,

        Components.ConnectSelectEvents(isSelecting),

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.05,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Amount_CMTCraft1_1", true))({
                Text = props.Amount,
                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(props.GoldVal) >= props.Amount then Color3.fromRGB(85, 255, 127) else Color3.fromRGB(255, 118, 117)
                end),
            }),

            Fusion.Hydrate(scope, Components:RefUI("ItemName_CMTCraft1_1"))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end),

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ItemName_CMTCraft1_1", true))({
                        Text = itemInfo.Name,
                    }),
                }
            })
        }
    })
end