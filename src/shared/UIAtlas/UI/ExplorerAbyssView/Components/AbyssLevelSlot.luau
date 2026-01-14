
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local AbyssBook = require(RepS.HarukaShared.Library.AbyssBook)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Index: number,
    AbyssIndexSelected: Fusion.Value<number>,
    IsInfoUI: boolean
})

    local isSelecting = Fusion.Value(scope, false)

    local aspectRatioConstraint = nil
    local size = UDim2.fromScale(0.15, 0.8)
    if not props.IsInfoUI then
        aspectRatioConstraint = Components.UIAspectRatioConstraint(scope, 0.378)
    end

    return Fusion.Hydrate(scope, Components:RefUI("Level_EAbyss2_1", false, false, {
        "UICorner", "CAPatternTex", "HighlightTex"
    }))({
        Name = "AbyssLevelSlot"..props.Index,
        LayoutOrder = props.Index,
        Size = size,

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.03,

                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(isSelecting) then Color3.fromHex('#66d9e8') else Components.WHITE_COLOR
                end)
            }),
            aspectRatioConstraint,

            Fusion.Hydrate(scope, Components:RefUI("Icon_EAbyss2_2", true))({
                Image = AbyssBook.TeamConfigIcons[props.Index]
            }),

            Fusion.Hydrate(scope, Components:RefUI("Level_EAbyss2_2"))({
                Text = tostring(props.Index)
            }),

            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if props.IsInfoUI then return end
                    props.AbyssIndexSelected:set(props.Index)
                end
            })
        }
    })
end