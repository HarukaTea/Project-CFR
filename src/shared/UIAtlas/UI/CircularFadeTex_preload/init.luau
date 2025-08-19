--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local CircularFadeTex = require(script.Components.CircularFadeTex)

local wait = task.wait

return function (plr: Player)
	local self = {}

	self.plr = plr
	self.scope = Fusion.scoped()

	local scope = self.scope :: Fusion.Scope


	self.cirularFadeQueue = HarukaLib.Queue()
	table.insert(scope, self.cirularFadeQueue)


	--// receive circular fade requests
	local function _createCircularFade(duration: number)
		self.cirularFadeQueue:Push({
            Duration = duration
        })
	end
	local function _onCircularFadeAdded()
		if self.cirularFadeQueue:IsLocked() then return end
		if self.cirularFadeQueue:IsEmpty() then return end

		self.cirularFadeQueue:SetLockState(true)

		local nextCircularFade = self.cirularFadeQueue:Pop() :: {
			Duration: number
		}
		local newScope = Fusion.scoped()

        local UI = CircularFadeTex(newScope)
		UI.Parent = self.plr.PlayerGui
		Debris:AddItem(UI, nextCircularFade.Duration + 2)


		Promise.delay(nextCircularFade.Duration + 2):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


		HarukaLib:CreateTween(UI.Circle, AssetBook.TweenInfos.half, {
			Size = UDim2.fromScale(0, 0)
		}):Play()

		wait(nextCircularFade.Duration)
		HarukaLib:CreateTween(UI.Circle, AssetBook.TweenInfos.half, {
			Size = UDim2.fromScale(3, 3)
		}):Play()


		wait(1)
		--// process next prompt
		self.cirularFadeQueue:SetLockState(false)

		_onCircularFadeAdded()
	end
    table.insert(scope, Events.CreateCircularFade.On(_createCircularFade))
	table.insert(scope, Bindables.CreateCircularFade:Connect(_createCircularFade))
	table.insert(scope, self.cirularFadeQueue.ElementAdded:Connect(_onCircularFadeAdded))
end
