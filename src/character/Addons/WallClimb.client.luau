--!nocheck

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)


local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local humanoid = char.Humanoid :: Humanoid
local animator = humanoid.Animator :: Animator
local plr = Players.LocalPlayer


local IS_PC = HarukaLib:GetDevice() == "PC"

local WallClimb = {}


repeat task.wait() until char:GetAttribute("Haruka_CriRPGClientInited")


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


local wallClimbRaycastParams = RaycastParams.new()
wallClimbRaycastParams.FilterType = Enum.RaycastFilterType.Include
wallClimbRaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("WallClimbPart")

Add(CollectionService:GetInstanceAddedSignal("WallClimbPart"):Connect(function()
    wallClimbRaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("WallClimbPart")
end))


local climbingAnim = animator:LoadAnimation(RepS.Packages.Anims.CFMechanics.Climbing)
climbingAnim.Priority = Enum.AnimationPriority.Action3
Add(climbingAnim)


local MOVEMENT_KEYS = {
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.A] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Space] = true
}
local function getKeyMovement(key: Enum.KeyCode): Vector3
    if key == Enum.KeyCode.W or key == "W" then
        return char.PrimaryPart.CFrame.UpVector
    elseif key == Enum.KeyCode.A or key == "A" then
        return -char.PrimaryPart.CFrame.RightVector
    elseif key == Enum.KeyCode.S or key == "S" then
        return -char.PrimaryPart.CFrame.UpVector
    elseif key == Enum.KeyCode.D or key == "D" then
        return char.PrimaryPart.CFrame.RightVector
    end
end
local function constructDirections() : { [string]: Vector3 }
    return {
        ["W"] = char.PrimaryPart.CFrame.LookVector,
        ["A"] = -char.PrimaryPart.CFrame.RightVector,
        ["S"] = -char.PrimaryPart.CFrame.LookVector,
        ["D"] = char.PrimaryPart.CFrame.RightVector
    }
end
local function getKeyFromMoveDirection()
    local dir = humanoid.MoveDirection
    for keyId: string, dirVector: Vector3 in constructDirections() do
        if math.round(dir:Dot(dirVector)) == 1 then
            return keyId
        end
    end
end
local function climbFunction(key)
    if key == Enum.KeyCode.W or key == "W" then
        if WallClimb.IsClimbing then
            WallClimb:Cast(key)
        elseif not WallClimb.IsClimbing then
            WallClimb:Init()
        end
    elseif key == Enum.KeyCode.A or key == "A" then
        if WallClimb.IsClimbing then
            WallClimb:Cast(key)
        end
    elseif key == Enum.KeyCode.S or key == "S" then
        if WallClimb.IsClimbing then
            WallClimb:Cast(key)
        end
    elseif key == Enum.KeyCode.D or key == "D" then
        if WallClimb.IsClimbing then
            WallClimb:Cast(key)
        end
    elseif key == Enum.KeyCode.Space then
        if WallClimb.IsClimbing then
            WallClimb:Stop()
        end
    end
end

WallClimb.IsClimbing = false

function WallClimb:Init()
    if WallClimb.IsClimbing then return end

    local rayResult = workspace:Raycast(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector, wallClimbRaycastParams) :: RaycastResult
    if not rayResult then return end

    local hit, pos, normal = rayResult.Instance, rayResult.Position, rayResult.Normal
    if not hit then return end

    local frontNormal: Vector3 = hit.CFrame.LookVector * 1
    if frontNormal:Dot(pos - hit.Position) <= 0 then return end


    WallClimb.IsClimbing = true

    char.PrimaryPart.Anchored = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    Events.RequestToWallClimb.Fire({
        State = true
    })

    climbingAnim:Play()
    climbingAnim:AdjustSpeed(0.4)
end

function WallClimb:Cast(key: Enum.KeyCode | string)
    local rayResult = workspace:Raycast(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector, wallClimbRaycastParams) :: RaycastResult
    local movement = getKeyMovement(key)

    if not rayResult then
        if key == Enum.KeyCode.W or key == "W" then
            self:Stop()
            char.PrimaryPart:ApplyImpulse(char.PrimaryPart.CFrame.UpVector * 500)
        else
            self:Stop()
        end
        return
    end

    if key == Enum.KeyCode.S or key == "S" then
        local verticalCast = workspace:Raycast(char.PrimaryPart.Position, -char.PrimaryPart.CFrame.UpVector * (humanoid.HipHeight * 1.25), wallClimbRaycastParams)
        if verticalCast then self:Stop() return end
    end
    if (key == Enum.KeyCode.A or key == "A") or (key == Enum.KeyCode.D or key == "D") then
        local adjacentCast, perpendicularCast

        if key == Enum.KeyCode.A or key == "A" then
            adjacentCast = workspace:Raycast(char.PrimaryPart.Position + (char.PrimaryPart.CFrame.LookVector * 1.5) + -char.PrimaryPart.CFrame.RightVector, char.PrimaryPart.CFrame.RightVector, wallClimbRaycastParams)
            perpendicularCast = workspace:Raycast(char.PrimaryPart.Position, -char.PrimaryPart.CFrame.RightVector, wallClimbRaycastParams)

        elseif key == Enum.KeyCode.D or key == "D" then
            adjacentCast = workspace:Raycast(char.PrimaryPart.Position + (char.PrimaryPart.CFrame.LookVector * 1.5) + char.PrimaryPart.CFrame.RightVector, -char.PrimaryPart.CFrame.RightVector, wallClimbRaycastParams)
            perpendicularCast = workspace:Raycast(char.PrimaryPart.Position, char.PrimaryPart.CFrame.RightVector, wallClimbRaycastParams)
        end

        if adjacentCast and not perpendicularCast then
            self:Switch(adjacentCast.Position, adjacentCast.Normal)
        elseif perpendicularCast then
            self:Switch(perpendicularCast.Position, perpendicularCast.Normal)
        end
    end

    char.PrimaryPart.CFrame = CFrame.lookAt(char.PrimaryPart.Position, rayResult.Position - rayResult.Normal) + movement * 0.159
end


function WallClimb:Switch(pos: Vector3, normal: Vector3)
    char.PrimaryPart.CFrame = CFrame.lookAt(pos + (normal / 1.25), pos)
end


function WallClimb:Stop()
    if not self.IsClimbing then return end

    self.IsClimbing = false

    char.PrimaryPart.Anchored = false

    Events.RequestToWallClimb.Fire({
        State = false
    })
    humanoid:ChangeState(Enum.HumanoidStateType.Running)

    climbingAnim:Stop()
end


RunService:BindToRenderStep("WallClimbSystem", Enum.RenderPriority.Camera.Value, function()
    if IS_PC then
        for _, key in UserInputService:GetKeysPressed() do
            if not MOVEMENT_KEYS[key.KeyCode] then continue end
            climbFunction(key.KeyCode)
        end
    else
        local key = getKeyFromMoveDirection()
        climbFunction(key)
    end
end)
Add(function()
    RunService:UnbindFromRenderStep("WallClimbSystem")
end)
