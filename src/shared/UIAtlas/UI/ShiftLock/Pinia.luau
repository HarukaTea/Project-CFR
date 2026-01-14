
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local FAIRLY_BIG_NUMBER = 1599 * 40 ^ 2

export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,
    UI: ScreenGui,

    LockConn: RBXScriptConnection?,
    LockEnabled: Fusion.Value<boolean>,

    Icon: Fusion.Value<string>,
    OFFSET: CFrame,

    ChangeShiftLockState: BindableEvent,

    CameraOffsetTweenVal: CFrameValue,

    LastInputType: Fusion.Value<string>,
    ShiftlockConn: RBXScriptConnection?,
}

return function (self: Self)
    local scope = self.scope :: Fusion.Scope

    self.LockConn = nil
    self.LockEnabled = Fusion.Value(scope, false)

	local ON_ICON, OFF_ICON = "rbxasset://textures/ui/mouseLock_on@2x.png", "rbxasset://textures/ui/mouseLock_off@2x.png"

    self.Icon = Fusion.Value(scope, OFF_ICON)
    self.OFFSET = CFrame.new(1.8, 0, 0)

    self.ChangeShiftLockState = Instance.new("BindableEvent")
    table.insert(scope, self.ChangeShiftLockState)

    self.CameraOffsetTweenVal = Instance.new("CFrameValue")
    self.CameraOffsetTweenVal.Value = CFrame.identity
    table.insert(scope, self.CameraOffsetTweenVal)

    self.LastInputType = FusionComponents.useXboxControllerHotInput(scope)

    self.ShiftlockConn = nil

    local cameraAdd, cameraEmpty = HarukaLib.Bin()
    table.insert(scope, cameraEmpty)

    Fusion.Observer(scope, self.LockEnabled):onBind(function()
        cameraEmpty()
        cameraAdd(RS.RenderStepped:Connect(function()
            workspace.CurrentCamera.CFrame *= self.CameraOffsetTweenVal.Value
        end))

        if Fusion.peek(self.LockEnabled) then return end

        table.insert(scope, task.delay(1, function()
            if Fusion.peek(self.LockEnabled) then return end

            cameraEmpty()
        end))
    end)

    local function _disconnectEvents()
        if self.ShiftlockConn then
            self.ShiftlockConn:Disconnect()
            self.ShiftlockConn = nil
        end
    end
    local function _enableShiftLock()
        local char = self.char
        local humanoid = char.Humanoid :: Humanoid
        local hrp = char.PrimaryPart

        if self.ShiftlockConn then
            _disconnectEvents()
        end
        self.ShiftlockConn = RunService.RenderStepped:Connect(function()
            if not char then return end
            if not char.PrimaryPart then return end
            if not humanoid then return end
            if not humanoid.Parent then return end
            if humanoid.Health <= 0 then return end
            if humanoid.Sit then return end

            humanoid.AutoRotate = false
            local lookVector = workspace.CurrentCamera.CFrame.LookVector

            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(
                lookVector.X * FAIRLY_BIG_NUMBER,
                hrp.Position.Y,
                lookVector.Z * FAIRLY_BIG_NUMBER
            ))
        end)
    end
    local function _setLockState(state: "On" | "Off")
        _disconnectEvents()

        if state == "On" then
            self.LockEnabled:set(true)
            self.Icon:set(ON_ICON)

            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = false

            HarukaLib:CreateTween(self.CameraOffsetTweenVal, Components.TweenInfos.twiceHalf, {
                Value = self.OFFSET
            }):Play()

            _enableShiftLock()
        else
            self.LockEnabled:set(false)
            self.Icon:set(OFF_ICON)

            if self.char and self.char:FindFirstChildOfClass("Humanoid") then
                self.char.Humanoid.AutoRotate = true
            end

            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true

            HarukaLib:CreateTween(self.CameraOffsetTweenVal, Components.TweenInfos.twiceHalf, {
                Value = CFrame.identity
            }):Play()
        end
    end
    self.ChangeShiftLockState.Event:Connect(_setLockState)

    --// track shift key
    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
            _setLockState(if Fusion.peek(self.LockEnabled) then "Off" else "On")
        end
    end))
end