
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Class: Fusion.Value<string>,
    EquippingPassives: {
        {
            Id: string,
            ItemId: Fusion.Value<string>,
            ItemUniqueId: Fusion.Value<string>,
        }
    },
    EquippingItems: Fusion.Value<{ StringValue }>,
})

    return Components.IconImageLabel(scope, {
        Name = "Weapon",
        AnchorPoint = Vector2.yAxis,
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.fromScale(1.7, 1.7),
        ZIndex = 10,

        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local equippingItems = use(props.EquippingItems) :: { any }
            local weapon: StringValue = nil

            for _, symbol: StringValue in equippingItems do
                if symbol.Name == "Weapon1" then
                    weapon = symbol
                    break
                end
            end
            if weapon == nil then
                return AssetBook.ExtraIcons.Null
            end

            local weaponId = weapon.Value :: string
            local itemInfo = ItemBook:GetItemInfo(weaponId)

            if itemInfo == nil then
                return AssetBook.ExtraIcons.Unknown
            end

            return itemInfo.Icon
        end),

        [Children] = {
            Components.IconImageLabel(scope, {
                Name = "Class",
                AnchorPoint = Vector2.yAxis,
                Position = UDim2.fromScale(-0.1, 1),
                Size = UDim2.fromScale(0.5, 0.5),

                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local classId = use(props.Class) :: string

                    if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                    return ClassBook[classId].Icon
                end),
                ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local classId = use(props.Class) :: string

                    if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                    return ClassBook[classId].Color
                end),
            }),

            Fusion.New(scope, "Folder")({
                Name = "Passives",

                [Children] = {
                    Fusion.ForPairs(scope, props.EquippingPassives, function(use: Fusion.Use, scope: Fusion.Scope, index: number, info)
                        local RADIANS = { -35, 0, 35 }
                        local r = 0.85

                        local item = use(info.ItemId) :: string
                        local itemInfo = ItemBook:GetItemInfo(item)
                        if itemInfo == nil then return index, nil end

                        return index, Components.IconImageLabel(scope, {
                            Name = "Passive"..index,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Size = UDim2.fromScale(0.45, 0.45),

                            Image = Fusion.Computed(scope, function()
                                if itemInfo == nil then
                                    return AssetBook.ExtraIcons.Null
                                end

                                return itemInfo.Icon
                            end),

                            Position = UDim2.fromScale(
                                r * math.cos(math.rad(RADIANS[4 - index])) + 0.5,
                                r * math.sin(math.rad(RADIANS[4 - index])) + 0.5
                            )
                        })
                    end)
                }
            })
        }

    })
end