
repeat task.wait() until workspace:GetAttribute("Haruka_ServerPlayerLibInited")

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local HarukaDatastore = require(ServerScriptService.HarukaServer.Shared.HarukaDatastore)
local PlayerProfileLib = require(ServerScriptService.HarukaServer.Services.PlayerProfileLib)

local PlayerTemplate = require(ServerScriptService.HarukaServer.Library.PlayerTemplate)

local wait = task.wait

--// Dev products purchase callback
local productFunctions = {}

for _, productId in AssetBook.DevProductIds do
    productFunctions[tostring(productId)] = function(receipt: {[string]: any}, player: Player, profile: HarukaDatastore.Profile<PlayerTemplate.JSON>)
        local productInfo = MarketplaceService:GetProductInfoAsync(receipt.ProductId, Enum.InfoType.Product)
        assert(productInfo)

        table.insert(profile.Data.DevProductsPurchaseLogs, {
            Purchased = true,
            PurchaseDateTime = DateTime.now():ToIsoDate(),
            PurchasedPrice = productInfo.PriceInRobux,
        })

        profile:SaveProfileAsync()
        PlayerProfileLib.CalDonationAndSave(profile, player)
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
            local profileObj = PlayerProfileLib:GetObjByUniqueId(player:GetAttribute("HarukaUniqueId"))
            if profileObj then
                local profile = profileObj.Profile
                if profile then
                    local handler = productFunctions[tostring(productId)]
                    local success, result = pcall(handler, receiptInfo, player, profile)

                    if success then
                        Events.CreateNotify_S.Fire(player, "You have successfully purchased the product!")
                        return Enum.ProductPurchaseDecision.PurchaseGranted
                    else
                        Events.CreateNotify_S.Fire(player, "Failed to process your purchase receipt!")
                        Events.CreateNotify_S.Fire(player, "!!! PLEASE CONTACT DEVELOPERS IN THE COMMUNITY FOR SUPPORT !!!")
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

    local profileObj = PlayerProfileLib:GetObjByUniqueId(player:GetAttribute("HarukaUniqueId"))
    if not profileObj then return end

    local profile = profileObj.Profile
    if not profile then return end

    pcall(function()
        local gamepassInfo = MarketplaceService:GetProductInfoAsync(gamePassId, Enum.InfoType.GamePass)
        if not gamepassInfo then return end
        if not gamepassInfo.IsForSale then return end

        local gamepassName = nil
        for gpName: string, gpId: number in AssetBook.GamepassIds do
            if gpId == gamePassId then
                gamepassName = gpName
                break
            end
        end
        if not gamepassName then return end

        profile.Data.GamepassPurchaseLogs[gamepassName] = {
            PurchaseDateTime = DateTime.now():ToIsoDate(),
            Purchased = true,
            PurchasedPrice = gamepassInfo.PriceInRobux
        }
    end)

    Events.CreateNotify_S.Fire(player, "You have successfully purchased the gamepass!")

    profile:SaveProfileAsync()
    PlayerProfileLib.CalDonationAndSave(profile, player)
end)
