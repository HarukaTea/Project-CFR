
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local fromScale = UDim2.fromScale

return function (scope: Fusion.Scope, props: {
    Text: string
})
    return Components.Frame(scope, {
        Name = "FullHintLabel",
        BackgroundTransparency = 0,


        [Children] = {
            Components.HarukaFrame(scope, {
                Name = "Center",

                [Children] = {
                    Components.TextLabel(scope, {
                        Name = "Hint",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = fromScale(0.5, 0.5),
                        Size = fromScale(1, 0.6),

                        Text = props.Text,

                        [Children] = {
                            Components.UITextSizeConstraint(scope, {
                                MaxTextSize = 36,
                            })
                        },
                    }),
                }
            })
        }
    })
end