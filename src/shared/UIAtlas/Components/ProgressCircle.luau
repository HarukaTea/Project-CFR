--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local nsNew, nsKPNew = NumberSequence.new, NumberSequenceKeypoint.new
local clamp = math.clamp


return function (scope: Fusion.Scope, props: {
    Direction: "Left" | "Right",
    RotationVal: Fusion.Value,
    ZIndex: number?,

    Color: Color3?

}) : Frame

    props.Color = props.Color or Color3.fromRGB(255, 255, 255)
    props.ZIndex = props.ZIndex or 2

    return Components.Frame(scope, {
        Name = "ProgressCircle"..props.Direction,
        ClipsDescendants = true,
        AnchorPoint = v2New(),
        Position = if props.Direction == "Right" then fromScale(0.5, 0) else fromScale(0, 0),
        Size = fromScale(0.5, 1),
        ZIndex = props.ZIndex,

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return if use(props.RotationVal) <= 0 then false else true
        end),

        [Children] = {
            Components.ImageLabel(scope, {
                Name = "ProgressImage",
                Position = if props.Direction == "Right" then fromScale(-1, 0) else fromScale(0, 0),
                Size = fromScale(2, 1),
                Image = "rbxasset://textures/ui/Controls/RadialFill.png",

                ImageColor3 = props.Color,

                [Children] = {
                    Components.UIGradient(scope, {
                        Rotation = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local angle = clamp(use(props.RotationVal) * 360, 0, 360)

                            return if props.Direction == "Left" then clamp(angle, 180, 360) else clamp(angle, 0, 180)
                        end),
                        Transparency = nsNew({
                            nsKPNew(0, 0, 0),
                            nsKPNew(0.499, 0, 0), nsKPNew(0.5, 1, 0),
                            nsKPNew(1, 1, 0)
                        })
                    })
                }
            })
        }
    })
end
