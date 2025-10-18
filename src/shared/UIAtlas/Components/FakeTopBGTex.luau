--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children


local CFEmblemTex = require(RepS.HarukaShared.UIAtlas.Components.CFEmblemTex)


return function (scope: Fusion.Scope)
    return Components.Frame(scope, {
        Name = "FakeTopBG",
        BackgroundTransparency = 0.1,
        Size = UDim2.fromScale(2, 1.8),
        ZIndex = 0,

        [Children] = {
            CFEmblemTex(scope, {
                Transparency = 0.98,
                Size = UDim2.fromScale(4, 4),
                Position = UDim2.fromScale(0.25, 0.5)
            })
        }
    })
end