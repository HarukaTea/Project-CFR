
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local Children = Fusion.Children



local function _getNamePriority(rawName: string?)
    local name = tostring(rawName or "")

    name = string.gsub(name, "%s+", "")
    if name == "" then
        return 14500000
    end

    name = name :: string
    name = string.lower(name)

    local BASE = 27
    local maxChars = 5
    local key = 0

    for i = 1, math.min(#name, maxChars) do
        local ch = string.sub(name, i, i)
        local v

        if string.match(ch, "%a") then
            v = string.byte(ch) - string.byte("a")
            if v < 0 or v > 25 then
                v = 26
            end
        else
            v = 26
        end

        key = key * BASE + v
    end
    if key > 14500000 then
        key = 14500000
    end

    return key
end

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

    local amount = Value(1)
    local uniqueId = props.ItemSymbol:GetAttribute("HarukaUniqueId")


    return Components.Frame(scope, {
        Name = props.ItemSymbol.Name,
        BackgroundTransparency = 0,
        BackgroundColor3 = AssetBook.ItemTierColors[info.Tier],

        LayoutOrder = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local priority = 3

            local T5Sort = use(props.CurrentSortOrderList[1])
            local T1Sort = use(props.CurrentSortOrderList[2])

            local tier = info.Tier or 1
            local nameKey = _getNamePriority(info.Name)

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
            Components.UICorner(scope, { CornerRadius = UDim.new(0.1, 0) }),

            Components.ScaledUIStroke(scope, {
                Thickness = 0.035,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting) or use(props.CurrentSelectedItemUniqueId) == uniqueId
                end)
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,

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

            Components.IconImageLabel(scope, {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.49, 0.35),
                Size = UDim2.fromScale(0.55, 0.55),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,

                Image = info.Icon,
            }),

            Components.TextLabel(scope, {
                Name = "Amount",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.75),
                Size = UDim2.fromScale(1, 0.25),
                BackgroundColor3 = Components.WHITE_COLOR,
                BackgroundTransparency = 0,
                FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),
                TextColor3 = Components.BLACK_COLOR,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local stackableList = AssetBook.StackableItemTypes

                    if table.find(stackableList, info.Type) then
                        return `Lv.{info.Level}`
                    else
                        return `x{use(amount)}`
                    end
                end),

                [Children] = {
                    Components.UICorner(scope, { CornerRadius = UDim.new(0.25, 0) })
                }
            }),
        }
    })
end