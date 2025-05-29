--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)


return function (scope: Fusion.Scope, props: {
    Transparency: number?,
    TileSize: UDim2,

    [Fusion.Children]: table?,
})

    props = props or {}

    props.Transparency = props.Transparency or 0.975
    props.TileSize = props.TileSize or UDim2.fromScale(0.15, 0.15)


    return Components.ImageLabel(scope, {
        Name = "CAPatternTex",
        ZIndex = 0,

        Image = "rbxassetid://91666280221875",
        ImageTransparency = props.Transparency,

        ScaleType = Enum.ScaleType.Tile,
        TileSize = props.TileSize,

        [Fusion.Children] = props[Fusion.Children] or {},
    })
end
