
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

--- techically we dont need `RefUI` here
return function(scope: Fusion.Scope)
    return Components.Frame(scope, {
        Name = "CircleFX",
        Size = UDim2.fromScale(0, 0),

        [Children] = {
            Components.RoundUICorner(scope),
            Components.ScaledUIStroke(scope, {
                Thickness = 0.03
            })
        }
    })
end