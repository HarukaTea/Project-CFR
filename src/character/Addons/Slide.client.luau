
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local worldConfig = ReplicatedStorage:FindFirstChild("WorldConfig") :: Configuration
local slideConfig = worldConfig:GetAttribute("CanSlide") :: boolean

if not slideConfig then return end



local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer
local humanoid = char.Humanoid :: Humanoid


repeat task.wait() until char:GetAttribute("Haruka_CriRPGClientInited")



ClientLib:InitCharDeadTrackers({
    Add = Add,
    Empty = Empty,
    Char = char,
    Player = plr
})


local animator = char.Humanoid.Animator :: Animator
local slideAnim = animator:LoadAnimation(ReplicatedStorage.Packages.Anims.CFMechanics.Slide)
slideAnim.Priority = Enum.AnimationPriority.Action3
slideAnim.Looped = false

Add(slideAnim)


local canSlide = true

local function _cancelSlide()
    humanoid:MoveTo(char.PrimaryPart.Position)
    humanoid.HipHeight = 0

    canSlide = true

    slideAnim:Stop()
end
local function _slide()
    while RS.Heartbeat:Wait() do
        if (humanoid:GetState() == Enum.HumanoidStateType.Running)
            or (humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics) then
            break
        end
    end

    humanoid.HipHeight = -1.5
    slideAnim:Play()


    local currentVel = char.PrimaryPart.AssemblyLinearVelocity
    char.PrimaryPart.AssemblyLinearVelocity = Vector3.new(
        currentVel.X,
        -35,
        currentVel.Z
    )

    local lastTick = tick()
    local move = if humanoid.MoveDirection.Magnitude > 0 then humanoid.MoveDirection * 20
        else char.PrimaryPart.CFrame.LookVector * 20

    local slideAdd, slideEmpty = HarukaLib.Bin()
    Add(slideEmpty)

    while canSlide == false do
        RS.RenderStepped:Wait()

        humanoid:MoveTo(char.PrimaryPart.Position + move)

        slideAdd(humanoid.Climbing:Once(function()
            canSlide = true
        end))

        if tick() - lastTick >= 0.5 then canSlide = true end
    end
    slideEmpty()

    canSlide = true
    _cancelSlide()
end


Add(Bindables.ActionSlide:Connect(function()
    if char:GetAttribute("IsSwimming") then return end

    canSlide = false
    _slide()
end))