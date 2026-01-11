
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

return function (scope: Fusion.Scope, props: {
    Text: string,
    LayoutOrder: number,
})
    return Fusion.Hydrate(scope, Components:RefUI("HintLabel_Hints1_1", true))({
        LayoutOrder = props.LayoutOrder,
        Text = props.Text,

        TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local size = workspace.CurrentCamera.ViewportSize.Y / (Components.DESIGN_VP_SIZE.Y / 19)
            return math.clamp(size, 1, 20)
        end)
    })
end