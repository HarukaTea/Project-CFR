--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)


local MKK_NUMBER = 1599 * 40 ^ 2


return function (self: { any })
    local scope = self.scope :: Fusion.Scope

    self.LockConn = nil :: RBXScriptConnection
    self.LockEnabled = Fusion.Value(scope, false)

	local ON_ICON, OFF_ICON = "rbxasset://textures/ui/mouseLock_on@2x.png", "rbxasset://textures/ui/mouseLock_off@2x.png"

    self.Icon = Fusion.Value(scope, OFF_ICON)
    self.OFFSET = CFrame.new(1.8, 0, 0)

    self.ChangeShiftLockState = Signal.new()
    table.insert(scope, self.ChangeShiftLockState)


    self.CameraOffsetTweenVal = Instance.new("CFrameValue")
    self.CameraOffsetTweenVal.Value = CFrame.identity
    table.insert(scope, self.CameraOffsetTweenVal)

    self.LastInputType = FusionComponents.useXboxControllerHotInput(scope)


    table.insert(scope, RS.RenderStepped:Connect(function()
        workspace.CurrentCamera.CFrame *= self.CameraOffsetTweenVal.Value
    end))


    local function _enableShiftLock()
        local char = self.char
        local humanoid = char.Humanoid :: Humanoid
        local hrp = char.PrimaryPart

        RS:BindToRenderStep("ShiftLockUpdate", Enum.RenderPriority.Camera.Value + 1, function()
            if not ClientLib.IsCharValid(char) then return end

            humanoid.AutoRotate = false

            if not humanoid.Sit then
                local lookVector = workspace.CurrentCamera.CFrame.LookVector

                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(
                    lookVector.X * MKK_NUMBER,
                    hrp.Position.Y,
                    lookVector.Z * MKK_NUMBER
                ))
            end
        end)
    end
    local function _disconnectEvents()
        RS:UnbindFromRenderStep("ShiftLockUpdate")
    end
    local function _setLockState(state: "On" | "Off")
        _disconnectEvents()

        if state == "On" then
            self.LockEnabled:set(true)
            self.Icon:set(ON_ICON)

            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = false

            HarukaLib:CreateTween(self.CameraOffsetTweenVal, AssetBook.TweenInfos.twiceHalf, {
                Value = self.OFFSET
            }):Play()

            _enableShiftLock()
        else
            self.LockEnabled:set(false)
            self.Icon:set(OFF_ICON)

            if self.char then
                if self.char:FindFirstChildOfClass("Humanoid") then
                    self.char.Humanoid.AutoRotate = true
                end
            end

            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true

            HarukaLib:CreateTween(self.CameraOffsetTweenVal, AssetBook.TweenInfos.twiceHalf, {
                Value = CFrame.identity
            }):Play()
        end
    end
    self.ChangeShiftLockState:Connect(_setLockState)


    --// track shift key
    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not input.UserInputType == Enum.UserInputType.Keyboard then return end

        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            _setLockState(if Fusion.peek(self.LockEnabled) then "Off" else "On")
        end
    end))
end
