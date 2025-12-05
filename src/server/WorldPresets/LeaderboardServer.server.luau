
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local ODSModule = require(ServerScriptService.HarukaServer.Shared.OrderedDatastoreWrapper)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)



type LBLibClass = {
    Funcs: { [string]: () -> nil },

    Init: (self: LBLibClass) -> nil
}



local LBLib = {} :: LBLibClass
LBLib.Funcs = {}


local TOP3_BADGE_ID = 2495465107761594

local abyssSpeedrunContainer = Instance.new("Folder")
abyssSpeedrunContainer.Name = "AbyssSpeedrunContainer"
abyssSpeedrunContainer.Parent = workspace.MapComponents


local donationRanksContainer = Instance.new("Folder")
donationRanksContainer.Name = "DonationRankContainer"
donationRanksContainer.Parent = workspace.MapComponents


local userNameCache = {}
local userThumbnailCache = {}


local abyssSpeedrunStore = ODSModule.new(require(ServerScriptService.ABYSS_DS_VERSION), true)
local donationStore = ODSModule.new("_Donation", true)


local STORE_LIST = {
    Abyss = abyssSpeedrunStore,
    Donation = donationStore
}


local function _getTop50Players(store: OrderedDataStore, isAscending: boolean?) : {
    {
        PlayerId: number,
        Val: number
    }
}
    if store == nil then return {} end

    isAscending = isAscending or false

    local pageSize = 50
    local pages = store:GetSortedAsync(isAscending, pageSize)
    local top50 = pages:GetCurrentPage()

    local topList = {}

    for rank, data in ipairs(top50) do
        local key: string = data.key
        local userId = tonumber(string.sub(key, 8))

        table.insert(topList, rank, {
            PlayerId = userId, Val = data.value
        })
    end

    return topList
end
local function refreshLeaderboard(store: OrderedDataStore, folder: Folder, isAscending: boolean?)
    folder:ClearAllChildren()


    local top50 = _getTop50Players(store, isAscending)
    for rank: number, data in ipairs(top50) do
        if (data.Val or 0) <= 0 then continue end

        local stringifyPlayerId = tostring(data.PlayerId)

        Promise.try(function()
            local val = Instance.new("NumberValue")
            val.Name = stringifyPlayerId
            val.Value = data.Val or 0
            val:SetAttribute("Order", rank)

            local playerName = userNameCache[stringifyPlayerId]
            if not playerName then
                userNameCache[stringifyPlayerId] = Players:GetNameFromUserIdAsync(data.PlayerId)
            end

            local playerThumbnail = userThumbnailCache[stringifyPlayerId]
            if not playerThumbnail then
                userThumbnailCache[stringifyPlayerId] = Players:GetUserThumbnailAsync(
                    data.PlayerId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size48x48
                )
            end

            val:SetAttribute("PlayerName", userNameCache[stringifyPlayerId])
            val:SetAttribute("PlayerThumbnail", userThumbnailCache[stringifyPlayerId])
            val.Parent = folder

        end):catch(function()
            local val = Instance.new("NumberValue")
            val.Name = stringifyPlayerId
            val.Value = data.Val or 0
            val:SetAttribute("Order", rank)
            val:SetAttribute("PlayerName", userNameCache[stringifyPlayerId] or "RBX_QUERY_COOLDOWN")
            val:SetAttribute("PlayerThumbnail", userThumbnailCache[stringifyPlayerId] or "")
            val.Parent = folder
        end)
    end
end
local function _checkIsDataValid(data) : boolean?
    if not data then return end
    if not data[1] then return end
    if not data[2] then return end

    if data[1] <= 0 then return end
    if data[1] > 3 then return end

    if not data[2].key then return end
    if not data[2].value then return end

    if data[2].value <= 0 then return end

    return true
end


function LBLib:Init()
    for _, func in self.Funcs do
        task.spawn(func)
    end
end





table.insert(LBLib.Funcs, function()
    HarukaLib.Clock(180, function()
        refreshLeaderboard(abyssSpeedrunStore.orderedDataStore, abyssSpeedrunContainer, true)
    end, true)
    HarukaLib.Clock(60, function()
        refreshLeaderboard(donationStore.orderedDataStore, donationRanksContainer)
    end, true)
end)


table.insert(LBLib.Funcs, function()
    ServerBindables.RToUpdateLeaderboardRank:Connect(function(key: string, value: number, storeName: string)
        if not storeName then return end
        if not STORE_LIST[storeName] then return end
        if not key then return end
        if not value then return end
        if type(value) ~= "number" then return end
        if value <= 0 then return end



        local store = STORE_LIST[storeName]

        store:UpdateAsync(key, value)
    end)

    ServerBindables.RToAwardLeaderboardRank:Connect(function(plr: Player, storeName: string)
        if storeName == "Donation" then
            donationStore:GetOrderedPositionAsync("Player_"..plr.UserId, true):andThen(function(data)
                --// data[1]: rank, data[2]: {key: string, value: number}
                if not _checkIsDataValid(data) then return end

                ServerLib:GiveBadge(TOP3_BADGE_ID, plr)

            end):catch(function() end)
        end
    end)
end)


LBLib:Init()