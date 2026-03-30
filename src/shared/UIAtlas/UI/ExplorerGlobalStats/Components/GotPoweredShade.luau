
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

return function (scope: Fusion.Scope)
    return Components:RefUI("GotPoweredShade", true)
end