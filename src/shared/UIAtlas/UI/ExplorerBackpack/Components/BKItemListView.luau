
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ItemBook = require(RepS.HarukaShared.Library.ItemBook)


local BKItemSlot = require(RepS.HarukaShared.UIAtlas.Components.BKItemSlot)

local Children = Fusion.Children


return function(scope: Fusion.Scope, self: { [string]: any }, isBackpackUI: boolean?)
    return Components.ScrollingFrame(scope, {
        Name = "Backpack",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.97, 0.95),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ClipsDescendants = false,

        [Fusion.Out("AbsoluteSize")] = self.ItemListAbsSize,

        [Children] = {
            Fusion.ForPairs(scope, self.Items, function(use: Fusion.Use, scope: Fusion.Scope, index: number, itemSymbol: IntConstrainedValue)
                local info = ItemBook:GetItemInfo(itemSymbol.Name)
                if not info then return nil end

                local isVisible = false
                local isVisibleFactor2 = false
                local category = use(self.CurrentCategory) :: string

                if category == "Misc" then
                    category = { "Quest", "CosmeticArmor", "CosmeticWeapon" }
                elseif category == "Active" then
                    category = { "Consumable", "Active" }
                elseif category == "Accessory" then
                    category = { "Accessory", "Passive" }
                else
                    category = { category }
                end
                isVisible = table.find(category, info.Type) ~= nil


                local tierNum = info.Tier - ((info.Tier - 1) % 2)
                tierNum = math.clamp(tierNum, 1, 3)

                local state = use(self.FilterTierList[tierNum])
                isVisibleFactor2 = state


                local isVisibleFactor3 = false
                local text = use(self.FilterItemText)
                local textWithoutSpaces = string.gsub(text, " ", "")

                if textWithoutSpaces == "" then
                    isVisibleFactor3 = true
                else
                    textWithoutSpaces = textWithoutSpaces :: string

                    if string.find(string.lower(info.Name), string.lower(textWithoutSpaces)) then
                        isVisibleFactor3 = true
                    else
                        isVisibleFactor3 = false
                    end
                end


                if isVisible and isVisibleFactor2 and isVisibleFactor3 then
                    return index, BKItemSlot(scope, {
                        ItemSymbol = itemSymbol,
                        EquippingItems = self.EquippingItems,

                        IsBackpack = isBackpackUI,

                        CurrentSelectedItemUniqueId = self.CurrentSelectedItemUniqueId,
                        CurrentSelectedItem = self.CurrentSelectedItem,
                        CurrentSortOrderList = self.SortMethodList,
                    })
                else
                    return index, nil
                end
            end)
        }
    }, {
        CellSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local size = use(self.ItemListAbsSize) :: Vector2
            local x = size.X * 0.125 * 0.86
            local y = size.X * 0.135 * 0.86

            return UDim2.fromOffset(x, y)
        end),
        CellPadding = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local size = use(self.ItemListAbsSize) :: Vector2
            local x = size.X * 0.015
            local y = size.X * 0.023

            return UDim2.fromOffset(x, y)
        end),

        [Fusion.Out("AbsoluteCellCount")] = self.AvailableItems or Fusion.Value(scope, 0),

        FillDirection = Enum.FillDirection.Horizontal,
    })
end