
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local StarTierSymbol = require(RepS.HarukaShared.UIAtlas.Components.StarTierSymbol)

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
    local isVisible = Value(true)
    local isVisibleFactor2 = Value(true)
    local isVisibleFactor3 = Value(true)
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



    return Components.Frame(scope, {
        Name = props.ItemSymbol.Name,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(isVisible) and use(isVisibleFactor2) and use(isVisibleFactor3)
        end),

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
            local nameKey = _getNamePriority(info.Name)

            local tierOrder = 0
            if T1Sort then
                tierOrder = tier
            elseif T5Sort then
                tierOrder = 6 - tier
            end

            local perGroupOrder = tierOrder * 20000000 + nameKey
            local layoutOrder = priority * 200000000 + perGroupOrder

            return layoutOrder
        end),


        [Children] = {
            Components.UICorner(scope, { CornerRadius = UDim.new(0.1, 0) }),

            Components.UIGradient(scope, {
                Color = ColorSequence.new(AssetBook.ItemTierColors[info.Tier]),
                Rotation = 45
            }),

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

                    props.ItemSymbol:SetAttribute("IsNew", false)
                end
            }),

            Components.IconImageLabel(scope, {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.49, 0.35),
                Size = UDim2.fromScale(0.55, 0.55),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,

                Image = info.Icon,
            }),

            Components.Frame(scope, {
                Name = "IsFav",
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(0.05, 0.05),
                Size = UDim2.fromScale(0.2, 0.2),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundColor3 = Color3.fromRGB(),
                BackgroundTransparency = 0,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isFav)
                end),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.ImageLabel(scope, {
                        Name = "Star",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.7, 0.7),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        Image = "rbxassetid://114302766654339",
                        ImageColor3 = Color3.fromRGB(255, 204, 50)
                    })
                }
            }),
            Components.Frame(scope, {
                Name = "IsLocked",
                AnchorPoint = Vector2.one,
                Position = UDim2.fromScale(0.95, 0.7),
                Size = UDim2.fromScale(0.2, 0.2),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                BackgroundColor3 = Color3.fromRGB(),
                BackgroundTransparency = 0,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isLocked)
                end),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.ImageLabel(scope, {
                        Name = "Lock",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(0.7, 0.7),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        Image = "rbxassetid://118831261287451",
                        ImageColor3 = Color3.fromRGB(231, 76, 60)
                    })
                }
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

            Components.TextLabel(scope, {
                Name = "Equipping",
                AnchorPoint = Vector2.xAxis,
                Position = UDim2.fromScale(1.1, -0.1),
                Size = UDim2.fromScale(0.3, 0.3),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                BackgroundTransparency = 0,
                BackgroundColor3 = Color3.fromHex('#40407a'),

                Text = "E",

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isEquipping)
                end),

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            }),

            Components.TextLabel(scope, {
                Name = "IsNew",
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(-0.1, -0.1),
                Size = UDim2.fromScale(0.25, 0.25),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                BackgroundTransparency = 0,
                BackgroundColor3 = Color3.fromRGB(195, 0, 0),

                Text = "!",
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.ExtraBold),

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isNew)
                end),

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            })
        }
    })
end