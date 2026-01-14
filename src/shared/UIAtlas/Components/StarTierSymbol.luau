
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

return function(scope: Fusion.Scope, props: {
    Size: UDim2?
})
    props = props or {}
    props.Size = props.Size or UDim2.fromScale(1, 1)

    return Fusion.Hydrate(scope, Components:RefUI("Star_1", true))({
        Size = props.Size,
    })
end