
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RepS = game:GetService("ReplicatedStorage")


local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


if UIS.TouchEnabled then
    local touchGui = Players.LocalPlayer.PlayerGui:WaitForChild("TouchGui", 999) :: ScreenGui

    touchGui.DisplayOrder = UIPriorityBook.MobileRBLXCoreGui
    touchGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    touchGui.IgnoreGuiInset = true

    local jumpButton = touchGui:WaitForChild("TouchControlFrame", 999):WaitForChild("JumpButton", 999) :: ImageButton

    task.wait(1)
    HarukaLib.Clock(1, function()
        jumpButton.AnchorPoint = Vector2.new(1, 1)
        jumpButton.Position = UDim2.fromScale(0.975, 0.935)
    end, true)
end