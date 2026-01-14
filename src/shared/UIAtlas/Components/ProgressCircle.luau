
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    Direction: "Left" | "Right",
    RotationVal: Fusion.Value<number>,
    ZIndex: number?,
    Color: Color3?
}) : Frame

    props.Color = props.Color or Color3.fromRGB(255, 255, 255)
    props.ZIndex = props.ZIndex or 2

    return Fusion.Hydrate(scope, Components:RefUI("ProgressCircle_1"))({
        Name = "ProgressCircle"..props.Direction,
        Position = if props.Direction == "Right" then UDim2.fromScale(0.5, 0) else UDim2.fromScale(0, 0),
        ZIndex = props.ZIndex,

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return if use(props.RotationVal) <= 0 then false else true
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("ProgressImage_PCircle1_1"))({
                Position = if props.Direction == "Right" then UDim2.fromScale(-1, 0) else UDim2.fromScale(0, 0),
                ImageColor3 = props.Color,

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("UIGradient_PCircle1_1"))({
                        Rotation = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local angle = math.clamp(use(props.RotationVal) * 360, 0, 360)

                            return if props.Direction == "Left" then
                                math.clamp(angle, 180, 360) else math.clamp(angle, 0, 180)
                        end),
                    })
                }
            })
        }
    })
end