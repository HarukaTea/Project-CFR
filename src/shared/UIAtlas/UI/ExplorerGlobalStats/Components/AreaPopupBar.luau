
local RepS = game:GetService("ReplicatedStorage")

local LocationBook = require(RepS.HarukaShared.Library.LocationBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    AreaVal: Fusion.Value<string>
})

    local absTextSize = Fusion.Value(scope, Vector2.zero)

    return Fusion.Hydrate(scope, Components:RefUI("AreaPopup_APA1_1"))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("AreaDecoBar_APA1_1"))({
                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return UDim2.new(0, use(absTextSize).X + 15.99 * 2.599, 0.08, 0)
                end), Components.TweenInfos.one),
            }),

            Fusion.Hydrate(scope, Components:RefUI("AreaName_APA1_1", true))({
                [Fusion.Out("AbsoluteSize")] = absTextSize,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local area = use(props.AreaVal) :: string

                    if not LocationBook[area] and area ~= "None" then
                        warn(`Lacking of location data for area: {area}`)
                        return ""
                    end
                    if area == "None" then return "" end

                    return LocationBook[area].Name
                end),
            })
        }
    })
end