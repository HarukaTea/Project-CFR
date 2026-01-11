
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Pinia = require(script.Pinia)

return function(plr: Player)
	if HarukaLib:GetDevice() == "VR" then
		return function () end
	end
	local isPC = HarukaLib:GetDevice() == "PC" or HarukaLib:GetDevice() == "Console"

	local self = {} :: Pinia.Self

	ClientLib:InitUIFramework(self, plr, "ShiftLock")

	Pinia(self)

	local scope = self.scope :: Fusion.Scope

	local lock: ImageLabel
	if isPC then
		lock = Fusion.Hydrate(scope, Components:RefUI("Lock_1"))({
			Visible = Fusion.Computed(scope, function(use: Fusion.Use)
				return use(self.LockEnabled)
			end)
		})
	end

	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ShiftLock",
		Parent = plr.PlayerGui,

	}, {
		CenterChildren = {
			lock,

			Fusion.Hydrate(scope, Components:RefUI("ShiftLock_1"))({
				Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
					return use(self.LastInputType) ~= "Keyboard"
				end),
				Image = Fusion.Computed(scope, function(use: Fusion.Use)
					return use(self.Icon)
				end),

				[Fusion.OnEvent("MouseButton1Click")] = function()
					if self.char and self.char:FindFirstChildOfClass("Humanoid") and self.char.PrimaryPart then
						self.ChangeShiftLockState:Fire(if Fusion.peek(self.LockEnabled) then "Off" else "On")
					end
				end,
			})
		}
	})
	self.UI = UI

	return function ()
		self.ChangeShiftLockState:Fire("Off")

        Fusion.doCleanup(scope)
    end
end