
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)


local Children = Fusion.Children


return function (scope: Fusion.Scope<any>, props: {
    PanelId: string,
    LayoutOrder: number,
    PanelTitle: string,

    PanelSelected: Fusion.Value<string>,
})

    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = props.PanelId,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(0.7, 0.09),
        LayoutOrder = props.LayoutOrder,

        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
            return if use(props.PanelSelected) == props.PanelId or use(isSelecting) then Color3.fromRGB(255, 247, 233) else Components.BLACK_COLOR
        end),

        [Children] = {
            Components.RoundUICorner(scope),
            Components.TextLabel(scope, {
                Name = "Title",
                Text = props.PanelTitle,
                TextXAlignment = Enum.TextXAlignment.Left,

                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                    return if use(props.PanelSelected) == props.PanelId or use(isSelecting) then Components.BLACK_COLOR else Color3.fromRGB(255, 247, 233)
                end),

                [Children] = {
                    Components.UIPadding(scope, {})
                }
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    if Fusion.peek(props.PanelSelected) == props.PanelId then return end

                    isSelecting:set(true)
                end,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.PanelSelected:set(props.PanelId)
                end
            })
        }

    })
end