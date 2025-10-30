
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local CircleFX = require(script.Parent.Components.CircleFX)
local RevPKSlot = require(script.Parent.Components.GlobalClassPBars.ReverberationPK)
local TicketPurchase = require(script.Parent.Components.TicketPurchase)

local wait = task.wait


local Pinia = require(script.Parent.Pinia)


return function (UI: ScreenGui, self: Pinia.Self)
    local scope = self.scope
    local bottom = UI.Bottom :: Frame


    --// cd anim
    table.insert(scope, Bindables.CDEndTimeReached:Connect(function(slotId: number)
        local slot = bottom:FindFirstChild(slotId, true) :: Frame?
        if not slot then return end


        local newScope = Fusion.scoped()

        local circle = CircleFX(newScope)
        circle.Parent = slot
        Debris:AddItem(circle, 2)


        Promise.delay(2):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)



        HarukaLib:CreateTween(circle, AssetBook.TweenInfos.onceHalf, { Size = UDim2.fromScale(2, 2) }):Play()
        HarukaLib:UITween(circle, "Out", { DelayTime = 0.2 })
    end))


    --// track effect list
    ClientLib.TrackEffectListToUI({
        Target = self.char,
        Scope = scope,
        GuiContainer = bottom.EffectList
    })



    ---// track class: reverberation mechanic
    table.insert(scope, Events.CLASS_RollNewResonateNumForPlayer.On(function(data)
        local UI = self.UI

        if not UI then return end
        if not UI:FindFirstChild("Center") then return end


        if not UI.Center:FindFirstChild("GlobalClassAbilityDiv") then return end
        if not UI.Center.GlobalClassAbilityDiv:FindFirstChild("ReverberationStyle") then return end



        local newScope = Fusion.scoped()

        local ReverberationPKSlot = RevPKSlot(newScope, {
            Num = data.ResonateNum
        })
        ReverberationPKSlot.Parent = UI.Center.GlobalClassAbilityDiv.ReverberationStyle
        Debris:AddItem(ReverberationPKSlot, 2)


        Promise.delay(2):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


        HarukaLib:UITween(ReverberationPKSlot, "In", {})
        HarukaLib:UITween(ReverberationPKSlot, "Out", { DelayTime = 1.5, TweenTime = 0.5 })

        SoundService.SFXs.DiceRoll:Play()
    end))


    --// track ticket purchases
    table.insert(scope, Events.OpenTicketPurchaseUI.On(function(data)
        local UI = self.UI

        if not UI then return end
        if not UI:FindFirstChild("Center") then return end

        if UI.Center:FindFirstChild("TicketPurchase") then return end


        local newScope = Fusion.scoped()

        local TicketPurchaseDreamField, blur = TicketPurchase(scope, {
            MerchantId = data.MerchantId
        })
        TicketPurchaseDreamField.Parent = UI.Center
        Debris:AddItem(TicketPurchaseDreamField, 30)
        Debris:AddItem(blur, 30)


        Promise.delay(31):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


        HarukaLib:UITween(TicketPurchaseDreamField, "In", {})
    end))
end