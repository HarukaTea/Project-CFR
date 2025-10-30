
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")


local Bindables = require(RepS.HarukaShared.Library.Bindables)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer
local humanoid = char.Humanoid :: Humanoid


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


local canSlide = true

local function _cancelSlide()
    humanoid:MoveTo(char.PrimaryPart.Position)
    humanoid.HipHeight = 0

    canSlide = true

    Bindables.CancelRawAnimation:Fire("Slide")
end
local function _slide()
    while RS.Heartbeat:Wait() do
        if (humanoid:GetState() == Enum.HumanoidStateType.Running)
            or (humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics) then
            break
        end
    end

    humanoid.HipHeight = -1.5
    Bindables.PlayRawAnimation:Fire("Slide")



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