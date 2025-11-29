
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)


local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer
local humanoid = char.Humanoid :: Humanoid
local camera = workspace.CurrentCamera


repeat task.wait() until char:GetAttribute("Haruka_CriRPGClientInited")


ClientLib:InitCharDeadTrackers({
    Add = Add,
    Empty = Empty,
    Char = char,
    Player = plr
})



local waterParts = CollectionService:GetTagged("WaterPart")
Add(CollectionService:GetInstanceAddedSignal("WaterPart"):Connect(function(part)
    table.insert(waterParts, part)
end))

local waterEqualizers = CollectionService:GetTagged("WaterEqualizer")
Add(CollectionService:GetInstanceAddedSignal("WaterEqualizer"):Connect(function()
    waterEqualizers = CollectionService:GetTagged("WaterEqualizer")
end))



local animator = char.Humanoid.Animator :: Animator
local swimAnim = animator:LoadAnimation(ReplicatedStorage.Packages.Anims.CFMechanics.Swim)
local swimIdleAnim = animator:LoadAnimation(ReplicatedStorage.Packages.Anims.CFMechanics.SwimIdle)

Add(swimAnim)
Add(swimIdleAnim)

local ANIMS = {
    Swim = swimAnim,
    SwimIdle = swimIdleAnim
}



if camera:FindFirstChild("WaterBlur") then camera.WaterBlur:Destroy() end
if camera:FindFirstChild("WaterColor") then camera.WaterColor:Destroy() end


local waterBlur = Instance.new("BlurEffect")
waterBlur.Name = "WaterBlur"
waterBlur.Size = 25
waterBlur.Enabled = false
waterBlur.Parent = camera
Add(waterBlur)

local waterColor = Instance.new("ColorCorrectionEffect")
waterColor.Name = "WaterColor"
waterColor.TintColor = Color3.fromRGB(34, 81, 138)
waterColor.Parent = camera
Add(waterColor)


local animState = nil
local isSwimming = false
local swimVel: BodyVelocity? = nil

local watersIn: { BasePart } = {}
local swimUp = false

local function playSwimAnim(newAnim: string?)
    local oldAnim = animState

    if newAnim ~= oldAnim then
        if oldAnim then
            if ANIMS[oldAnim] then
                ANIMS[oldAnim]:Stop()
            end
        end
        if newAnim then
            if ANIMS[newAnim] then
                ANIMS[newAnim]:Play()
            end
        end

        animState = newAnim
    end
end
local function swimIn()
    if isSwimming then return end

    isSwimming = true
    char:SetAttribute("IsSwimming", true)

    char.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    char.Humanoid.HipHeight = -3

    local rootVel = char.PrimaryPart.AssemblyLinearVelocity

    if not swimVel then
        swimVel = Instance.new("BodyVelocity")
        swimVel.Name = "SwimVelocity"
        swimVel.P = 8000
        swimVel.Velocity = Vector3.new()
        swimVel.MaxForce = Vector3.new(rootVel.X, 8000, rootVel.Z)
        swimVel.Parent = char.PrimaryPart
    end

    playSwimAnim("SwimIdle")


    Events.SetServerCharAttr_C.Fire({
        AttrId = "IsSwimming",
        State = true
    })
end
local function swimOut()
    if not isSwimming then return end

    isSwimming = false
    swimUp = false

    char:SetAttribute("IsSwimming", false)

    if swimVel then
        swimVel:Destroy()
        swimVel = nil
    end

    local rootVel = char.PrimaryPart.AssemblyLinearVelocity

    char.Humanoid.HipHeight = 0
    char.PrimaryPart.AssemblyLinearVelocity = Vector3.new(
        rootVel.X, char.Humanoid.JumpPower * 1.2, rootVel.Z
    )

    playSwimAnim(nil)

    Events.SetServerCharAttr_C.Fire({
        AttrId = "IsSwimming",
        State = false
    })
end

Add(char.PrimaryPart.Touched:Connect(function(water: BasePart)
    if water:IsA("BasePart") and string.find(water.Name, "_Liquid") then
        swimIn()
        if not table.find(watersIn, water) then
            table.insert(watersIn, water)
        end
    end
end))
Add(char.PrimaryPart.TouchEnded:Connect(function(water: BasePart)
    if water:IsA("BasePart") and string.find(water.Name, "_Liquid") then
        if table.find(watersIn, water) then
            table.remove(watersIn, table.find(watersIn, water))
        end
        if #watersIn <= 0 then
            swimOut()
        end
    end
end))
Add(char.Humanoid.Changed:Connect(function()
    if humanoid.Jump and isSwimming then
        swimUp = true

    elseif not humanoid.Jump and isSwimming then
        swimUp = false

    elseif humanoid.Jump and not isSwimming then
        swimUp = false

    elseif not humanoid.Jump and not isSwimming then
        swimUp = false
    end
end))
Add(RS.Heartbeat:Connect(function()
    if not isSwimming then return end
    if not swimVel then return end

    local swimVelocity = if swimUp then humanoid.WalkSpeed else 0
    local direction = swimVel.Velocity

    if direction.Magnitude > 0.2 then
        playSwimAnim("Swim")
    else
        playSwimAnim("SwimIdle")
    end

    swimVel.Velocity = Vector3.new(
        humanoid.MoveDirection.X * humanoid.WalkSpeed,
        swimVelocity,
        humanoid.MoveDirection.Z * humanoid.WalkSpeed
    )
end))
Add(RS.Heartbeat:Connect(function()
    local isInWater = HarukaLib:IsInRegion(camera.CFrame.Position, waterParts)
    isInWater = (isInWater ~= nil)

    waterBlur.Enabled = isInWater
    waterColor.Enabled = isInWater

    for _, equalizer: EqualizerSoundEffect in waterEqualizers do
        equalizer.Enabled = isInWater
    end
end))