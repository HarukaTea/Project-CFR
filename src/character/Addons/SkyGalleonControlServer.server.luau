
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer
local currentGalleon: Model? = nil


repeat task.wait() until char:GetAttribute("Haruka_CriRPGServerInited")


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		Empty()
	end
end))
Add(script.Destroying:Connect(function()
    Empty()
end))
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



Add(Events.DriveSkyGalleon_C.On(function(plr: Player, moveVector: Vector3)
    if not currentGalleon then return end
    if not moveVector then return end


    local currentCFrame = currentGalleon.PrimaryPart.CFrame
    local rotationInput = -moveVector.X
    local targetVelocity = currentCFrame.LookVector * -moveVector.Z * 66
    local newPosition = currentCFrame.Position + targetVelocity

    if moveVector.Z > 0 then
        rotationInput = -rotationInput
    end
    if math.abs(rotationInput) <= 0.4 then
        rotationInput = 0
    end


    local galleon, pos, rotation =
        currentGalleon,
        Vector3.new(newPosition.X, 140, newPosition.Z),
        rotationInput * 15

    if not galleon:FindFirstChild("Owner") then return end
    if galleon.Owner.Value ~= plr then return end
    if not ServerLib.IsModelValid(galleon) then return end
    if not galleon.PrimaryPart:FindFirstChild("AlignPosition") then return end

    if not galleon.PrimaryPart.Position:FuzzyEq(pos) then
        galleon.PrimaryPart.AlignPosition.Position = pos
    end

    local targetDirection = galleon.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(rotation), 0)
    local targetPoint = galleon.PrimaryPart.Position + targetDirection.LookVector.Unit * 159

    galleon.Humanoid:MoveTo(targetPoint)
end))
