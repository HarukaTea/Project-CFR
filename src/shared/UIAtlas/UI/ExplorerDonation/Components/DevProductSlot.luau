
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

local plr = Players.LocalPlayer

return function(scope: Fusion.Scope, props: {
    Type: string,
    AssetId: number
})

    local productInfo = Fusion.Value(scope, {})
    local hasOwnedGamepass = Fusion.Value(scope, false)
    table.insert(scope, task.spawn(function()
        local info
        pcall(function()
            info = MarketplaceService:GetProductInfoAsync(props.AssetId, Enum.InfoType[props.Type])
        end)
        info = info or {}

        productInfo:set(info)
    end))
    table.insert(scope, task.spawn(function()
        if props.Type ~= "Gamepass" then return end

        local hasOwned = false
        pcall(function()
            hasOwned = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, props.AssetId)
        end)

        hasOwnedGamepass:set(hasOwned)
    end))

    local isSelecting = Fusion.Value(scope, false)

    return Fusion.Hydrate(scope, Components:RefUI("Product_EDonate2_1", false, false, {
        "UICorner", "Featured"
    }))({
        Name = "Product_"..props.AssetId,

        LayoutOrder = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return if use(hasOwnedGamepass) then 99999 else use(productInfo).PriceInRobux or 0
        end),

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.025,
                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Icon_EDonate2_1", true))({
                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return HarukaLib:CombineRbxId(use(productInfo).IconImageAssetId)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Price_EDonate2_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local productInfoState = use(productInfo)
                    if productInfoState.PriceInRobux then
                        return `Donate {utf8.char(0xE002)} {productInfoState.PriceInRobux}`
                    end
                    return "???"
                end),
            }),

            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if props.Type == "Gamepass" then
                        MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, props.AssetId)

                        Bindables.DevProductPurchasing:Fire()

                    elseif props.Type == "Product" then
                        MarketplaceService:PromptProductPurchase(Players.LocalPlayer, props.AssetId, true, Enum.CurrencyType.Robux)

                        Bindables.DevProductPurchasing:Fire()
                    end
                end
            })
        }
    })
end