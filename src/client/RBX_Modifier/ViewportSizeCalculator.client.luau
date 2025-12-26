
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local viewportSize = workspace.CurrentCamera.ViewportSize - Vector2.new(0, GuiService.TopbarInset.Height)


workspace:SetAttribute("ViewportSize", workspace.CurrentCamera.ViewportSize)
workspace:SetAttribute("UIViewportSize", viewportSize)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    viewportSize = workspace.CurrentCamera.ViewportSize - Vector2.new(0, GuiService.TopbarInset.Height)

    workspace:SetAttribute("ViewportSize", workspace.CurrentCamera.ViewportSize)
    workspace:SetAttribute("UIViewportSize", viewportSize)
end)


HarukaLib.Clock(5, function()
    viewportSize = workspace.CurrentCamera.ViewportSize - Vector2.new(0, GuiService.TopbarInset.Height)

    workspace:SetAttribute("ViewportSize", workspace.CurrentCamera.ViewportSize)
    workspace:SetAttribute("UIViewportSize", viewportSize)
end, true)
