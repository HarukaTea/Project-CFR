--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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


RunService:UnbindFromRenderStep("WallClimbSystem")


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

local terrainRaycastParams = RaycastParams.new()
terrainRaycastParams.FilterType = Enum.RaycastFilterType.Include
terrainRaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPart")

Add(CollectionService:GetInstanceAddedSignal("WallClimbPart"):Connect(function()
    wallClimbRaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("WallClimbPart")
end))
Add(CollectionService:GetInstanceAddedSignal("TerrainPart"):Connect(function()
    terrainRaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPart")
end))


local climbingAnim = animator:LoadAnimation(RepS.Packages.Anims.CFMechanics.Climbing)
climbingAnim.Priority = Enum.AnimationPriority.Action3
Add(climbingAnim)


local MOVEMENT_KEYS = {
    [Enum.KeyCode.W] = true,
    [Enum.KeyCode.S] = true,
    [Enum.KeyCode.Space] = true
}
local function getKeyMovement(key: Enum.KeyCode): Vector3
    if key == Enum.KeyCode.W or key == "W" then
        return char.PrimaryPart.CFrame.UpVector
    elseif key == Enum.KeyCode.S or key == "S" then
        return -char.PrimaryPart.CFrame.UpVector
    end

    return nil
end
local function constructDirections() : { [string]: Vector3 }
    return {
        ["W"] = char.PrimaryPart.CFrame.LookVector,
        ["S"] = -char.PrimaryPart.CFrame.LookVector,
    }
end
local function getKeyFromMoveDirection()
    local dir = humanoid.MoveDirection
    for keyId: string, dirVector: Vector3 in constructDirections() do
        if math.round(dir:Dot(dirVector)) == 1 then
            return keyId
        end
    end

    return nil
end
local function climbFunction(key)
    if key == Enum.KeyCode.W or key == "W" then
        if WallClimb.IsClimbing then
            WallClimb:Cast(key)
        elseif not WallClimb.IsClimbing then
            WallClimb:Init()
        end
    elseif key == Enum.KeyCode.S or key == "S" then
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
    if not char:GetAttribute("CanClimb") then return end
    if WallClimb.IsClimbing then return end

    local rayResult = workspace:Raycast(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector, wallClimbRaycastParams) :: RaycastResult
    if not rayResult then return end

    local hit, pos = rayResult.Instance, rayResult.Position
    if not hit then return end

    local frontNormal: Vector3 = hit.CFrame.LookVector * 1
    if frontNormal:Dot(pos - hit.Position) <= 0 then return end


    WallClimb.IsClimbing = true

    char.PrimaryPart.Anchored = true
    char:SetAttribute("IsClimbing", true)

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    climbingAnim:Play()
    climbingAnim:AdjustSpeed(0.4)


    Events.RequestToEnterClimbingState.Fire({
        State = true
    })
end

function WallClimb:Cast(key: Enum.KeyCode | string)
    if not WallClimb.IsClimbing then return end

    local rayResult = workspace:Raycast(char.PrimaryPart.Position, char.PrimaryPart.CFrame.LookVector, wallClimbRaycastParams) :: RaycastResult
    local movement = getKeyMovement(key)

    if climbingAnim.Speed <= 0 then
        climbingAnim:AdjustSpeed(0.4)
    end
    if not rayResult then
        self:Stop()

        if key == Enum.KeyCode.W or key == "W" then
            if not char.PrimaryPart:FindFirstChild("WallClimbUpVel") then
                local upVel = Instance.new("BodyVelocity")
                upVel.Name = "WallClimbUpVel"
                upVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                upVel.Velocity = char.PrimaryPart.CFrame.UpVector * 60
                upVel.Parent = char.PrimaryPart

                Debris:AddItem(upVel, 0.01)
            end
        end
        return
    end
    if key == Enum.KeyCode.S or key == "S" then
        local verticalCast = workspace:Raycast(char.PrimaryPart.Position, -char.PrimaryPart.CFrame.UpVector * 4.5, terrainRaycastParams)
        if verticalCast then
            self:Stop()
            return
        end
    end

    char.PrimaryPart.CFrame = CFrame.lookAt(char.PrimaryPart.Position, rayResult.Position - rayResult.Normal) + movement * 0.159 * 2.3
end


function WallClimb:Stop()
    if not self.IsClimbing then return end

    self.IsClimbing = false

    char.PrimaryPart.Anchored = false
    char:SetAttribute("IsClimbing", false)

    humanoid:ChangeState(Enum.HumanoidStateType.Running)

    climbingAnim:Stop()


    Events.RequestToEnterClimbingState.Fire({
        State = false
    })
end


RunService:BindToRenderStep("WallClimbSystem", Enum.RenderPriority.Camera.Value, function()
    if IS_PC then
        local pressedKeys = UserInputService:GetKeysPressed()

        for _, key in pressedKeys do
            if not MOVEMENT_KEYS[key.KeyCode] then continue end

            climbFunction(key.KeyCode)
        end
        if #pressedKeys <= 0 and WallClimb.IsClimbing then
            climbingAnim:AdjustSpeed(0)
        end
    else
        local key = getKeyFromMoveDirection()
        climbFunction(key)
    end
end)
Add(function()
    RunService:UnbindFromRenderStep("WallClimbSystem")
end)