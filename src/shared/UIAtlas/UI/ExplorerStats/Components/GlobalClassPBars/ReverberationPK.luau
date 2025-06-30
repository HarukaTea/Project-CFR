--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local IconShadeTex = require(RepS.HarukaShared.UIAtlas.Components.IconShadeTex)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Num: number
})
    return Components.Frame(scope, {
        Name = "ResonateNum",

        [Children] = {
            Components.IconImageLabel(scope, {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.75, 0.75),
                Image = "rbxassetid://121488236607929"
            }),

            IconShadeTex(scope, {}),

            Components.TextLabel(scope, {
                Name = "Num",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, -0.3),
                ZIndex = 2,
                Size = UDim2.fromScale(0.75, 0.75),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                FontFace = Font.fromName("Roboto", Enum.FontWeight.Bold),
                Text = props.Num,

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 2.5 })
                }
            })
        }
    })
end
