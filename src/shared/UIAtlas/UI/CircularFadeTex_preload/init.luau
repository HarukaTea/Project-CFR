
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local CircularFadeTex = require(script.Components.CircularFadeTex)

local wait = task.wait

return function (plr: Player)
	local self = {}

	ClientLib:InitUIFramework(self, plr, "CircularFadeTex", true)

	local scope = self.scope :: Fusion.Scope


	self.CirularFadeQueue = HarukaLib.Queue()
	table.insert(scope, self.CirularFadeQueue)


	--// receive circular fade requests
	local function _createCircularFade(duration: number)
		self.CirularFadeQueue:Push({
            Duration = duration
        })
	end
	local function _onCircularFadeAdded()
		if self.CirularFadeQueue:IsLocked() then return end
		if self.CirularFadeQueue:IsEmpty() then return end

		local nextCircularFade = self.CirularFadeQueue:Pop() :: {
			Duration: number
		}
		local newScope = Fusion.scoped()


		self.CirularFadeQueue:SpawnMutex(nextCircularFade.Duration + 1)

        local UI = CircularFadeTex(newScope)
		UI.Parent = self.plr.PlayerGui
		Debris:AddItem(UI, nextCircularFade.Duration + 2)


		Promise.delay(nextCircularFade.Duration + 2):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


		HarukaLib:CreateTween(UI.Circle, Components.TweenInfos.half, {
			Size = UDim2.fromScale(0, 0)
		}):Play()

		wait(nextCircularFade.Duration)
		HarukaLib:CreateTween(UI.Circle, Components.TweenInfos.half, {
			Size = UDim2.fromScale(3, 3)
		}):Play()
	end
    table.insert(scope, Events.CreateCircularFade_S.On(_createCircularFade))
	table.insert(scope, Bindables.CreateCircularFade.Event:Connect(_createCircularFade))

	self.CirularFadeQueue.RefreshSignal.Event:Connect(_onCircularFadeAdded)
end