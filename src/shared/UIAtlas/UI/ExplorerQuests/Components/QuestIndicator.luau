
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    QuestType: string,
    WorldPoint: Vector3,
    CharPoint: Fusion.Value<Vector3>,

    COLORS: { [string]: Color3 }
})

    return Components.Frame(scope, {
        Name = "Marker",

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Symbol_QInfo1_1", true))({
                BackgroundColor3 = props.COLORS[props.QuestType]
            }),

            Fusion.Hydrate(scope, Components:RefUI("Distance_QInfo1_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    local distance = math.ceil((use(props.CharPoint) - props.WorldPoint).Magnitude)
                    return `{distance}M`
                end),
            })
        }
    })
end