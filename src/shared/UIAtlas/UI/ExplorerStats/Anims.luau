--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TS = game:GetService("TweenService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local CircleFX = require(script.Parent.Components.CircleFX)
local GotHitFX = require(script.Parent.Components.GotHitShade)
local GotHealFX = require(script.Parent.Components.GotHealShade)
local GotPoweredFX = require(script.Parent.Components.GotPoweredShade)
local ItemDropBar = require(script.Parent.Components.ItemDropBar)
local EXPBar = require(script.Parent.Components.LevelEXPBar)
local RegionBar = require(script.Parent.Components.AreaPopupBar)
local RevPKSlot = require(script.Parent.Components.GlobalClassPBars.ReverberationPK)

local wait = task.wait


return function (UI: ScreenGui, self: table)
    local scope = self.scope :: Fusion.Scope
    local bottom = UI.Bottom :: Frame


    --// cd anim
    table.insert(scope, Bindables.CDEndTimeReached:Connect(function(slotId: number)
        local slot = bottom:FindFirstChild(slotId, true) :: Frame?
        if not slot then return end

        local circle = CircleFX(scope)
        Debris:AddItem(circle, 2)

        circle.Parent = slot

        HarukaLib:CreateTween(circle, AssetBook.TweenInfos.onceHalf, { Size = UDim2.fromScale(2, 2) }):Play()
        HarukaLib:UITween(circle, "Out", { DelayTime = 0.2 })
    end))


    --// got hit anim
    local spawnClock = true
    task.delay(5, function()
        spawnClock = false
    end)
    table.insert(scope, Events.PlayGotHitScreenFX.On(function()
        if spawnClock then return end


        local gotHitFX = GotHitFX(scope)
        gotHitFX.Parent = self.UI

        Debris:AddItem(gotHitFX, 2)

        HarukaLib:UITween(gotHitFX, "Out", { TweenTime = 0.5 } )
    end))



    --// got heal fx
    table.insert(scope, Events.PlayHealScreenFX.On(function()
        if spawnClock then return end


        local gotHealFX = GotHealFX(scope)
        gotHealFX.Parent = self.UI

        Debris:AddItem(gotHealFX, 2)

        HarukaLib:UITween(gotHealFX, "Out", { TweenTime = 1.15 } )
    end))


    --// got powered fx
    table.insert(scope, Events.PlayStatPoweredScreenFX.On(function()
        if spawnClock then return end


        local gotPoweredFX = GotPoweredFX(scope)
        gotPoweredFX.Parent = self.UI

        Debris:AddItem(gotPoweredFX, 2)

        HarukaLib:UITween(gotPoweredFX, "Out", { TweenTime = 1.15 } )
    end))


    --// track new items
    local itemDropQueue = HarukaLib.Queue()
    table.insert(scope, itemDropQueue)


    local function _onNewItemDropFXAdded()
        if itemDropQueue:IsLocked() then return end
        if itemDropQueue:IsEmpty() then return end

        itemDropQueue:SetLockState(true)


        local data = itemDropQueue:Pop()

        local itemDropBar = ItemDropBar(scope, {
            ItemId = data.ItemId,
            Amount = data.Amount
        })
        itemDropBar.Parent = self.UI.Center.ItemDropsDiv.ItemDrops


        Debris:AddItem(itemDropBar, 3)


        HarukaLib:UITween(itemDropBar, "In")
        HarukaLib:UITween(itemDropBar, "Out", { TweenTime = 0.5, DelayTime = 3 - 0.5 })

        RunService.Heartbeat:Wait()
        itemDropQueue:SetLockState(false)

        _onNewItemDropFXAdded()
    end
    table.insert(scope, itemDropQueue.ElementAdded:Connect(_onNewItemDropFXAdded))
    table.insert(scope, Events.PlayItemDropFX.On(function(data)
        itemDropQueue:Push(data)
    end))


    --// track new exp awarded
    local expDropQueue = HarukaLib.Queue()
    table.insert(scope, expDropQueue)


    local function _onNewEXPAdded()
        if expDropQueue:IsLocked() then return end
        if expDropQueue:IsEmpty() then return end

        expDropQueue:SetLockState(true)


        local exp = expDropQueue:Pop()

        local expBar = EXPBar(scope, {
            AddedEXP = exp
        })
        expBar.Parent = self.UI.Top.LevelEXP


        Debris:AddItem(expBar, 2)


        HarukaLib:UITween(expBar, "In")
        HarukaLib:UITween(expBar, "Out", { TweenTime = 0.5, DelayTime = 1.5 })

        wait(2)
        expDropQueue:SetLockState(false)

        _onNewEXPAdded()
    end
    table.insert(scope, expDropQueue.ElementAdded:Connect(_onNewEXPAdded))
    table.insert(scope, Events.OpenEXPAwardBar.On(function(data)
        expDropQueue:Push(data.EXPGained)
    end))


    --// track region in
    local regionQueue = HarukaLib.Queue()
    table.insert(scope, regionQueue)


    local function _onNewRegionAdded()
        if regionQueue:IsLocked() then return end
        if regionQueue:IsEmpty() then return end

        if self == nil then return end
        if not self.UI then return end
        if not self.UI:FindFirstChild("Top") then return end

        local nextRegion = regionQueue:Pop() :: string

        regionQueue:SetLockState(true)

        local regionBar = RegionBar(scope, {
            AreaVal = self.AreaIn
        })
        regionBar.Parent = self.UI.Top

        self.AreaIn:set(nextRegion)

        Debris:AddItem(regionBar, 3.5)

        HarukaLib:UITween(regionBar, "In")
        HarukaLib:UITween(regionBar, "Out", { TweenTime = 0.5, DelayTime = 2.5 })

        wait(1.5)
        regionQueue:SetLockState(false)

        _onNewRegionAdded()
    end
    table.insert(scope, regionQueue.ElementAdded:Connect(_onNewRegionAdded))
    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-AreaIn"] = function(region: string)
            if region == nil or region == "" or region == "None" then return end

            regionQueue:Push(region)
        end
    }))


    --// track effect list
    ClientLib:TrackEffectListToUI({
        Target = self.char,
        Scope = scope,
        GuiContainer = bottom.CharacterStats.Div.Main
    })



    ---// track class: reverberation mechanic
    table.insert(scope, Events.CLASS_RollNewResonateNumForPlayer.On(function(data)
        if not self.UI then return end
        if not self.UI:FindFirstChild("Center") then return end
        if not self.UI.Center:FindFirstChild("GlobalClassAbilityDiv") then return end
        if not self.UI.Center.GlobalClassAbilityDiv:FindFirstChild("ReverberationStyle") then return end


        local ReverberationPKSlot = RevPKSlot(scope, {
            Num = data.ResonateNum
        })
        ReverberationPKSlot.Parent = self.UI.Center.GlobalClassAbilityDiv.ReverberationStyle
        Debris:AddItem(ReverberationPKSlot, 2)


        HarukaLib:UITween(ReverberationPKSlot, "In")
        HarukaLib:UITween(ReverberationPKSlot, "Out", { DelayTime = 1.5, TweenTime = 0.5 })

        SoundService.SFXs.DiceRoll:Play()
    end))


    --// enter fx
    table.insert(scope, HarukaLib:Hydrate(UI, {
        ["Prop-Enabled"] = function(newState: boolean)
            if newState then
                HarukaLib:UITween(UI, "In", {
                    TweenTime = 0.35
                })
            end
        end
    }))
end
