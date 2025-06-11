--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local StarTierSymbol = require(RepS.HarukaShared.UIAtlas.Components.StarTierSymbol)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    ItemSymbol: IntConstrainedValue,
    EquippingItems: Fusion.Value,

    CurrentSelectedItemUniqueId: Fusion.Value,
    CurrentSelectedItem: Fusion.Value,
    CurrentSortOrderList: { Fusion.Value }
})
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(scope, val)
    end

    local info = ItemLib:GetItemInfo(props.ItemSymbol.Name)
    if not info then return nil end

    local isSelecting = Value(false)
    local isVisible = Value(true)
    local isVisibleFactor2 = Value(true)
    local isVisibleFactor3 = Value(true)
    local isEquipping = Value(false)


    local amount = Value(1)
    local level = Value(1)
    local isNew = Value(false)
    local uniqueId = props.ItemSymbol:GetAttribute("HarukaUniqueId")


    table.insert(scope, HarukaLib:Hydrate(props.ItemSymbol, {
        ["Prop-Value"] = function(val: number)
            amount:set(val)
        end,
        ["Attr-Level"] = function(val: number)
            level:set(val)
        end,
        ["Attr-IsNew"] = function(val: boolean)
            isNew:set(val)
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
            local AZSort = use(props.CurrentSortOrderList[1])
            local ZASort = use(props.CurrentSortOrderList[2])

            local T1Sort = use(props.CurrentSortOrderList[3])
            local T5Sort = use(props.CurrentSortOrderList[4])

            if AZSort or ZASort then
                local firstChar = string.sub(info.Name, 1, 1)
                local charCode = string.byte(firstChar)

                if string.match(firstChar, "%a") then
                    local baseCode
                    if charCode >= 65 and charCode <= 90 then
                        baseCode = 65
                    elseif charCode >= 97 and charCode <= 122 then
                        baseCode = 97
                    else
                        return 0
                    end

                    if AZSort then
                        return charCode - baseCode + 1
                    elseif ZASort then
                        return 27 - (charCode - baseCode)
                    end
                else
                    return 0
                end

            elseif T1Sort or T5Sort then
                if T1Sort then
                    return info.Tier
                elseif T5Sort then
                    return 6 - info.Tier
                end
            end

            return 1
        end),


        [Children] = {
            Components.UICorner(scope, { CornerRadius = UDim.new(0.1, 0) }),

            Components.UIGradient(scope, {
                Color = ColorSequence.new(AssetBook.TierColorsType2[info.Tier]),
                Rotation = 45
            }),

            Components.UIStroke(scope, {
                Thickness = 2.5,

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
                Size = UDim2.fromScale(0.5, 0.5),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,

                Image = info.Icon,
            }),

            Components.Frame(scope, {
                Name = "TierShowcase",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.62),
                Size = UDim2.fromScale(1, 0.17),
                ZIndex = 2,

                [Children] = {
                    Components.UIListLayout(scope, {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }),

                    Fusion.ForValues(scope, table.create(info.Tier, true), function(_, scope: Fusion.Scope, _)
                        return StarTierSymbol(scope)
                    end)
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
                    local stackableList = { "Accessory", "Weapon", "Active", "Passive" }

                    if table.find(stackableList, info.Type) then
                        return `Lv.{use(level)}`
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
