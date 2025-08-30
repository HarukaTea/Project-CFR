--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Events = require(ReplicatedStorage.HarukaShared.Library.Events)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer
local currentGalleon: Model = nil


repeat task.wait() until char:GetAttribute("Haruka_CriRPGClientInited")

--// TODO: we haven't enabled sky galleon driving feature yet
if true then return end


local wait = task.wait


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		Empty()
	end
end))
Add(script.Destroying:Connect(Empty))
Add(char.Humanoid.HealthChanged:Connect(function(health: number)
    if health <= 0 then
        Empty()
    end
end))
Add(char.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
    local newParent = char
    if newParent then
        if newParent.PrimaryPart == nil and not newParent:FindFirstChild("Humanoid") then
            Empty()
            return
        end
    else
        Empty()
    end
end))
Add(HarukaLib:Hydrate(char.Humanoid, {
    ["Prop-SeatPart"] = function(part: BasePart)
        if part == nil then
            currentGalleon = nil
        end
    end
}))


Add(Events.SetSkyGalleon.On(function(data)
    currentGalleon = data.Galleon
end))




local ControlsModule = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")) :: {
    GetControls: () -> {
        GetMoveVector: () -> Vector3
    }
}
ControlsModule = ControlsModule:GetControls()


Add(RunService.Heartbeat:Connect(function()
    if not currentGalleon then return end


    local moveVector = ControlsModule:GetMoveVector() :: Vector3

    local currentCFrame = currentGalleon.PrimaryPart.CFrame
    local forwardBackwardInput = -moveVector.Z
    local rotationInput = -moveVector.X
    local targetVelocity = currentCFrame.LookVector * forwardBackwardInput * 38
    local newPosition = currentCFrame.Position + targetVelocity

    if moveVector.Z > 0 then
        rotationInput = -rotationInput
    end
    if math.abs(rotationInput) <= 0.4 then
        rotationInput = 0
    end


    Events.RequestToSetSkyGalleonPos.Fire({
        Galleon = currentGalleon,
        Position = Vector3.new(newPosition.X, 25, newPosition.Z),
        Rotation = rotationInput * 15
    })
end))