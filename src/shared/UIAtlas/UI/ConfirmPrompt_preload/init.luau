--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Signal = require(RepS.HarukaShared.Shared.Signal)

local ConfirmPrompt = require(script.Components.ConfirmPrompt)
local InfoPrompt = require(script.Components.InfoPrompt)


return function (plr: Player)
	local self = {}

	self.plr = plr
	self.scope = Fusion.scoped()


	local scope = self.scope :: Fusion.Scope


	self.ConfirmPromptsQueue = HarukaLib.Queue()
	table.insert(scope, self.ConfirmPromptsQueue)

	self.InfoPromptsQueue = HarukaLib.Queue()
	table.insert(scope, self.InfoPromptsQueue)


	--// receive confirm prompt requests
	local function _createConfirmPrompt(data: {
		Hint: string,
		ConfirmText: string,
		CancelText: string,

		ConfirmUniqueId: string
	})
		self.ConfirmPromptsQueue:Push(data)
	end
	local function _onConfirmPromptAdded()
		if self.ConfirmPromptsQueue:IsLocked() then return end
		if self.ConfirmPromptsQueue:IsEmpty() then return end

		self.ConfirmPromptsQueue:SetLockState(true)

		local nextPrompt = self.ConfirmPromptsQueue:Pop() :: {
			Hint: string,
			ConfirmText: string,
			CancelText: string,
			ConfirmUniqueId: string
		}


		local confirmScope = Fusion.scoped()
		local resultSignal = Signal.new()
		table.insert(confirmScope, resultSignal)

		local UI = ConfirmPrompt(confirmScope, {
			Hint = nextPrompt.Hint,
			ConfirmText = nextPrompt.ConfirmText,
			CancelText = nextPrompt.CancelText,

			ResultSignal = resultSignal,
		})
		UI.Parent = self.plr.PlayerGui


		HarukaLib:UITween(UI, "In", {
			TweenTime = 0.5,

			PosTweenStyle = "FromT2B",
			PosTweenBaseElement = UI.Center.ConfirmPrompt,
		})


		local finalResult = resultSignal:Wait()

		Bindables.ConfirmPromptChosen:Fire(nextPrompt.ConfirmUniqueId, finalResult)

		HarukaLib:UITween(UI, "Out", {
			TweenCallback = function(tweenOutUI: GuiObject)
				Fusion.doCleanup(confirmScope)

				tweenOutUI.Full:Destroy()

				HarukaLib:UITween(tweenOutUI, "Out", {
					PosTweenStyle = "FromT2B",
					PosTweenBaseElement = tweenOutUI.Center.ConfirmPrompt,
				})
			end
		})

		--// process next prompt
		self.ConfirmPromptsQueue:SetLockState(false)

		_onConfirmPromptAdded()
	end
	table.insert(scope, Bindables.CreateConfirmPrompt:Connect(_createConfirmPrompt))
	table.insert(scope, self.ConfirmPromptsQueue.ElementAdded:Connect(_onConfirmPromptAdded))


	--// receive info prompt requests
	local function _createInfoPrompt(data: {
		Hint: string,
		ConfirmText: string,

		ConfirmUniqueId: string
	})
		self.InfoPromptsQueue:Push(data)
	end
	local function _onInfoPromptAdded()
		if self.InfoPromptsQueue:IsLocked() then return end
		if self.InfoPromptsQueue:IsEmpty() then return end

		self.InfoPromptsQueue:SetLockState(true)

		local nextPrompt = self.InfoPromptsQueue:Pop() :: {
			Hint: string,
			ConfirmText: string,
			ConfirmUniqueId: string
		}


		local confirmScope = Fusion.scoped()
		local resultSignal = Signal.new()
		table.insert(confirmScope, resultSignal)

		local UI = InfoPrompt(confirmScope, {
			Hint = nextPrompt.Hint,
			ConfirmText = nextPrompt.ConfirmText,

			ResultSignal = resultSignal,
		})
		UI.Parent = self.plr.PlayerGui


		HarukaLib:UITween(UI, "In", {
			TweenTime = 0.5,

			PosTweenStyle = "FromT2B",
			PosTweenBaseElement = UI.Center.InfoPrompt,
		})


		local finalResult = resultSignal:Wait()

		Bindables.ConfirmPromptChosen:Fire(nextPrompt.ConfirmUniqueId, finalResult)

		HarukaLib:UITween(UI, "Out", {
			TweenCallback = function(tweenOutUI: GuiObject)
				Fusion.doCleanup(confirmScope)

				tweenOutUI.Full:Destroy()

				HarukaLib:UITween(tweenOutUI, "Out", {
					PosTweenStyle = "FromT2B",
					PosTweenBaseElement = tweenOutUI.Center.InfoPrompt,
				})
			end
		})

		--// process next prompt
		self.InfoPromptsQueue:SetLockState(false)

		_onConfirmPromptAdded()
	end
	table.insert(scope, Bindables.CreateInfoPrompt:Connect(_createInfoPrompt))
	table.insert(scope, self.InfoPromptsQueue.ElementAdded:Connect(_onInfoPromptAdded))
end
