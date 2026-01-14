
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

repeat task.wait(1) until Players.LocalPlayer.PlayerGui:WaitForChild("TouchGui", 999)

local touchGui = Players.LocalPlayer.PlayerGui.TouchGui :: ScreenGui

touchGui.DisplayOrder = UIPriorityBook.MobileRBLXCoreGui
touchGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
