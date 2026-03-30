
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local HintLabel = require(script.Parent.Components.HintLabel)
local CenterHintLabel = require(script.Parent.Components.CenterHintLabel)
local FullHintLabel = require(script.Parent.Components.FullHintLabel)

export type Self = {
	plr: Player,
	char: Model,
	scope: Fusion.Scope,

	FSHintsQueue: HarukaLib.HarukaQueue,
	CenterHintsQueue: HarukaLib.HarukaQueue,

	UI: ScreenGui
}

return function (self: Self)
	local scope = self.scope :: Fusion.Scope

	self.FSHintsQueue = HarukaLib.Queue()
	self.CenterHintsQueue = HarukaLib.Queue()
	table.insert(scope, self.FSHintsQueue)
	table.insert(scope, self.CenterHintsQueue)

	--// receive hint requests
	local order = 1
	local function _createHint(text: string)
		if not self then return end
		if not self.UI then return end
		if not self.UI:FindFirstChild("Top") then return end

		order += 1
		if order > 999 then order = 1 end

		local newScope = Fusion.scoped()

        local normalHint = HintLabel(newScope, {
			Text = text,
			LayoutOrder = order,
		})
		normalHint.Parent = self.UI.Top.Hints
		Debris:AddItem(normalHint, 3.2)

		Promise.delay(3.2):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)

		HarukaLib:UITransTween(normalHint, "In", { TweenTime = 0.5 })
		HarukaLib:UITransTween(normalHint, "Out", { TweenTime = 0.5, DelayTime = 3 })
	end
	table.insert(scope, Events.CreateNotify_S.On(_createHint))
	table.insert(scope, Bindables.CreateNotify.Event:Connect(_createHint))

	--// receive fs hint requests
	local function _createFSHint(text: string, duration: number)
		self.FSHintsQueue:Push({
			Text = text, Duration = duration
		})
	end
	local function _onFSHintAdded()
		if self.FSHintsQueue:IsLocked() then return end
		if self.FSHintsQueue:IsEmpty() then return end

		local nextHint = self.FSHintsQueue:Pop() :: {
			Text: string, Duration: number
		}
		local newScope = Fusion.scoped()

		self.FSHintsQueue:EnableMutex(nextHint.Duration)

		local fullNotify = FullHintLabel(newScope, {
			Text = nextHint.Text,
		})
		fullNotify.Parent = self.UI
		Debris:AddItem(fullNotify, nextHint.Duration + 1)

		Promise.delay(nextHint.Duration + 1):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)

		HarukaLib:UITransTween(fullNotify, "In", {})
		HarukaLib:UITransTween(fullNotify, "Out", { DelayTime = nextHint.Duration + 0.3 })
	end
	table.insert(scope, Events.CreateFSNotify_S.On(_createFSHint))
	table.insert(scope, Bindables.CreateFSNotify.Event:Connect(_createFSHint))

	self.FSHintsQueue.OnPushed.Event:Connect(_onFSHintAdded)

	--// receive center hint requests
	local function _createCenterNotify(text: string, showBar: boolean)
		self.CenterHintsQueue:Push({
			Text = text, ShowBar = showBar
		})
	end
	local function _onCenterHintAdded()
		if self.CenterHintsQueue:IsLocked() then return end
		if self.CenterHintsQueue:IsEmpty() then return end

		self.CenterHintsQueue:EnableMutex(1.5)

		local nextHint = self.CenterHintsQueue:Pop() :: {
			Text: string, ShowBar: boolean
		}
		local newScope = Fusion.scoped()

		local notifyBar = CenterHintLabel(newScope, {
			Text = nextHint.Text,
			ShowBar = nextHint.ShowBar,
		})
		notifyBar.Parent = self.UI
		Debris:AddItem(notifyBar, 2)

		Promise.delay(2):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)

		HarukaLib:UITransTween(notifyBar, "In", { TweenTime = 0.5 })
		HarukaLib:UITransTween(notifyBar, "Out", { TweenTime = 0.5, DelayTime = 0.9 })
	end
	table.insert(scope, Events.CreateCenterNotify_S.On(_createCenterNotify))
	table.insert(scope, Bindables.CreateCenterNotify.Event:Connect(_createCenterNotify))

	self.CenterHintsQueue.OnPushed.Event:Connect(_onCenterHintAdded)
end