
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

    return Components.Frame(scope, {
        Name = props.PanelId,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(1, 0.09),
        LayoutOrder = props.LayoutOrder,

        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
            return if use(props.PanelSelected) == props.PanelId or use(isSelecting) then Components.WHITE_COLOR else Components.BLACK_COLOR
        end),

        [Children] = {
            Components.RoundUICorner(scope),
            Components.TextLabel(scope, {
                Name = "Title",
                Text = props.PanelTitle,
                TextXAlignment = Enum.TextXAlignment.Left,

                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                    return if use(props.PanelSelected) == props.PanelId or use(isSelecting) then Components.BLACK_COLOR else Components.WHITE_COLOR
                end),

                [Children] = {
                    Components.UIPadding(scope, {})
                }
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