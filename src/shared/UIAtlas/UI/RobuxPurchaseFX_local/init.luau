
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local RobuxPurchaseFX = require(script.Components.RobuxPurchaseFX)


return function (plr: Player)
	local self = {}

	self.plr = plr
	self.scope = Fusion.scoped()

	--// receive requests
	local function _onPurchaseRequest()

        local newScope = Fusion.scoped()
        local ui = RobuxPurchaseFX(newScope)

        ui:AddTag("_RobuxPurchaseFXUI")
        ui.Parent = plr.PlayerGui

        Debris:AddItem(ui, 60)


        Promise.delay(62):andThen(function()
            Fusion.doCleanup(newScope)
        end):catch(function() end)
	end
    Bindables.DevProductPurchasing:Connect(_onPurchaseRequest)



    local function _onPurchaseFinished()
        for _, fx: ScreenGui in CollectionService:GetTagged("_RobuxPurchaseFXUI") do
            fx:Destroy()
        end
    end
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(_onPurchaseFinished)
    MarketplaceService.PromptProductPurchaseFinished:Connect(_onPurchaseFinished)
end