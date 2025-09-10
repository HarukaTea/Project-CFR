--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RepS = game:GetService("ReplicatedStorage")


local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

if UIS.TouchEnabled then
    local touchGui = Players.LocalPlayer.PlayerGui:WaitForChild("TouchGui", 999) :: ScreenGui

    touchGui.DisplayOrder = UIPriorityBook.MobileRBLXCoreGui
    touchGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    touchGui.IgnoreGuiInset = true

    local jumpButton = touchGui:WaitForChild("TouchControlFrame", 999):WaitForChild("JumpButton", 999) :: ImageButton

    task.wait()
    jumpButton.AnchorPoint = Vector2.new(0, 0.8)
end