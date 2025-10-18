--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local LocationBook = require(RepS.HarukaShared.Library.LocationBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    AreaVal: Fusion.Value
})

    local absTextSize = Fusion.Value(scope, Vector2.zero)

    return Components.Frame(scope, {
        Name = "AreaPopup",
        Position = UDim2.fromScale(0.5, 1.5),

        [Children] = {
            Components.TextLabel(scope, {
                Name = "AreaName",
                AutomaticSize = Enum.AutomaticSize.X,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0),
                Size = UDim2.fromScale(0, 0.8),

                [Fusion.Out("AbsoluteSize")] = absTextSize,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local area = use(props.AreaVal) :: string

                    if not LocationBook[area] and area ~= "None" then
                        warn(`Lacking of location data for area: {area}`)
                        return ""
                    end
                    if area == "None" then
                        return ""
                    end

                    return LocationBook[area].Name
                end),

                [Children] = {
                    Components.UIPadding(scope, {}),
                    Components.TextUIStroke(scope, { Thickness = 2.5 })
                }
            }),

            Components.Frame(scope, {
                Name = "AreaDecoBar",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.9),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0,

                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return UDim2.new(0, use(absTextSize).X + 15.99 * 2.599, 0.08, 0)

                end), AssetBook.TweenInfos.one),
            })
        }
    })
end