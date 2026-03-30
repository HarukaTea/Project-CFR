
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local worldConfig = RepS:FindFirstChild("WorldConfig") :: Configuration
if not worldConfig then return end

local wallClimbConfig = worldConfig:GetAttribute("CanWallClimb") :: boolean
if not wallClimbConfig then return end

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local humanoid = char.Humanoid :: Humanoid
local animator = humanoid.Animator :: Animator
local plr = Players.LocalPlayer

local WallClimb = {}
WallClimb.IsClimbing = false
WallClimb.IsNearWall = false

repeat task.wait() until char:GetAttribute("Haruka_CriRPGClientInited")

ClientLib:TrackCharDiedEvent({
    Add = Add,
    Empty = Empty,
    Char = char,
    Player = plr
})

local wallClimbRaycastParams = RaycastParams.new()
wallClimbRaycastParams.FilterType = Enum.RaycastFilterType.Include
wallClimbRaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("WallClimbPart")

local terrainRaycastParams = RaycastParams.new()
terrainRaycastParams.FilterType = Enum.RaycastFilterType.Include
terrainRaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("TerrainPartEntity")

Add(CollectionService:GetInstanceAddedSignal("WallClimbPart"):Connect(function()
    wallClimbRaycastParams.FilterDescendantsInstances = CollectionService:GetTagged("WallClimbPart")
end))
Add(CollectionService:GetInstanceAddedSignal("TerrainPartEntity"):Connect(function(part)
    terrainRaycastParams:AddToFilter(part)
end))

local climbingAnim = animator:LoadAnimation(RepS.Packages.Anims.CFMechanics.Climbing)
climbingAnim.Priority = Enum.AnimationPriority.Action3
Add(climbingAnim)

local function getKeyMovement(key: Enum.KeyCode | string): Vector3?
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

function WallClimb:Init()
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

    Events.SetServerCharAttr_C.Fire({
        AttrId = "IsClimbing",
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

    local dt = RunService.Heartbeat:Wait()
    char.PrimaryPart.CFrame = CFrame.lookAt(char.PrimaryPart.Position, rayResult.Position - rayResult.Normal) + movement * 40 * dt
end

function WallClimb:Stop()
    if not self.IsClimbing then return end

    self.IsClimbing = false

    char.PrimaryPart.Anchored = false
    char:SetAttribute("IsClimbing", false)

    humanoid:ChangeState(Enum.HumanoidStateType.Running)

    climbingAnim:Stop()

    Events.SetServerCharAttr_C.Fire({
        AttrId = "IsClimbing",
        State = false
    })
end

Add(HarukaLib.Clock(1, function()
    WallClimb.IsNearWall = false

    for _, wall: BasePart in CollectionService:GetTagged("WallClimbPart") do
        local distance = plr:DistanceFromCharacter(wall.Position)
        if distance > 0 and distance <= 80 then
            WallClimb.IsNearWall = true
            break
        end
    end
end))
Add(RunService.Heartbeat:Connect(function()
    if not WallClimb.IsNearWall then return end

    local key = getKeyFromMoveDirection()
    climbFunction(key)
end))
