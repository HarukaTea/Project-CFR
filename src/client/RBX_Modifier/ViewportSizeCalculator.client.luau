
local GuiService = game:GetService("GuiService")


local viewportSize = workspace.CurrentCamera.ViewportSize - Vector2.new(0, GuiService.TopbarInset.Height)


workspace:SetAttribute("UIViewportSize", viewportSize)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    viewportSize = workspace.CurrentCamera.ViewportSize - Vector2.new(0, GuiService.TopbarInset.Height)

    workspace:SetAttribute("UIViewportSize", viewportSize)
end)
