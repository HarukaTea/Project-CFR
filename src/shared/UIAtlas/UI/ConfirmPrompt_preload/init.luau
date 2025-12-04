
local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Signal = require(RepS.HarukaShared.Shared.Signal)

local ConfirmPrompt = require(script.Components.ConfirmPrompt)


return function (plr: Player)
	local self = {}

	self.plr = plr
	self.scope = Fusion.scoped()


	local scope = self.scope :: Fusion.Scope

	--// receive confirm prompt requests
	local function _createConfirmPrompt(data: {
		Hint: string,
		ConfirmText: string,
		CancelText: string,

		ConfirmUniqueId: string
	})
		local confirmScope = Fusion.scoped()
		local resultSignal = Signal.new()
		table.insert(confirmScope, resultSignal)

		local UI = ConfirmPrompt(confirmScope, {
			Hint = data.Hint,
			ConfirmText = data.ConfirmText,
			CancelText = data.CancelText,

			ResultSignal = resultSignal,
		})
		UI.Parent = self.plr.PlayerGui


		HarukaLib:UITween(UI, "In", {
			TweenTime = 0.5,

			PosTweenStyle = "FromT2B",
			PosTweenBaseElement = UI.Center.ConfirmPrompt,
		})


		local finalResult = resultSignal:Wait()

		Bindables.ConfirmPromptChosen:Fire(data.ConfirmUniqueId, finalResult)

		HarukaLib:UITween(UI, "Out", {
			TweenCallback = function(tweenOutUI)
				Fusion.doCleanup(confirmScope)

				tweenOutUI.Full:Destroy()

				HarukaLib:UITween(tweenOutUI, "Out", {
					PosTweenStyle = "FromT2B",
					PosTweenBaseElement = tweenOutUI.Center.ConfirmPrompt,
				})
			end
		})
	end
	table.insert(scope, Bindables.CreateConfirmPrompt:Connect(_createConfirmPrompt))
end