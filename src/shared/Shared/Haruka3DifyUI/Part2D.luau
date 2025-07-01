--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Part2D = {}
Part2D.__index = Part2D


--// Constructor
function Part2D.new(element: GuiObject, ancestorModule: { any })
    local self = setmetatable({}, Part2D)

    self.IsEnabled = false
    self.Element = element
    self.RootGui = element:FindFirstAncestorOfClass("ScreenGui")
    self.Screen3DModule = ancestorModule
    self.OffsetCFrame = CFrame.identity


    self.VPSize = self:GetVPSize()

    if element.Parent and element.Parent:IsA("GuiObject") then
        self.ParentElement = element.Parent
    end

    self.Add, self.Empty = HarukaLib.Bin()

    return self
end

--[[
    Enable the Part2D, note that this can only be called once per Part2D instance.
]]
function Part2D:Enable()
    if self.IsEnabled then return end
    if not self.Element then return end

    self.IsEnabled = true
    self.Empty()

    local surfaceGui = Instance.new("SurfaceGui")
    local bindPart = Instance.new("Part")

    bindPart.CollisionGroup = "NoCollision"
    bindPart.EnableFluidForces = false
    bindPart.Locked = true
    bindPart.Material = Enum.Material.SmoothPlastic
    bindPart.Anchored = true
    bindPart.CanCollide = false
    bindPart.CanQuery = false
    bindPart.CanTouch = false
    bindPart.Transparency = 1
    bindPart.Massless = true
    bindPart.CastShadow = false
    bindPart.Parent = surfaceGui

    surfaceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    surfaceGui.Name = self.Element.Name.."_Part2D"
    surfaceGui.Face = Enum.NormalId.Back
    surfaceGui.AlwaysOnTop = true
    surfaceGui.LightInfluence = 0
    surfaceGui.MaxDistance = 999
    surfaceGui.Adornee = bindPart
    surfaceGui.Parent = self.ParentElement or self.RootGui

    surfaceGui.Enabled = false
    surfaceGui.Enabled = true --- deal with surfacegui caching behavior

    self.Add(surfaceGui)
    self.Add(bindPart)

    self.SurfaceGui = surfaceGui
    self.BindPart = bindPart

    self.Element.Parent = surfaceGui

    RS:BindToRenderStep("Haruka3DifyUI", Enum.RenderPriority.Last.Value + 2, function()
        self.VPSize = self:GetVPSize()
        surfaceGui.CanvasSize = self.VPSize

        bindPart.Size = self:GetXYZFromScreenSize(self.VPSize)
        bindPart.CFrame = self:GetWorldCFrame()
    end)
    self.Add(function()
        RS:UnbindFromRenderStep("Haruka3DifyUI")
    end)
end

--[[
    Stop the Part2D from rendering when you don't need it anymore.
]]
function Part2D:Disable()
    if not self.IsEnabled then return end

    self.IsEnabled = false
    pcall(function()
        if self.Element then self.Element.Parent = self.ParentElement or self.RootGui end
    end)

    self.Empty()
end


--[[
    Destroy and clear the Part2D.
]]
function Part2D:Destroy()
    self:Disable()
    self = nil
end


--[[
    Set the offset of the Part in the 3D space.
]]
function Part2D:SetOffsetY(offsetY: number)
    self.OffsetCFrame = CFrame.Angles(0, math.rad(offsetY), 0)
end


--// Private functions

function Part2D:GetVPSize() : Vector2
    if self.ParentPart2D and self.ParentPart2D.Element then
        return self.ParentPart2D.Element.AbsoluteSize
    end

    return workspace.CurrentCamera.ViewportSize
end

function Part2D:GetXYZFromScreenSize(size: Vector2) : Vector3
    local camera = workspace.CurrentCamera
    local cameraSize = camera.ViewportSize
    local FOV = math.clamp(camera.FieldOfView, 1, 115.9)

    return Vector3.new(
        (cameraSize.X / cameraSize.Y) * math.tan(math.rad(FOV) / 2) * (size.X / cameraSize.X),
        math.tan(math.rad(FOV) / 2) * (size.Y / cameraSize.Y),
        0
    ) * self.Screen3DModule.Distance
end

function Part2D:GetWorldCFrame() : CFrame
    if not self.Element then return CFrame.identity end

    self:RecomputeParentElement()

    local oriCFrame, udPos, addedPosition
    local udMax = self:Udim2ToCFrame(UDim2.fromScale(1, 1))

    if self.ParentPart2D then
        if not self.ParentPart2D.Element or not self.ParentElement then
            return CFrame.identity
        end

        local anchorPoint = self.ParentPart2D.Element.AnchorPoint

        oriCFrame = self.ParentPart2D:GetWorldCFrame()
        udPos = self.ParentPart2D.Element.Position

        local anchorFrame = self:Udim2ToCFrame(UDim2.fromScale(-anchorPoint.X + 0.5, -anchorPoint.Y + 0.5))
        if not self.ParentPart2D.IsEnabled and self.ParentPart2D.ParentPart2D and self.ParentPart2D.ParentPart2D.Element then
            local compatibilityPosition = UDim2.new(0, 0, 0, 0)

            if not self.IsEnabled and self.Element and self.ParentPart2D and self.ParentPart2D.Element then
                local offset = self.Element.AbsolutePosition - self.ParentPart2D.Element.AbsolutePosition

                compatibilityPosition = UDim2.fromOffset(offset.X, offset.Y)
            end
            udPos = compatibilityPosition
            anchorFrame = CFrame.identity
        end


        addedPosition = self.ParentPart2D:Udim2ToCFrame(udPos)
            * udMax
            * anchorFrame
            * CFrame.Angles(0, 0, -math.rad(self.ParentElement.Rotation))
    else
        local VPDiff = workspace.CurrentCamera.ViewportSize - workspace.CurrentCamera.ViewportSize

        oriCFrame = workspace.CurrentCamera.CFrame
            * CFrame.new(0, 0, -(self.Screen3DModule.Distance) / 2)
            * self.Screen3DModule.RootOffsetCFrame

        udPos = UDim2.fromOffset(VPDiff.X / 2, VPDiff.Y / 2)
        addedPosition = self:Udim2ToCFrame(udPos) * self:Udim2ToCFrame(UDim2.fromScale(1, 1))
    end

    local finalCFrame = oriCFrame * addedPosition
    local finalPivot = finalCFrame
        * udMax:Inverse()
        * self:Udim2ToCFrame(self.Element.Position)
        * udMax

    return finalCFrame * self:GetPartPivot(finalCFrame, finalPivot, self.OffsetCFrame)
end

--// Helper private functions

function Part2D:RecomputeParentElement()
    if self.ParentElement and self.ParentElement:IsA("GuiObject") then
        self.ParentPart2D = self.Screen3DModule:GetPart2D(self.ParentElement)
    end
    if self.SurfaceGui then
        local parentPart2D = self.ParentPart2D
        local zIndex = 0

        while parentPart2D do
            zIndex += 1
            parentPart2D = parentPart2D.ParentPart2D
        end

        self.SurfaceGui.ZOffset = zIndex
    end
end

function Part2D:Udim2ToCFrame(udim2: UDim2)
    if not self.Element then return CFrame.identity end

    local scaleX, scaleY = udim2.X.Scale, udim2.Y.Scale
    local offsetX, offsetY = udim2.X.Offset, udim2.Y.Offset

    local VPSize = self:GetVPSize()
    local partSize = self:GetXYZFromScreenSize(VPSize)

    local afterScaleX, afterScaleY = scaleX + offsetX / VPSize.X, scaleY + offsetY / VPSize.Y

    partSize = self:GetXYZFromScreenSize(VPSize)

    return CFrame.new(
        (partSize.X) * (afterScaleX - 0.5),
        -(partSize.Y) * (afterScaleY - 0.5),
        0
    )
end

function Part2D:GetPartPivot(oriCFrame: CFrame, pivotCFrame: CFrame, angleCFrame: CFrame) : CFrame
    return oriCFrame:Inverse() * pivotCFrame * angleCFrame * pivotCFrame:Inverse() * oriCFrame
end

return Part2D
