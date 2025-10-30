
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    Transparency: number?,
    TileSize: UDim2?,

    [Fusion.SpecialKey]: Components.FusionPropsEntry,
})
    props = props or {}

    props.Transparency = props.Transparency or 0.975
    props.TileSize = props.TileSize or UDim2.fromScale(0.15, 0.15)

    props[Fusion.Children] = props[Fusion.Children] or {}


    return Components.ImageLabel(scope, {
        Name = "CAPatternTex",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        ZIndex = 0,

        Image = "rbxassetid://91666280221875",
        ImageTransparency = props.Transparency,

        ScaleType = Enum.ScaleType.Tile,
        TileSize = props.TileSize,

        [Children] = props[Fusion.Children],
    })
end