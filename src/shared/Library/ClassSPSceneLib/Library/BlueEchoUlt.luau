--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local Trail = require(RepS.HarukaShared.Library.TrailAlgoBook)


local Types = require(script.Parent.Parent.Types)


local wait = task.wait


--// Main

return function(self: Types.ClassSPSceneTable, char: Model, projectileUniqueId: string)
    local ClassSPSceneLib = self
    if not ClientLib.IsCharValid(char) then return end


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib.IsCharValid(targetingEnemy) then return end


    local centerPos = char:GetAttribute("CombatLocation").Position :: Vector3

    local normalInfo = TweenInfo.new(0.65)
	local beamInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
	local starInfo = TweenInfo.new(1.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)

    local echoRay = RepS.Packages.SkillProjectiles:FindFirstChild("EchoRay", true):Clone() :: BasePart
    echoRay.Position = centerPos
    echoRay.Parent = workspace
    Debris:AddItem(echoRay, 10)


    Trail:Init(echoRay, {
        Origin = echoRay.CFrame * CFrame.new(0, -40, 0),
        Projectile = RepS.Packages.SkillProjectiles:FindFirstChild("EchoTrail", true):Clone() :: BasePart,
        Index = 7,
        Interval = 0.01,
        Duration = 0.6,
        CurveOffset = 22.5
    })


    wait(0.6)
    HarukaLib:EmitParticles(echoRay.Init)
    HarukaLib:SetParticleState(echoRay, true)

    echoRay.Start.Beam.Enabled = true
    echoRay.End.PointLight.Enabled = true
    echoRay.Start.Star.Image.ImageTransparency = 0
    echoRay.Start.Circle.Image.ImageTransparency = 0

    HarukaLib:CreateTween(echoRay.Start.Beam, beamInfo, {
        Width0 = 0.55, Width1 = 0.55
    }):Play()

    HarukaLib:CreateTween(echoRay.Start.Star.Image, starInfo, {
        Rotation = echoRay.Start.Star.Image.Rotation + 360
    }):Play()


    Promise.new(function()
        while true do
            RunService.Heartbeat:Wait()

            local post = ClientLib.FindGroundByRayForOrb(echoRay.Position)

            HarukaLib:CreateTween(echoRay, normalInfo, {
                Position = targetingEnemy.PrimaryPart.Position + Vector3.yAxis * 30
            }):Play()

            echoRay.End.Position = Vector3.yAxis * ((-post.Y) + 1)
            echoRay.EndTrail0.Position = Vector3.new(0.3, echoRay.End.Position.Y, 0)
            echoRay.EndTrail1.Position = Vector3.new(-0.3, echoRay.End.Position.Y, 0)
        end

    end):timeout(5):catch(function() end)


    wait(5)
    echoRay.EndTrail0.Trail.Enabled = false

    HarukaLib:SetParticleState(echoRay, false)
    HarukaLib:CreateTween(echoRay.Start.Beam, AssetBook.TweenInfos.twiceHalf, {
        Width0 = 0, Width1 = 0
    }):Play()

    HarukaLib:CreateTween(echoRay.End.PointLight, AssetBook.TweenInfos.twiceHalf, {
        Brightness = 0
    }):Play()

    HarukaLib:CreateTween(echoRay.Start.Star.Image, AssetBook.TweenInfos.twiceHalf, {
        ImageTransparency = 1
    }):Play()

    HarukaLib:CreateTween(echoRay.Start.Circle.Image, AssetBook.TweenInfos.twiceHalf, {
        ImageTransparency = 1
    }):Play()

    Debris:AddItem(echoRay, 1.5)
end