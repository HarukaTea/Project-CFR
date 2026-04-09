
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local GotHitFX = require(script.Parent.Components.GotHitShade)
local GotHealFX = require(script.Parent.Components.GotHealShade)
local GotPoweredFX = require(script.Parent.Components.GotPoweredShade)
local ItemDropBar = require(script.Parent.Components.ItemDropBar)
local EXPBar = require(script.Parent.Components.LevelEXPBar)
local ClassEXPBar = require(script.Parent.Components.ClassLevelEXPBar)
local RegionBar = require(script.Parent.Components.AreaPopupBar)
local CastingTimeBar = require(script.Parent.Components.CastTimeBar)
local BadgeAwarding = require(script.Parent.Components.BadgeAwarding)


local Pinia = require(script.Parent.Pinia)


local wait = task.wait


return function (UI: ScreenGui, self: Pinia.Self)
    local scope = self.scope

    --// got hit anim
    local spawnClock = true
    task.delay(5, function()
        spawnClock = false
    end)
    table.insert(scope, Events.PlayGotHitScreenFX_S.On(function()
        if spawnClock then return end

        local newScope = Fusion.scoped()

        local gotHitFX = GotHitFX(newScope)
        gotHitFX.Parent = self.UI
        Debris:AddItem(gotHitFX, 2)

        Promise.delay(2):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


        HarukaLib:UITransTween(gotHitFX, "Out", { TweenTime = 0.5 } )
    end))



    --// got heal fx
    table.insert(scope, Events.PlayHealedScreenFX_S.On(function()
        if spawnClock then return end

        local newScope = Fusion.scoped()

        local gotHealFX = GotHealFX(newScope)
        gotHealFX.Parent = self.UI
        Debris:AddItem(gotHealFX, 2)


        Promise.delay(2):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


        HarukaLib:UITransTween(gotHealFX, "Out", { TweenTime = 1.15 } )
    end))


    --// got powered fx
    table.insert(scope, Events.PlayStatPoweredScreenFX_S.On(function()
        if spawnClock then return end


        local newScope = Fusion.scoped()

        local gotPoweredFX = GotPoweredFX(newScope)
        gotPoweredFX.Parent = self.UI
        Debris:AddItem(gotPoweredFX, 2)


        Promise.delay(2):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


        HarukaLib:UITransTween(gotPoweredFX, "Out", { TweenTime = 1.15 } )
    end))


    --// track new items
    table.insert(scope, Events.PlayItemDropFX_S.On(function(data)
        if not UI then return end
        if not UI:FindFirstChild("Bottom") then return end


        local newScope = Fusion.scoped()

        local itemDropBar = ItemDropBar(newScope, {
            ItemId = data.ItemId,
            Amount = data.Amount
        })
        itemDropBar.Parent = UI.Bottom.ItemDropsDiv.ItemAcquiredFrame
        Debris:AddItem(itemDropBar, 3.6)


        Promise.delay(3.6):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)
    end))


    --// track new exp awarded
    local expDropQueue = HarukaLib.Queue()
    table.insert(scope, expDropQueue)


    local function _onNewEXPAdded()
        if expDropQueue:IsLocked() then return end
        if expDropQueue:IsEmpty() then return end

        if not UI then return end
        if not UI:FindFirstChild("Top") then return end

        expDropQueue:EnableMutex(4)


        local data = expDropQueue:Pop()
        local newScope = Fusion.scoped()

        local expBar = EXPBar(newScope, {
            AddedEXP = data.EXPGained,
        })
        expBar.Parent = UI.Top.LevelEXP
        Debris:AddItem(expBar, 4)

        local classExpBar = ClassEXPBar(scope, {
            AddedClassEXP = data.ClassEXPGained
        })
        classExpBar.Parent = UI.Top.LevelEXP
        Debris:AddItem(classExpBar, 4)


        Promise.delay(4):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


        HarukaLib:UITransTween(expBar, "In", {})
        HarukaLib:UITransTween(expBar, "Out", { TweenTime = 0.5, DelayTime = 3.5 })

        HarukaLib:UITransTween(classExpBar, "In", {})
        HarukaLib:UITransTween(classExpBar, "Out", { TweenTime = 0.5, DelayTime = 3.5 })
    end
    table.insert(scope, Events.OpenEXPAwardBar_S.On(function(data)
        expDropQueue:Push({
            EXPGained = data.EXPGained,
            ClassEXPGained = data.ClassEXPGained
        })
    end))

    expDropQueue.OnPushed.Event:Connect(_onNewEXPAdded)


    --// track region in
    local regionQueue = HarukaLib.Queue()
    table.insert(scope, regionQueue)


    local function _onNewRegionAdded()
        if regionQueue:IsLocked() then return end
        if regionQueue:IsEmpty() then return end

        if self == nil then return end

        if not UI then return end
        if not UI:FindFirstChild("Top") then return end

        regionQueue:EnableMutex(1.5)

        local nextRegion = regionQueue:Pop() :: string
        local newScope = Fusion.scoped()

        local regionBar = RegionBar(newScope, {
            AreaVal = nextRegion
        })
        regionBar.Parent = UI.Top
        Debris:AddItem(regionBar, 3.5)


        Promise.delay(3.5):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


        HarukaLib:UITransTween(regionBar, "In", {})
        HarukaLib:UITransTween(regionBar, "Out", { TweenTime = 0.5, DelayTime = 2.5 })
    end
    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-AreaIn"] = function(region: string)
            if region == nil or region == "" or region == "None" then return end

            regionQueue:Push(region)
        end
    }))
    _onNewRegionAdded()

    regionQueue.OnPushed.Event:Connect(_onNewRegionAdded)


    --// track cast cd
    table.insert(scope, Events.OpenCastTimeBar_S.On(function(castTime: number)
        if not UI then return end
        if not UI:FindFirstChild("Bottom") then return end


        local newScope = Fusion.scoped()
        local castingTimeBar = CastingTimeBar(newScope, {
            Time = castTime
        })
        castingTimeBar.Parent = UI.Bottom.CastTimeBars
        Debris:AddItem(castingTimeBar, castTime + 0.2)


        Promise.delay(castTime + 1):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


        wait(castTime)
        HarukaLib:UITransTween(castingTimeBar, "Out", {})
    end))


    --// track new achievements
    local achivementQueue = HarukaLib.Queue()
    table.insert(scope, achivementQueue)


    local function _onNewAchievementAdded()
        if achivementQueue:IsLocked() then return end
        if achivementQueue:IsEmpty() then return end

        achivementQueue:EnableMutex(4)



        local badgeId = achivementQueue:Pop()
        local newScope = Fusion.scoped()

        local expBar = BadgeAwarding(newScope, {
            BadgeId = tonumber(badgeId),
        })
        expBar.Parent = UI.Bottom.BadgeAwarding
        Debris:AddItem(expBar, 5)


        Promise.delay(5):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


        SoundService.SFXs.QuestCompleted:Play()


        HarukaLib:UITransTween(expBar, "In", { TweenTime = 0.6 })
        HarukaLib:UITransTween(expBar, "Out", { TweenTime = 0.5, DelayTime = 3 })
    end
    table.insert(scope, Events.PlayBadgeNotify_S.On(function(badgeId: string)
        achivementQueue:Push(badgeId)
    end))

    achivementQueue.OnPushed.Event:Connect(_onNewAchievementAdded)
end