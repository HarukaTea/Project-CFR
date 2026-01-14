
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

return function (scope: Fusion.Scope, props: {
    Visible: boolean?,
    Color: Color3?,
    Transparency: number?,
}) : ImageLabel
    props = props or {}

    props.Visible = props.Visible or true
    props.Color = props.Color or Components.WHITE_COLOR
    props.Transparency = props.Transparency or 0.3

    return Fusion.Hydrate(scope, Components:RefUI("IconShadeTex_1"))({
        Visible = props.Visible,
        ImageTransparency = props.Transparency,
        ImageColor3 = props.Color
    })
end