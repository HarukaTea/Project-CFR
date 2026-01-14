
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    ItemSymbol: IntConstrainedValue,
    EquippingItems: Fusion.Value<{ StringValue }>,

    IsBackpack: boolean?,

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
    local isEquipping = Value(false)

    local amount = Value(1)
    local isNew = Value(false)
    local isFav = Value(false)
    local isLocked = Value(false)
    local uniqueId = props.ItemSymbol:GetAttribute("HarukaUniqueId")

    table.insert(scope, HarukaLib:Hydrate(props.ItemSymbol, {
        ["Prop-Value"] = function(val: number)
            amount:set(val)
        end,
        ["Attr-IsNew"] = function(val: boolean)
            isNew:set(val)
        end,
        ["Attr-IsFav"] = function(val: boolean)
            isFav:set(val)
        end,
        ["Attr-IsLocked"] = function(val: boolean)
            isLocked:set(val)
        end
    }))

    local equippingObserver = Fusion.Observer(scope, props.EquippingItems)
    equippingObserver:onBind(function()
        local found = false

        for _, equipping: StringValue in Fusion.peek(props.EquippingItems) do
            if (equipping:GetAttribute("HarukaUniqueId")) == props.ItemSymbol:GetAttribute("HarukaUniqueId") then
                found = true
                break
            end
        end

        isEquipping:set(found)
    end)

    return Fusion.Hydrate(scope, Components:RefUI("BKItemSlot_1", false, false, {
        "UICorner"
    }))({
        Name = props.ItemSymbol.Name,
        BackgroundColor3 = AssetBook.ItemTierColors[info.Tier],

        LayoutOrder = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local priority = 3

            if use(isFav) and props.IsBackpack then
                priority = 0
            elseif use(isEquipping) then
                priority = 1
            elseif use(isNew) then
                priority = 2
            end

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

                    props.ItemSymbol:SetAttribute("IsNew", false)
                end
            }),

            Fusion.Hydrate(scope, Components:RefUI("Icon_BKIS1_1", true))({
                Image = info.Icon
            }),

            Fusion.Hydrate(scope, Components:RefUI("Amount_BKIS1_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local stackableList = AssetBook.StackableItemTypes
                    if table.find(stackableList, info.Type) then
                        return `Lv.{info.Level}`
                    else
                        return `x{use(amount)}`
                    end
                end),
            }),

            Fusion.Hydrate(scope, Components:RefUI("IsFav_BKIS1_1", true))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isFav)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("IsLocked_BKIS1_1", true))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isLocked)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Equipping_BKIS1_1", true))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isEquipping)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("IsNew_BKIS1_1", true))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isNew)
                end),
            }),
        }
    })
end