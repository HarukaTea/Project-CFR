
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local HintLabel = require(script.Parent.Components.HintLabel)
local CenterHintLabel = require(script.Parent.Components.CenterHintLabel)
local FullHintLabel = require(script.Parent.Components.FullHintLabel)


local wait = task.wait



export type Self = {
	plr: Player,
	char: Model,
	scope: Fusion.Scope<any>,

	fsHintsQueue: HarukaLib.HarukaQueue,
	centerHintsQueue: HarukaLib.HarukaQueue,

	UI: ScreenGui
}




return function (self: Self)
	local scope = self.scope :: Fusion.Scope<any>


	self.fsHintsQueue = HarukaLib.Queue()
	self.centerHintsQueue = HarukaLib.Queue()
	table.insert(scope, self.fsHintsQueue)
	table.insert(scope, self.centerHintsQueue)



	--// receive hint requests
	local order = 1
	local function _createHint(text: string)
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


		HarukaLib:UITween(normalHint, "In", { TweenTime = 0.5 })
		HarukaLib:UITween(normalHint, "Out", { TweenTime = 0.5, DelayTime = 3 })
	end
	table.insert(scope, Events.CreateNotify.On(_createHint))
	table.insert(scope, Bindables.CreateNotify:Connect(_createHint))



	--// receive fs hint requests
	local function _createFSHint(text: string, duration: number)
		self.fsHintsQueue:Push({
			Text = text, Duration = duration
		})
	end
	local function _onFSHintAdded()
		if self.fsHintsQueue:IsLocked() then return end
		if self.fsHintsQueue:IsEmpty() then return end

		self.fsHintsQueue:SetLockState(true)

		local nextHint = self.fsHintsQueue:Pop() :: {
			Text: string, Duration: number
		}
		local newScope = Fusion.scoped()


		local fullNotify = FullHintLabel(newScope, {
			Text = nextHint.Text,
		})
		fullNotify.Parent = self.UI
		Debris:AddItem(fullNotify, nextHint.Duration + 1)


		Promise.delay(nextHint.Duration + 1):andThen(function()
			Fusion.doCleanup(newScope)
		end):catch(function() end)


		HarukaLib:UITween(fullNotify, "In", {})
		HarukaLib:UITween(fullNotify, "Out", { DelayTime = nextHint.Duration + 0.3 })


		wait(nextHint.Duration)
		self.fsHintsQueue:SetLockState(false)

		_onFSHintAdded()
	end
	table.insert(scope, Events.CreateFSNotify.On(_createFSHint))
	table.insert(scope, Bindables.CreateFSNotify:Connect(_createFSHint))
	table.insert(scope, self.fsHintsQueue.ElementAdded:Connect(_onFSHintAdded))


	--// receive center hint requests
	local function _createCenterNotify(text: string, showBar: boolean)
		self.centerHintsQueue:Push({
			Text = text, ShowBar = showBar
		})
	end
	local function _onCenterHintAdded()
		if self.centerHintsQueue:IsLocked() then return end
		if self.centerHintsQueue:IsEmpty() then return end

		self.centerHintsQueue:SetLockState(true)


		local nextHint = self.centerHintsQueue:Pop() :: {
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


		HarukaLib:UITween(notifyBar, "In", { TweenTime = 0.5 })
		HarukaLib:UITween(notifyBar, "Out", { TweenTime = 0.5, DelayTime = 0.9 })

		wait(1.5)
		self.centerHintsQueue:SetLockState(false)

		_onCenterHintAdded()
	end
	table.insert(scope, Events.CreateCenterNotify.On(_createCenterNotify))
	table.insert(scope, Bindables.CreateCenterNotify:Connect(_createCenterNotify))
	table.insert(scope, self.centerHintsQueue.ElementAdded:Connect(_onCenterHintAdded))



	--// system message display
	local function _displaySystemMessage(text: string)
		TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(HarukaLib:RichTextify(text))
	end
	table.insert(scope, Events.CreateSystemNotify.On(_displaySystemMessage))
	table.insert(scope, Bindables.CreateSystemNotify:Connect(_displaySystemMessage))
end