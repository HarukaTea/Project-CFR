
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope<any>, props: {
    QuestType: string,
    WorldPoint: Vector3,

    CharPoint: Fusion.Value<Vector3>
})

    return Components.Frame(scope, {
        Name = "Marker",

        [Children] = {
            Components.Frame(scope, {
                Name = "Symbol",
                BackgroundColor3 = AssetBook.QuestTypeColors[props.QuestType],
                BackgroundTransparency = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0),
                Size = UDim2.fromScale(0.3, 0.3),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.ScaledUIStroke(scope, {
                        Thickness = 0.15,
                        Color = Components.BLACK_COLOR
                    })
                }
            }),

            Components.TextLabel(scope, {
                Name = "Distance",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.4),
                Size = UDim2.fromScale(1, 0.4),
                AutoLocalize = false,

                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    local distance = math.ceil((use(props.CharPoint) - props.WorldPoint).Magnitude)

                    return `{distance}M`
                end),

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {})
                }
            })
        }
    })
end