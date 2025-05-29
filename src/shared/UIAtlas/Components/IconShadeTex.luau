--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)


return function (scope: Fusion.Scope, props: {
    Visible: Fusion.Computed? | boolean?,
    Color: Color3?
})

    props = props or {}

    props.Visible = props.Visible or true
    props.Color = props.Color or Components.WHITE_COLOR


    return Components.ImageLabel(scope, {
        Name = "IconShadeTex",
        Size = UDim2.fromScale(1.7, 1.7),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        ZIndex = 0,

        Visible = props.Visible,

        Image = "rbxassetid://91832243782412",
        ImageTransparency = 0.3,
        ImageColor3 = props.Color
    })
end


