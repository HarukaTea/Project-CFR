
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    ItemSymbol: IntConstrainedValue,

    CurrentSelectedItemUniqueId: Fusion.Value<string>,
    CurrentSelectedItem: Fusion.Value<string>,
    CurrentSortOrderList: { Fusion.Value<boolean> }
})
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(scope, val)
    end

    local info = ItemBook:GetItemInfo(props.ItemSymbol.Name)
    if not info then return nil end

    local isSelecting = Value(false)
    local uniqueId = props.ItemSymbol:GetAttribute("HarukaUniqueId")

    return Fusion.Hydrate(scope, Components:RefUI("BKQuickItemSlot_1", false, false, {
        "UICorner"
    }))({
        Name = props.ItemSymbol.Name,
        BackgroundColor3 = AssetBook.ItemTierColors[info.Tier],

        LayoutOrder = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local priority = 3

            local T5Sort = use(props.CurrentSortOrderList[1])
            local T1Sort = use(props.CurrentSortOrderList[2])

            local tier = info.Tier or 1
            local nameKey = HarukaLib:GetNameOrder(info.Name)

            local tierOrder = 0
            if T1Sort then
                tierOrder = tier
            elseif T5Sort then
                tierOrder = 7 - tier
            end

            local perGroupOrder = tierOrder * 20000000 + nameKey
            local layoutOrder = priority * 200000000 + perGroupOrder

            return layoutOrder
        end),

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.035,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting) or use(props.CurrentSelectedItemUniqueId) == uniqueId
                end)
            }),

            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if Fusion.peek(props.CurrentSelectedItemUniqueId) == uniqueId then
                        props.CurrentSelectedItemUniqueId:set("")
                        props.CurrentSelectedItem:set("")
                        return
                    end

                    props.CurrentSelectedItemUniqueId:set(uniqueId)
                    props.CurrentSelectedItem:set(props.ItemSymbol.Name)
                end
            }),

            Fusion.Hydrate(scope, Components:RefUI("Icon_BKQIS1_1", true))({
                Image = info.Icon
            }),

            Fusion.Hydrate(scope, Components:RefUI("Level_BKQIS1_1", true))({
                Text = `Lv.{info.Level}`,
            })
        }
    })
end