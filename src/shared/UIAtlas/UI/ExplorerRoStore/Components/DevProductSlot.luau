
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

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
            info = MarketplaceService:GetProductInfo(props.AssetId, Enum.InfoType[props.Type])
        end)

        productInfo:set(info)
    end))
    table.insert(scope, task.spawn(function()
        if props.Type ~= "GamePass" then return end

        local hasOwned = false
        pcall(function()
            hasOwned = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, props.AssetId)
        end)

        hasOwnedGamepass:set(hasOwned)
    end))



    local isLimited
    if props.Type == "GamePass" then
        isLimited = {
            Components.TextLabel(scope, {
                Name = "Limited",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.5, 0.15),
                BackgroundTransparency = 0,
                BackgroundColor3 = Components.WHITE_COLOR,
                TextColor3 = Components.BLACK_COLOR,
                Text = "LIMITED",

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            }),
            Components.Frame(scope, {
                Name = "Shadow",
                BackgroundTransparency = 0.4,
                ZIndex = 2,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(hasOwnedGamepass)
                end),

                [Children] = {
                    Components.UICorner(scope, {
                        CornerRadius = UDim.new(0.1, 0)
                    }),
                }
            })

        }
    end

    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = "Product_"..props.AssetId,
        BackgroundColor3 = Components.BLACK_COLOR,
        BackgroundTransparency = 0,

        LayoutOrder = Fusion.Computed(scope, function(use: Fusion.Use, _)
            if use(hasOwnedGamepass) then
                return 99999
            else
                return use(productInfo).PriceInRobux or 0
            end
        end),

        [Children] = {
            Components.UIAspectRatioConstraint(scope, 1.271),
            Components.UICorner(scope, {
                CornerRadius = UDim.new(0.1, 0)
            }),

            Components.UIStroke(scope, {
                Thickness = 3,
                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Components.IconImageLabel(scope, {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.1),
                Size = UDim2.fromScale(0.5, 0.5),

                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return HarukaLib:CombineRbxId(use(productInfo).IconImageAssetId) or ""
                end)
            }),

            isLimited,

            Components.TextLabel(scope, {
                Name = "Price",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromScale(0.5, 1),
                Size = UDim2.fromScale(1, 0.2),
                BackgroundTransparency = 0,
                BackgroundColor3 = Components.WHITE_COLOR,
                TextColor3 = Components.BLACK_COLOR,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local productInfoState = use(productInfo)
                    if productInfoState.PriceInRobux then
                        return `Donate {utf8.char(0xE002)} {productInfoState.PriceInRobux}`
                    end

                    return "Fetching Info..."
                end),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if props.Type == "GamePass" then
                        MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, props.AssetId)
                    elseif props.Type == "Product" then
                        MarketplaceService:PromptProductPurchase(Players.LocalPlayer, props.AssetId, true, Enum.CurrencyType.Robux)
                    end
                end
            })
        }
    })
end