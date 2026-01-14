
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    ItemId: string,
    Items: Fusion.Value<{ IntConstrainedValue }>,
    Amount: number,

    SelectedMaterialVal: Fusion.Value<string>,
})
    local itemInfo = ItemBook:GetItemInfo(props.ItemId)
    if not itemInfo then return nil end

    local isSelecting = Fusion.Value(scope, false)
    local totalAmount = Fusion.Value(scope, 0)

    local itemsObserver = Fusion.Observer(scope, props.Items)
    itemsObserver:onBind(function()
        local items = Fusion.peek(props.Items)
        local amount = 0

        for _, item: IntConstrainedValue in items do
            if item.Name == props.ItemId then
                amount += item.Value
            end
        end

        totalAmount:set(amount)
    end)

    return Fusion.Hydrate(scope, Components:RefUI("CraftMaterialTemplate_ECraft1_1", false, false, {
        "UICorner"
    }))({
        Image = itemInfo.Icon,
        LayoutOrder = if props.ItemId == "GOLD" then 233 else 1,

        [Children] = {
            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.SelectedMaterialVal:set(props.ItemId)
                end
            }),

            Components.ScaledUIStroke(scope, {
                Thickness = 0.05,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Amount_CMTCraft1_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `{use(totalAmount)}/{props.Amount}`
                end),
                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(totalAmount) >= props.Amount then Color3.fromRGB(85, 255, 127) else Color3.fromRGB(255, 118, 117)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("ItemName_CMTCraft1_1"))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end),

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ItemName_CMTCraft1_1", true))({
                        Text = itemInfo.Name,
                    }),
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Tip_CMTCraft1_1"))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end),

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ItemName_CMTCraft1_1", true))({
                        Text = "CLICK ITEM FOR MORE INFO",
                    }),
                }
            })
        }
    })
end