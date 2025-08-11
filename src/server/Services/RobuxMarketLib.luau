local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local ProfileStore = require(ServerScriptService.HarukaServer.Shared.ProfileStore)


local RobuxMarketLib = {}


local wait = task.wait


--// Dev products purchase callback
local productFunctions = {}

for _, productId in AssetBook.DevProductIds do
    productFunctions[tostring(productId)] = function(receipt: {[string]: any}, player: Player, profile: ProfileStore.Profile)
        local productInfo = MarketplaceService:GetProductInfo(receipt.ProductId, Enum.InfoType.Product)
        assert(productInfo)

        table.insert(profile.Data.DevProductsPurchaseLogs, {
            Purchased = true,
            PurchaseDateTime = DateTime.now():ToIsoDate(),
            PurchasedPrice = productInfo.PriceInRobux,
        })

        profile:Save()
        shared.PlayerLib._RequestToCalculateTotalDonationAndSave(profile, player)
    end
end
local function processReceipt(receiptInfo: {[string]: any})
    local userId = receiptInfo.PlayerId
    local productId = receiptInfo.ProductId

    local player = Players:GetPlayerByUserId(userId)
    if player then
        while player:GetAttribute("HarukaUniqueId") == nil and player.Parent == Players do
            wait()
        end
        wait()

        if player and player:GetAttribute("HarukaUniqueId") and player.Parent == Players then
            local playerObj = shared.PlayerLib.GetPlayerObjByUniqueId(player:GetAttribute("HarukaUniqueId"))
            if playerObj then
                local profile = playerObj.Profile :: ProfileStore.Profile

                if profile and profile:IsActive() then
                    local handler = productFunctions[tostring(productId)]
                    local success, result = pcall(handler, receiptInfo, player, profile)

                    if success then
                        Events.CreateNotify.Fire(player, "You have successfully purchased the product!")
                        return Enum.ProductPurchaseDecision.PurchaseGranted
                    else
                        Events.CreateNotify.Fire(player, "Failed to process receipt!")
                        Events.CreateNotify.Fire(player, "But you didnt lose your Robux!")
                        warn(`Failed to process receipt: `, receiptInfo, result)
                    end
                end
            end
        end
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end
MarketplaceService.ProcessReceipt = processReceipt




MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, gamePassId: number, wasPurchased: boolean)
    if not wasPurchased then return end
    if not player then return end
    if player.Parent ~= Players then return end

    local stringifyGamepassId = tostring(gamePassId)

    local playerObj = shared.PlayerLib.GetPlayerObjByUniqueId(player:GetAttribute("HarukaUniqueId"))
    if not playerObj then return end

    local profile = playerObj.Profile :: ProfileStore.Profile
    if not profile then return end


    pcall(function()
        local gamepassInfo = MarketplaceService:GetProductInfo(gamePassId, Enum.InfoType.GamePass)
        if not gamepassInfo then return end
        if not gamepassInfo.IsForSale then return end

        profile.Data.GamepassPurchaseLogs[stringifyGamepassId] = {
            PurchaseDateTime = DateTime.now():ToIsoDate(),
            Purchased = true,
            PurchasedPrice = gamepassInfo.PriceInRobux
        }
    end)

    profile:Save()
    shared.PlayerLib.CalDonationAndSave(profile, player)


    Events.CreateNotify.Fire(player, "You have successfully purchased the gamepass!")
end)


return RobuxMarketLib