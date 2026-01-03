
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local worldConfig = ReplicatedStorage:FindFirstChild("WorldConfig") :: Configuration
if not worldConfig then return end

local galleonConfig = worldConfig:GetAttribute("CanSkyGalleon") :: boolean
if not galleonConfig then return end


local ClientLib = require(ReplicatedStorage.HarukaShared.Library.ClientLib)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)
local currentGalleon: Model? = nil


repeat task.wait() until char:GetAttribute("Haruka_CriRPGServerInited")



ClientLib:InitCharDeadTrackers({
    Add = Add,
    Empty = Empty,
    Char = char,
    Player = plr
})


Add(HarukaLib:Hydrate(char.Humanoid, {
    ["Prop-SeatPart"] = function(part: BasePart)
        if part == nil then
            currentGalleon = nil
        else
            if part.Parent and part.Parent.Name == "SkyDriveGalleon" then
                currentGalleon = part.Parent
            end
        end
    end
}))



Add(Events.DriveSkyGalleon_C.On(function(player: Player, moveVector: Vector3)
    if player ~= plr then return end
    if not currentGalleon then return end
    if not moveVector then return end


    local x, y, z = moveVector.X, moveVector.Y, moveVector.Z
    x, y, z = math.clamp(x, -1, 1), math.clamp(y, -1, 1), math.clamp(z, -1, 1)
    moveVector = Vector3.new(x, y, z)


    local currentCFrame = currentGalleon.PrimaryPart.CFrame
    local rotationInput = -moveVector.X
    local targetVelocity = currentCFrame.LookVector * -moveVector.Z * 50
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
    if not ServerLib:IsModelValid(galleon) then return end
    if not galleon.PrimaryPart:FindFirstChild("AlignPosition") then return end

    if not galleon.PrimaryPart.Position:FuzzyEq(pos) then
        galleon.PrimaryPart.AlignPosition.Position = pos
    end

    local targetDirection = galleon.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(rotation), 0)
    local targetPoint = galleon.PrimaryPart.Position + targetDirection.LookVector.Unit * 159

    galleon.Humanoid:MoveTo(targetPoint)
end))
