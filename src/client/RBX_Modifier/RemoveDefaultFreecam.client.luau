--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Players = game:GetService("Players")

local plrGui = Players.LocalPlayer.PlayerGui

repeat task.wait() until plrGui:WaitForChild("Freecam", 999)

task.wait()
plrGui.Freecam:Destroy()