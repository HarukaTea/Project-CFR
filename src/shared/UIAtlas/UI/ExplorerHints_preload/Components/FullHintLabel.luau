
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

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
                    Fusion.Hydrate(scope, Components:RefUI("Hint_FH1_1", true))({
                        Text = props.Text
                    })
                }
            })
        }
    })
end