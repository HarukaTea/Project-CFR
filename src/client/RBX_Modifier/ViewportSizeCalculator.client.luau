
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local function _calculateViewportSize()
    local viewportSize = workspace.CurrentCamera.ViewportSize - Vector2.new(0, GuiService.TopbarInset.Height)

    workspace:SetAttribute("ViewportSize", workspace.CurrentCamera.ViewportSize)
    workspace:SetAttribute("UIViewportSize", viewportSize)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(_calculateViewportSize)
HarukaLib.Clock(5, _calculateViewportSize, true)
