
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    PanelId: string,
    LayoutOrder: number,
    PanelTitle: string,

    PanelSelected: Fusion.Value<string>,
})

    local isSelecting = Fusion.Value(scope, false)

    return Fusion.Hydrate(scope, Components:RefUI("CategoryBtnT_Settings1_3", false, true))({
        Name = props.PanelId,
        LayoutOrder = props.LayoutOrder,

        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
            return if use(props.PanelSelected) == props.PanelId or use(isSelecting) then Components.WHITE_COLOR else Components.BLACK_COLOR
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Title_CBTS1_4", true))({
                Text = props.PanelTitle,

                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                    return if use(props.PanelSelected) == props.PanelId or use(isSelecting) then Components.BLACK_COLOR else Components.WHITE_COLOR
                end),
            }),

            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.PanelSelected:set(props.PanelId)
                end
            })
        }
    })
end