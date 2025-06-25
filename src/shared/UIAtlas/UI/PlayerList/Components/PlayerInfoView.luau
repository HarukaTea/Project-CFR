--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local FrameBorderTex = require(RepS.HarukaShared.UIAtlas.Components.FrameBorderTex)

local New, Children, Computed = Fusion.New, Fusion.Children, Fusion.Computed

local v2New, udNew = Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB


return function (scope: Fusion.Scope, props: {
    PlayerSelecting: Fusion.Value,
})

    return Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        if use(props.PlayerSelecting) == nil then
            return nil

        elseif use(props.PlayerSelecting) ~= nil then
            local player = use(props.PlayerSelecting) :: Player


            local function Value(val: any) : Fusion.Value
                return Fusion.Value(scope, val)
            end
            local level = Value(1)
            local role = Value("")
            local class = Value("Burst")
            local equippingItems = FusionComponents.useFolder(scope, player.EquippingItems)
            local playTime = Value(0)


            table.insert(scope, HarukaLib:Hydrate(player, {
                ["Attr-Role"] = function(thatRole: string)
                    role:set(thatRole)
                end
            }))
            table.insert(scope, HarukaLib:Hydrate(player, {
                ["Attr-Class"] = function(val: string)
                    class:set(val)
                end,
                ["Attr-Level"] = function(val: number)
                    level:set(val)
                end,
                ["Attr-PlayTime"] = function(val: number)
                    playTime:set(val)
                end,
            }))


            local function PlayerItemSlot(index: number): ImageLabel
                local POSITIONS = {
                    fromScale(0.164, 0.391),
                    fromScale(0.401, 0.391),
                    fromScale(0.637, 0.391),
                    fromScale(0.048, 0.558),
                    fromScale(0.28, 0.558),
                    fromScale(0.516, 0.558),
                    fromScale(0.753, 0.558),
                }

                return Components.IconImageLabel(scope, {
                    Name = "Slot"..index,
                    Position = POSITIONS[index],
                    Size = fromScale(0.165, 0.165),

                    Image = Computed(scope, function(use: Fusion.Use, _)
                        local item: StringValue = nil

                        if index <= 3 and index >= 1 then
                            for _, symbol: StringValue in use(equippingItems) do
                                if symbol.Name == "Accessory"..index then
                                    item = symbol
                                    break
                                end
                            end

                        elseif index <= 6 and index >= 4 then
                            for _, symbol: StringValue in use(equippingItems) do
                                if symbol.Name == "Active"..(index - 3) then
                                    item = symbol
                                    break
                                end
                            end

                        elseif index == 7 then
                            for _, symbol: StringValue in use(equippingItems) do
                                if symbol.Name == "Weapon1" then
                                    item = symbol
                                    break
                                end
                            end

                            if item == nil then return AssetBook.ExtraIcons.Null end

                            local itemInfo = ItemBook:GetItemInfo(item.Value)
                            if itemInfo == nil then return AssetBook.ExtraIcons.Unknown end

                            return itemInfo.Icon
                        end

                        if item == nil then return AssetBook.ExtraIcons.Null end

                        local itemInfo = ItemBook:GetItemInfo(item.Value)
                        if itemInfo == nil then return AssetBook.ExtraIcons.Unknown end

                        return itemInfo.Icon
                    end)
                })
            end

            return Components.Frame(scope, {
                Name = "PlayerInfo",
                AnchorPoint = v2New(1, 0),
                Position = fromScale(0.72, 1.5),
                Size = fromScale(0.15, 4.5),
                ZIndex = 10,

                [Children] = {
                    Components.Frame(scope, {
                        Name = "DescBG",
                        AnchorPoint = v2New(),
                        Position = fromScale(0, 0),
                        BackgroundTransparency = 0.1,
                        ZIndex = 0,

                        Size = Fusion.Computed(scope, function(use: Fusion.Use)
                            return if use(role) then UDim2.fromScale(1, 0.86) else UDim2.fromScale(1, 0.77)
                        end),

                        [Children] = {
                            New(scope, "UICorner")({ CornerRadius = udNew(0.05, 0) }),

                            FrameBorderTex(scope, {
                                BorderType = "Outer",
                                Offset = 3
                            }),
                        }
                    }),
                    Components.IconImageLabel(scope, {
                        Name = "Class",
                        Position = fromScale(0.05, 0.055),
                        Size = fromScale(0.175, 0.175),

                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(class) :: string

                            if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                            return ClassBook[classId].Icon
                        end),
                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(class) :: string

                            if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                            return ClassBook[classId].Color
                        end),
                    }),
                    Components.TextLabel(scope, {
                        Name = "DisplayName",
                        Position = fromScale(0.3, 0.05),
                        Size = fromScale(0.63, 0.095),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoLocalize = false,

                        Text = Computed(scope, function(use: Fusion.Use)
                            return use(props.PlayerSelecting).DisplayName
                        end)
                    }),
                    Components.TextLabel(scope, {
                        Name = "UserName",
                        Position = fromScale(0.3, 0.15),
                        Size = fromScale(0.63, 0.06),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = fromRGB(193, 193, 193),
                        AutoLocalize = false,

                        Text = Computed(scope, function(use: Fusion.Use)
                            return `@{use(props.PlayerSelecting).Name}`
                        end)
                    }),
                    Components.TextLabel(scope, {
                        Name = "LevelAndPlayTime",
                        Position = fromScale(0.06, 0.245),
                        Size = fromScale(0.866, 0.077),
                        TextColor3 = fromRGB(255, 255, 0),

                        Text = Computed(scope, function(use: Fusion.Use)
                            local playTime = use(playTime) :: number
                            local convertedTime = playTime / 3600
                            local isHour = true

                            if convertedTime < 1 then
                                isHour = false
                                convertedTime = playTime / 60
                            end

                            if isHour then
                                playTime = `{string.format("%.1f", convertedTime)} Hours`
                            else
                                playTime = `{string.format("%.0f", convertedTime)} Minutes`
                            end


                            return `Lv.{use(level)} - {playTime}`
                        end)
                    }),
                    New(scope, "Frame")({
                        Name = "HorizonLine",
                        AnchorPoint = v2New(0.5, 0),
                        Position = fromScale(0.5, 0.35),
                        Size = fromScale(0.9, 0.005),
                        BackgroundTransparency = 0.7
                    }),

                    PlayerItemSlot(1),
                    PlayerItemSlot(2),
                    PlayerItemSlot(3),
                    PlayerItemSlot(4),
                    PlayerItemSlot(5),
                    PlayerItemSlot(6),
                    PlayerItemSlot(7),

                    Components.TextLabel(scope, {
                        Name = "Role",
                        Position = fromScale(0.06, 0.751),
                        Size = fromScale(0.865, 0.06),
                        TextTransparency = 0.2,

                        Text = Computed(scope, function(use: Fusion.Use)
                            return `- {use(role)} -`
                        end),
                        Visible = Computed(scope, function(use: Fusion.Use)
                            local thatRole = use(role) :: string

                            return thatRole ~= nil and thatRole ~= ""
                        end)
                    }),
                },
            })
        end
    end)
end
