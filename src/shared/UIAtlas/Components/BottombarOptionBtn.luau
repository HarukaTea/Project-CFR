
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Option: string,
    Index: number
}, self: {
    FilterViewShown: Fusion.Value<boolean>
})

    local isSelecting = Fusion.Value(scope, false)

    local ICONS = {
        Filter = "rbxassetid://88154353103061"
    }

    return Fusion.Hydrate(scope, Components:RefUI("LSideBtnTemplate_LS1_1", false, true))({
        Name = props.Option,
        LayoutOrder = props.Index,

        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return if use(isSelecting) then Components.WHITE_COLOR else Components.BLACK_COLOR
        end),

        [Children] = {
            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if props.Option == "Filter" then
                        self.FilterViewShown:set(not Fusion.peek(self.FilterViewShown))
                    end
                end
            }),

            Fusion.Hydrate(scope, Components:RefUI("Icon_LSideBtn1_1"))({
                Image = ICONS[props.Option],

                ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(isSelecting) then Components.BLACK_COLOR else Components.WHITE_COLOR
                end)
            })
        }
    })
end