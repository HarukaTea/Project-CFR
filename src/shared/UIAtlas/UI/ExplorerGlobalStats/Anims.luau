--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local GotHitFX = require(script.Parent.Components.GotHitShade)
local GotHealFX = require(script.Parent.Components.GotHealShade)
local GotPoweredFX = require(script.Parent.Components.GotPoweredShade)
local ItemDropBar = require(script.Parent.Components.ItemDropBar)
local EXPBar = require(script.Parent.Components.LevelEXPBar)
local RegionBar = require(script.Parent.Components.AreaPopupBar)
local CastingTimeBar = require(script.Parent.Components.CastTimeBar)
local BadgeAwarding = require(script.Parent.Components.BadgeAwarding)


local wait = task.wait


return function (UI: ScreenGui, self: table)
    local scope = self.scope :: Fusion.Scope

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
    table.insert(scope, Events.PlayItemDropFX.On(function(data)
        local itemDropBar = ItemDropBar(scope, {
            ItemId = data.ItemId,
            Amount = data.Amount
        })
        itemDropBar.Parent = self.UI.Center.ItemDropsDiv.ItemDrops


        Debris:AddItem(itemDropBar, 3)


        HarukaLib:UITween(itemDropBar, "In")
        HarukaLib:UITween(itemDropBar, "Out", { TweenTime = 0.5, DelayTime = 3 - 0.5 })
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
            AreaVal = nextRegion
        })
        regionBar.Parent = self.UI.Top

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


    --// track cast cd
    table.insert(scope, Events.OpenCastTimeBar.On(function(data)
        local castingTimeBar = CastingTimeBar(scope, {
            Time = data.Duration
        })
        castingTimeBar.Parent = self.UI.Bottom.CastTimeBars

        Debris:AddItem(castingTimeBar, data.Duration + 0.2)


        wait(data.Duration)
        HarukaLib:UITween(castingTimeBar, "Out")
    end))


    --// track new achievements
    local achivementQueue = HarukaLib.Queue()
    table.insert(scope, achivementQueue)


    local function _onNewAchievementAdded()
        if achivementQueue:IsLocked() then return end
        if achivementQueue:IsEmpty() then return end

        achivementQueue:SetLockState(true)


        local data = achivementQueue:Pop()

        local expBar = BadgeAwarding(scope, {
            BadgeId = data.BadgeId,
        })
        expBar.Parent = UI.Bottom.BadgeAwarding


        SoundService.SFXs.QuestCompleted:Play()


        Debris:AddItem(expBar, 5)


        HarukaLib:UITween(expBar, "In", { TweenTime = 0.6 })
        HarukaLib:UITween(expBar, "Out", { TweenTime = 0.5, DelayTime = 3 })

        wait(4)
        achivementQueue:SetLockState(false)

        _onNewAchievementAdded()
    end
    table.insert(scope, achivementQueue.ElementAdded:Connect(_onNewAchievementAdded))
    table.insert(scope, Events.DisplayAchievementNotify.On(function(data)
        achivementQueue:Push(data)
    end))
end
