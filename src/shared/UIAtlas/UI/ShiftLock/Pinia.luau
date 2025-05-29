--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Signal = require(RepS.HarukaShared.Shared.Signal)


local MKK_NUMBER = 1599 * 40 ^ 2


return function (self: table)
    local scope = self.scope :: Fusion.Scope

    self.LockConn = nil :: RBXScriptConnection
    self.LockEnabled = Fusion.Value(scope, false)

	local ON_ICON, OFF_ICON = "rbxasset://textures/ui/mouseLock_on@2x.png", "rbxasset://textures/ui/mouseLock_off@2x.png"

    self.Icon = Fusion.Value(scope, OFF_ICON)

    self.ChangeShiftLockState = Signal.new()
    table.insert(scope, self.ChangeShiftLockState)


    local function _enableShiftLock()
        RS:BindToRenderStep("ShiftLockUpdate", Enum.RenderPriority.Camera.Value, function()
            if not ClientLib:IsCharValid(self.char) then return end

            self.char.Humanoid.AutoRotate = false

            if not self.char.Humanoid.Sit then
                local lookVector = workspace.CurrentCamera.CFrame.LookVector

                self.char.PrimaryPart.CFrame = CFrame.new(self.char.PrimaryPart.Position, Vector3.new(
                    lookVector.X * MKK_NUMBER,
                    self.char.PrimaryPart.Position.Y,
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

            _enableShiftLock()
        else
            self.LockEnabled:set(false)
            self.Icon:set(OFF_ICON)

            if self.char then
                if self.char:FindFirstChildOfClass("Humanoid") then
                    self.char.Humanoid.AutoRotate = true
                end
            end
        end
    end
    self.ChangeShiftLockState:Connect(_setLockState)
end
