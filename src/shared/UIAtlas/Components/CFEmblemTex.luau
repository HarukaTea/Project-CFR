
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    Transparency: number?,
    Size: UDim2?,
    Position: UDim2?,
    Color: Fusion.Computed<Color3>? | Color3?,

    [Fusion.SpecialKey]: Components.FusionPropsEntry?,
})

    props = props or {}

    props.Transparency = props.Transparency or 0.935
    props.Size = props.Size or UDim2.fromScale(4, 4)
    props.Position = props.Position or UDim2.fromScale(0.5, 0.5)
    props.Color = props.Color or Color3.new(1, 1, 1)

    props[Fusion.Children] = props[Fusion.Children] or {}

    return Components.Frame(scope, {
        Name = "CFEmblemTex",
        ClipsDescendants = true,
        ZIndex = 0,

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Emblem_CFETex1_1"))({
                Position = props.Position,
                Size = props.Size,
                Image = "rbxassetid://72405016863286",
                ImageTransparency = props.Transparency,
                ImageColor3 = props.Color
            }),

            [Children] = props[Fusion.Children],
        }
    })
end