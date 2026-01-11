
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RepS = game:GetService("ReplicatedStorage")

local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

if UIS.TouchEnabled then
    local touchGui = Players.LocalPlayer.PlayerGui:WaitForChild("TouchGui", 999) :: ScreenGui

    touchGui.DisplayOrder = UIPriorityBook.MobileRBLXCoreGui
    touchGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
end