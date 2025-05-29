--!nocheck

repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local plrGui = Players.LocalPlayer.PlayerGui


local function _updateButton(gui: GuiObject)
    if gui:IsA("TextButton") or gui:IsA("ImageButton") then
        if gui.Name == "JumpButton" then return end

        gui.MouseButton1Click:Connect(function()
            local screenGui = gui:FindFirstAncestorOfClass("ScreenGui")
            if not screenGui then return end
            if not gui.Visible or not screenGui.Enabled then return end


            SoundService.SFXs.ButtonClick:Play()
        end)
    end
end


do
    for _, gui in plrGui:GetDescendants() do
        _updateButton(gui)
    end
    plrGui.DescendantAdded:Connect(_updateButton)
end
