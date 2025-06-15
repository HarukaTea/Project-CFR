--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children


return function(plr: Player)
	if HarukaLib:GetDevice() == "VR" then
		return function () end
	end
	local isPC = HarukaLib:GetDevice() == "PC" or HarukaLib:GetDevice() == "Console"


	local self = {}

	self.plr = plr
	self.char = plr.Character

	self.scope = Fusion.scoped()

	require(script.Pinia)(self)


	local scope = self.scope :: Fusion.Scope


	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ShiftLock",
		DisplayOrder = UIPriorityBook.Normal,
		ScreenInsets = Enum.ScreenInsets.None,
		Parent = plr.PlayerGui,

	}, {
		CenterProps = {
			[Children] = {
				Components.HoverImageButton(scope, {
					Name = "ShiftLock",
					Size = UDim2.fromScale(0.8, 0.8),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Position = UDim2.fromScale(0.99, 0),
					AnchorPoint = Vector2.xAxis,

					Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
						return use(self.LastInputType) ~= "Keyboard"
					end),
					Image = Fusion.Computed(scope, function(use: Fusion.Use)
						return use(self.Icon)
					end),

					[Fusion.OnEvent("MouseButton1Click")] = function()
						if self.char:FindFirstChild("Humanoid") and self.char.PrimaryPart then
							self.ChangeShiftLockState:Fire(if Fusion.peek(self.LockEnabled) then "Off" else "On")
						end
					end,
				}),

				Components.ImageLabel(scope, {
					Name = "Lock",
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Size = UDim2.fromOffset(32, 32),

					Image = "rbxasset://textures/MouseLockedCursor.png",

					Visible = Fusion.Computed(scope, function(use: Fusion.Use)
						return use(self.LockEnabled) and isPC
					end)
				})
			}
		}
	})


	return function ()
		self.ChangeShiftLockState:Fire("Off")
        Fusion.doCleanup(scope)
    end
end
