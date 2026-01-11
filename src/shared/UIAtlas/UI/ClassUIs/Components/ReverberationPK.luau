
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Num: number
})
    return Fusion.Hydrate(scope, Components:RefUI("ResonateNum_CA1_1", false, false, {
        "Icon", "IconShadeTex"
    }))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Num_Rev_CA1_1", true))({
                Text = tostring(props.Num)
            })
        }
    })
end