--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local QuestBook = require(RepS.HarukaShared.Library.QuestBook)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    QuestType: string,
    WorldPoint: Vector3,

    CharPoint: Fusion.Value
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
                    Components.UIStroke(scope, {
                        Thickness = 2,
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
                    local distance = math.floor((use(props.CharPoint) - props.WorldPoint).Magnitude)

                    return `{distance}M`
                end),


                [Children] = {
                    Components.TextUIStroke(scope, {
                        Thickness = 2
                    })
                }
            })
        }
    })
end
