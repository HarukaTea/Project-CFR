
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Events = require(RepS.HarukaShared.Library.Events)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local RankBook = require(RepS.HarukaShared.Library.RankBook)

local Children, Computed = Fusion.Children, Fusion.Computed

local fromScale = UDim2.fromScale

local plr = Players.LocalPlayer

return function (scope: Fusion.Scope, props: {
    PlayerSelecting: Fusion.Value<Player?>,
    PartyMembers: Fusion.Value<{ ObjectValue }>
})

    return Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        if use(props.PlayerSelecting) == nil then return nil end

        local player = use(props.PlayerSelecting) :: Player

        local function Value<T>(val: T) : Fusion.Value<T>
            return Fusion.Value(scope, val)
        end
        local level = Value(1)
        local playerRoleTitle = Value("")
        local class = Value("Burst")
        local equippingItems = Components.FusionComponents.useChildren(scope, player.EquippingItems)
        local playTime = Value(0)

        table.insert(scope, HarukaLib:Hydrate(player, {
            ["Attr-Title"] = function(thatTitle: string)
                playerRoleTitle:set(thatTitle)
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

        local function redButtonBase(text: string, func: () -> nil) : TextButton
            return Fusion.Hydrate(scope, Components:RefUI("DeclineButton_PInfo1_1", true))({
                Text = text,

                [Fusion.OnEvent("MouseButton1Click")] = func,
            })
        end

        local button: TextButton = nil
        button = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local partyMembers = use(props.PartyMembers) :: { ObjectValue }

            if player == plr then
                if table.find(partyMembers, plr) then
                    return redButtonBase("LEAVE PARTY", function()
                        Events.PartyInvite_C.Fire({
                            Option = "PartyLeave", PlayerName = plr.Name
                        })
                    end)
                else
                    return redButtonBase("MAGIC BUTTON", function()
                        Bindables.CreateNotify:Fire("Yes it does nothing lol")
                    end)
                end
            else
                if table.find(partyMembers, player) then
                    return redButtonBase("KICK FROM PARTY", function()
                        Events.PartyInvite_C.Fire({
                            Option = "PartyKick", PlayerName = player.Name
                        })
                    end)
                else
                    return Fusion.Hydrate(scope, Components:RefUI("AcceptButton_PInfo1_1", true))({
                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            Bindables.RToCreatePartyInvite:Fire(player)
                        end
                    })
                end
            end
        end)

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

            return Fusion.Hydrate(scope, Components:RefUI("Slot_PInfo1_1", true))({
                Name = "Slot"..index,
                Position = POSITIONS[index],

                Image = Computed(scope, function(use: Fusion.Use, _)
                    local item: StringValue = nil
                    local equippingItemsState = use(equippingItems)

                    if index <= 3 and index >= 1 then
                        for _, symbol: StringValue in equippingItemsState do
                            if symbol.Name == "Accessory"..index then
                                item = symbol
                                break
                            end
                        end

                    elseif index <= 6 and index >= 4 then
                        for _, symbol: StringValue in equippingItemsState do
                            if symbol.Name == "Active"..(index - 3) then
                                item = symbol
                                break
                            end
                        end

                    elseif index == 7 then
                        for _, symbol: StringValue in equippingItemsState do
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

        return Fusion.Hydrate(scope, Components:RefUI("PlayerInfo_PL1_1", false, true, {
            "HorizonLine", "Emblem"
        }))({
            [Children] = {
                Fusion.Hydrate(scope, Components:RefUI("Class_PInfo1_1", true))({
                    Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        local classId = use(class) :: string

                        if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                        return ClassBook[classId].Icon
                    end),
                    ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        local classId = use(class) :: string

                        if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                        return ClassBook[classId].Color
                    end)
                }),

                Fusion.Hydrate(scope, Components:RefUI("DisplayName_PInfo1_1"))({
                    Text = player.DisplayName
                }),
                Fusion.Hydrate(scope, Components:RefUI("UserName_PInfo1_1"))({
                    Text = `@{player.Name}`
                }),

                Fusion.Hydrate(scope, Components:RefUI("LevelAndPlayTime_PInfo1_1"))({
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

                Fusion.Hydrate(scope, Components:RefUI("Title_PInfo1_1"))({
                    TextColor3 = Computed(scope, function(use: Fusion.Use)
                        local info = RankBook.PlayerTitleInfo[use(playerRoleTitle)] or {
                            Color = "#ffffff"
                        }
                        return Color3.fromHex(info.Color)
                    end),
                    Text = Computed(scope, function(use: Fusion.Use)
                        return `- {use(playerRoleTitle)} -`
                    end)
                }),

                PlayerItemSlot(1),
                PlayerItemSlot(2),
                PlayerItemSlot(3),
                PlayerItemSlot(4),
                PlayerItemSlot(5),
                PlayerItemSlot(6),
                PlayerItemSlot(7),

                button,
            }
        })
    end)
end