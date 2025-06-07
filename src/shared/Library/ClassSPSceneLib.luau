--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Bezier = require(RepS.HarukaShared.Library.Bezier)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Events = require(RepS.HarukaShared.Library.Events)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local Trail = require(RepS.HarukaShared.Library.Trail)

local ClassSPSceneLib = {}

local wait = task.wait


--// Helper functions

local function _tweenValue(start: number, duration: number, endTime: number, obj: Instance)
	local numVal = Instance.new('NumberValue')
	numVal.Value = start


    HarukaLib:CreateTween(numVal, TweenInfo.new(duration), {Value = endTime}):Play()
	Debris:AddItem(numVal, duration)

	if obj then
		numVal.Changed:Connect(function(New)
			obj.Size = NumberSequence.new(New)
		end)
	end

	return numVal
end
local function _createMarkContainer() : Folder
    local tempMarkedContainer = Instance.new("Folder")
    tempMarkedContainer.Name = "TempMarkedContainer"
    tempMarkedContainer.Parent = game:GetService("ServerStorage")
    Debris:AddItem(tempMarkedContainer, 15)

    return tempMarkedContainer
end

--// Main

ClassSPSceneLib.ChainJump = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end


    local projectile = RepS.Packages.SkillProjectiles:FindFirstChild("ExtraJumpFade", true):Clone() :: Model
    projectile:PivotTo(char.PrimaryPart.CFrame * CFrame.new(0, -3, 0))

    projectile.Parent = workspace
    Debris:AddItem(projectile, 3)


    HarukaLib:CreateTween(projectile.Blast1, AssetBook.TweenInfos.twiceHalf, {
        Size = Vector3.new(16, 16, 16),
        Transparency = 1
    }):Play()

    HarukaLib:CreateTween(projectile.Blast2, AssetBook.TweenInfos.twiceHalf, {
        Size = Vector3.new(22, 26, 26),
        Transparency = 1
    }):Play()
end


ClassSPSceneLib.ChainSlash = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


    local charge = RepS.Packages.SkillProjectiles:FindFirstChild("ChainSlashCharge", true):Clone() :: BasePart
    charge.CFrame = char.PrimaryPart.CFrame
    charge.Parent = workspace
    Debris:AddItem(charge, 1)


    wait(0.55)
    local vortex = RepS.Packages.SkillProjectiles:FindFirstChild("ChainVortexSlash", true):Clone() :: Model
    vortex:PivotTo(char.PrimaryPart.CFrame * CFrame.new(0, 1.5, 0))
    vortex.Parent = workspace
    Debris:AddItem(vortex, 10)


    HarukaLib:CreateTween(vortex.Blade, TweenInfo.new(0.255, Enum.EasingStyle.Quad, Enum.EasingDirection.In, -1), {
        Orientation = vortex.Blade.Orientation + Vector3.new(0, -360, 0)
    }):Play()


    local tempMarkedContainer = _createMarkContainer()


    Promise.try(function()
        while true do
            RunService.Heartbeat:Wait()

            if not vortex then break end
            if vortex.Parent == nil then break end

            local pos = vortex.Blade.Position

            for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                if not ClientLib:IsCharValid(symbol.Value) then continue end
                if tempMarkedContainer:FindFirstChild(symbol.Value:GetAttribute("HarukaUniqueId")) then continue end


                local entity = symbol.Value :: Model
                local enemyPos = entity.PrimaryPart.Position
                local dist = (pos - enemyPos).Magnitude :: number

                if dist < 16 then
                    local bool = Instance.new("BoolValue")
                    bool.Name = entity:GetAttribute("HarukaUniqueId")
                    bool.Value = true
                    bool.Parent = tempMarkedContainer
                    Debris:AddItem(bool, 2)


                    Events.RequestToDMGEnemyBySkillProjectile.Fire({
                        ProjectileUniqueId = projectileUniqueId,
                        EnemyEntity = entity,
                    })
                end
            end
        end
    end):catch(function() end)

    Promise.try(function()
        while RunService.RenderStepped:Wait() do
            if not ClientLib:IsModelValid(vortex) then break end
            if not ClientLib:IsModelValid(char) then break end


            vortex.PrimaryPart.Position = char.PrimaryPart.Position
            vortex:PivotTo(vortex.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-2.5), 0))
        end
    end):catch(function() end)
end


ClassSPSceneLib.BurstArrowsSplit = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


    local angles = {
        CFrame.new(math.random(10, 20), 0, 0),
        CFrame.new(math.random(-20, -10), 0, 0),
        CFrame.new(0, math.random(5, 10), 0)
    }
    local function _impact()
        if not ClientLib:IsCharValid(targetingEnemy) then return end

        local impact = RepS.Packages.SkillProjectiles:FindFirstChild("BurstArrowUltImpact", true):Clone() :: BasePart
        impact.CFrame = targetingEnemy.PrimaryPart.CFrame
        impact.Parent = workspace
        Debris:AddItem(impact, 1)


        HarukaLib:CreateTween(impact:FindFirstChildWhichIsA("PointLight", true), AssetBook.TweenInfos.one, {
            Brightness = 0
        }):Play()
        HarukaLib:EmitParticles(impact)
    end


    for _ = 1, 3 do
        local endCF = targetingEnemy.PrimaryPart.CFrame

        local arrow = RepS.Packages.SkillProjectiles:FindFirstChild("BurstArrowSplitUlt", true):Clone() :: BasePart
        arrow.Anchored = false
        arrow.CFrame = char["Left Arm"].CFrame
        arrow.CFrame = CFrame.new(arrow.Position, endCF.Position)
        arrow.Parent = workspace

        local start = arrow.CFrame
        local mid1 = (start:Lerp(endCF, 0.3) * angles[math.random(#angles)]).Position
        local mid2 = (start:Lerp(endCF, 0.6) * angles[math.random(#angles)]).Position

        task.spawn(function()
            local elapsed = 0

            while true do
                elapsed += RunService.RenderStepped:Wait() * 1.5

                local curvePos = Bezier.CubicBezier(elapsed, start.Position, mid1, mid2, endCF.Position)

                if elapsed >= 1 then
                    arrow:Destroy()
                    _impact()
                    break
                else
                    arrow.Position = curvePos
                end
            end
        end)
        wait(0.07)
    end
end


ClassSPSceneLib.FireballSpell = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


    local fireball = RepS.Packages.SkillProjectiles:FindFirstChild("Fireball", true):Clone() :: BasePart
    fireball.CFrame = char["Right Arm"].CFrame
    fireball.CFrame = HarukaLib:CFLookAt(fireball.Position, targetingEnemy.PrimaryPart.Position)
    fireball.Anchored = true
    fireball.Parent = workspace
    Debris:AddItem(fireball, 1.5)


    HarukaLib:CreateTween(fireball, AssetBook.TweenInfos.one, {
        Position = targetingEnemy.PrimaryPart.Position
    }):Play()


    Promise.try(function()
        local found = false

        while true do
            RunService.Heartbeat:Wait()

            if found then break end
            if fireball == nil then break end
            if fireball.Parent == nil then break end

            local pos = fireball.Position

            for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                if not ClientLib:IsCharValid(symbol.Value) then continue end

                local entity = symbol.Value :: Model
                local enemyPos = entity.PrimaryPart.Position
                local dist = (pos - enemyPos).Magnitude :: number

                if dist < 11 then
                    Events.RequestToDMGEnemyBySkillProjectile.Fire({
                        ProjectileUniqueId = projectileUniqueId,
                        EnemyEntity = entity,
                    })

                    found = true
                    break
                end
            end
        end

        if fireball then fireball:Destroy() end

    end):catch(function() end)
end


ClassSPSceneLib.FlowAyakaUlt = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


    local flowCharge = RepS.Packages.SkillProjectiles:FindFirstChild("FlowCharge", true):Clone() :: BasePart
    flowCharge.CFrame = char.PrimaryPart.CFrame
    flowCharge.Parent = workspace
    Debris:AddItem(flowCharge, 1)

    HarukaLib:EmitParticles(flowCharge)


    local tempMarkedContainer = _createMarkContainer()


    for _, angle: number in { -8, 8 } do
        task.spawn(function()
            local part = HarukaLib:CreateMockPart()
            part.CFrame = char.PrimaryPart.CFrame * CFrame.new(angle / 3, 0, 0)
            part.Parent = workspace
            Debris:AddItem(part, 10)


            Promise.try(function()
                local isFound = false

                while true do
                    RunService.Heartbeat:Wait()

                    if isFound then break end
                    if part == nil then break end
                    if part.Parent == nil then break end

                    local pos = part.Position

                    for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                        if not ClientLib:IsCharValid(symbol.Value) then continue end
                        if tempMarkedContainer:FindFirstChild(symbol.Value:GetAttribute("HarukaUniqueId")) then continue end


                        local entity = symbol.Value :: Model
                        local enemyPos = entity.PrimaryPart.Position
                        local dist = (pos - enemyPos).Magnitude :: number

                        if dist < 26 then
                            local bool = Instance.new("BoolValue")
                            bool.Name = entity:GetAttribute("HarukaUniqueId")
                            bool.Value = true
                            bool.Parent = tempMarkedContainer


                            Events.RequestToDMGEnemyBySkillProjectile.Fire({
                                ProjectileUniqueId = projectileUniqueId,
                                EnemyEntity = entity,
                            })
                            isFound = true
                            break
                        end
                    end
                end

            end):catch(function() end)


            local startPos = part.CFrame
            local endPos = part.CFrame * CFrame.new(angle, 3.5, -32.5)
            local distance = (endPos.Position - startPos.Position).Magnitude :: number

            Promise.try(function()
                for i = 0, distance, 0.125 do
                    local progress = i / distance
                    endPos *= CFrame.new(0, 0, -0.225)

                    part.CFrame = part.CFrame:Lerp(endPos, progress)

                    if i >= 12 then break end
                    wait()
                end

                part:Destroy()
            end):catch(function() end)


            --- visual
            local flowIce = RepS.Packages.SkillProjectiles:FindFirstChild("FlowIce", true):Clone() :: BasePart
            flowIce.CFrame = part.CFrame
            flowIce.Parent = workspace
            Debris:AddItem(flowIce, 10)

            Promise.try(function()
                while part and part.Parent do
                    flowIce.Rot.Orientation = Vector3.zAxis * math.random(-360, 360)
                    flowIce.Rot.Shards:Emit(35)
                    wait(0.15)
                end
            end):catch(function() end)

            Promise.try(function()
                while true do
                    RunService.Heartbeat:Wait()

                    if flowIce == nil then break end
                    if flowIce.Parent == nil then break end

                    if part and part.Parent then
                        HarukaLib:CreateTween(flowIce, TweenInfo.new(0.005, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                            CFrame = part.CFrame
                        }):Play()
                    else
                        Debris:AddItem(flowIce, 2)

                        local val = _tweenValue(3, 0.135, 20)
                        HarukaLib:CreateTween(flowIce.Attachment.PointLight, AssetBook.TweenInfos.twiceHalf, {Range = 35}):Play()

                        flowIce.Attachment.Smoke.Enabled = false
                        flowIce.Attachment.Specs.Enabled = false
                        flowIce.Attachment.Main.Enabled = false
                        flowIce.Attachment.Wind.Enabled = false
                        flowIce.Attachment.Vortex.Enabled = false

                        flowIce.Hit.Spark:Emit(1)
                        flowIce.Hit.Gradient:Emit(1)
                        flowIce.Hit.Snowflake:Emit(7)
                        flowIce.Hit.Shards:Emit(20)
                        flowIce.Hit.Specs:Emit(25)
                        flowIce.Hit.Smoke:Emit(80)

                        val.Changed:Connect(function(newVal: number)
                            pcall(function()
                                flowIce.Attachment.Main.Size = NumberSequence.new({flowIce.Attachment.Main.Size.Keypoints[1], NumberSequenceKeypoint.new(1, newVal)})
                                flowIce.Attachment.Wind.Size = NumberSequence.new({flowIce.Attachment.Main.Size.Keypoints[1], NumberSequenceKeypoint.new(1, (newVal * 1.35))})
                            end)
                        end)

                        wait(0.35)
                        HarukaLib:CreateTween(flowIce.Attachment.PointLight, TweenInfo.new(0.8), {Range = 0}):Play()
                        break
                    end
                end

            end):catch(function() end)
        end)
    end
end


ClassSPSceneLib.BlueEchoUlt = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


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

            local post = ClientLib:FindGroundByRayForOrb(echoRay.Position)

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



return ClassSPSceneLib
