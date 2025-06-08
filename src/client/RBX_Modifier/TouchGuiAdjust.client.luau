--!nocheck

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RepS = game:GetService("ReplicatedStorage")


local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)


if UIS.TouchEnabled then
    local touchGui = Players.LocalPlayer.PlayerGui:WaitForChild("TouchGui", 999) :: ScreenGui

    touchGui.DisplayOrder = UIPriorityBook.MobileRBLXCoreGui
    touchGui.IgnoreGuiInset = true

    local jumpButton = touchGui:WaitForChild("TouchControlFrame", 999):WaitForChild("JumpButton", 999) :: ImageButton

    task.wait()
    jumpButton.AnchorPoint = Vector2.one
    jumpButton.Position = UDim2.fromScale(0.97, 0.7)
end