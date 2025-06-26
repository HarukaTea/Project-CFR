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
    tempMarkedContainer.Name = "TempMarkedContainer_"..HarukaLib:GenerateUUID()
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


    Promise.new(function(resolve)
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

        resolve()
    end):timeout(15):catch(function() end)

    Promise.new(function(resolve)
        while RunService.RenderStepped:Wait() do
            if not ClientLib:IsModelValid(vortex) then break end
            if not ClientLib:IsModelValid(char) then break end


            vortex.PrimaryPart.Position = char.PrimaryPart.Position
            vortex:PivotTo(vortex.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-2.5), 0))
        end

        resolve()
    end):timeout(15):catch(function() end)
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
    Debris:AddItem(fireball, 3)


    HarukaLib:CreateTween(fireball, AssetBook.TweenInfos.one, {
        Position = targetingEnemy.PrimaryPart.Position
    }):Play()


    Promise.new(function(resolve, reject)
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


                    local hitVFX = RepS.Packages.SkillProjectiles:FindFirstChild("FireballHitVFX", true):Clone() :: BasePart
                    hitVFX.CFrame = entity.PrimaryPart.CFrame
                    hitVFX.Anchored = true
                    hitVFX.Parent = workspace
                    Debris:AddItem(hitVFX, 5)

                    HarukaLib:EmitParticles(hitVFX)

                    found = true
                    break
                end
            end
        end

        if fireball then fireball:Destroy() end

        resolve()

    end):timeout(10):catch(function() end)
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


            Promise.new(function(resolve)
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

                resolve()

            end):timeout(5):catch(function() end)


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



ClassSPSceneLib.ArcaneMarkRune = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end

    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


    local mark = RepS.Packages.SkillProjectiles:FindFirstChild("ArcaneMarkRune", true):Clone() :: Model
    mark:PivotTo(targetingEnemy.PrimaryPart.CFrame * CFrame.new(0, 2.5, 0))
    mark.PrimaryPart.Anchored = true
    mark.Parent = workspace
    Debris:AddItem(mark, 5)

    HarukaLib:EmitParticles(mark)
end



ClassSPSceneLib.StarBeamStrike = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


    local beamStrike = RepS.Packages.SkillProjectiles:FindFirstChild("BeamStrike", true):Clone() :: Model
    beamStrike:PivotTo(char.PrimaryPart.CFrame)
    beamStrike.Parent = char
    Debris:AddItem(beamStrike, 6)


    Promise.new(function(resolve, reject)
        while beamStrike and beamStrike.Parent do
            beamStrike:PivotTo(HarukaLib:CFLookAt(char.PrimaryPart.Position, targetingEnemy.PrimaryPart.Position))
            RunService.Heartbeat:Wait()
        end

        resolve()
    end):timeout(7):catch(function() end)


    local tempMarkedContainer = _createMarkContainer()


    Promise.new(function()
        local isFound = false

        local part = beamStrike.Part :: BasePart

        while true do
            RunService.Heartbeat:Wait()

            if isFound then break end
            if beamStrike == nil then break end
            if beamStrike.Parent == nil then break end
            if part == nil then break end
            if part.Parent == nil then break end

            local pos = part.Position

            for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                if not ClientLib:IsCharValid(symbol.Value) then continue end
                if tempMarkedContainer:FindFirstChild(symbol.Value:GetAttribute("HarukaUniqueId")) then continue end


                local entity = symbol.Value :: Model
                local enemyPos = entity.PrimaryPart.Position
                local dist = (pos - enemyPos).Magnitude :: number

                if dist < 15 then
                    local bool = Instance.new("BoolValue")
                    bool.Name = entity:GetAttribute("HarukaUniqueId")
                    bool.Value = true
                    bool.Parent = tempMarkedContainer
                    Debris:AddItem(bool, 2)


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
end



ClassSPSceneLib.ChainSwordAstral = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end

    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


    local centerPos = char:GetAttribute("CombatLocation").Position :: Vector3
    local positions = {}

    local rMag = 12
    local mag = 35

    positions[1] = centerPos + Vector3.new(math.random(-rMag, rMag), 0, mag)
    positions[2] = centerPos + Vector3.new(math.random(-rMag, rMag), 0, -mag)
    positions[3] = centerPos + Vector3.new(mag, 0, math.random(-rMag, rMag))
    positions[4] = centerPos + Vector3.new(-mag, 0, math.random(-rMag, rMag))
    positions[5] = centerPos
    positions[6] = targetingEnemy.PrimaryPart.Position

    for _, pos in positions do
        Promise.try(function()
            local astral = RepS.Packages.SkillProjectiles:FindFirstChild("ChainTargetCircle", true):Clone() :: BasePart
            astral.CFrame = CFrame.new(ClientLib:FindGroundByRay(pos))
            astral.Parent = workspace
            Debris:AddItem(astral, 3)

            local sword = RepS.Packages.SkillProjectiles:FindFirstChild("DivineBlade", true):Clone() :: Model
            sword:PivotTo(astral.CFrame * CFrame.new(0, 70, 0) * CFrame.Angles(math.rad(-90), 0, 0))
            sword.Parent = workspace
            Debris:AddItem(sword, 3)


            HarukaLib:Tween(sword, AssetBook.TweenInfos.twiceHalf, {
                Pivot = astral.CFrame * CFrame.new(0, 5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            }, true):Wait()


            HarukaLib:EmitParticles(astral)


            for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                if not ClientLib:IsCharValid(symbol.Value) then continue end

                local entity = symbol.Value :: Model
                local enemyPos = entity.PrimaryPart.Position
                local dist = (astral.Position - enemyPos).Magnitude :: number

                if dist < 23 then
                    Events.RequestToDMGEnemyBySkillProjectile.Fire({
                        ProjectileUniqueId = projectileUniqueId,
                        EnemyEntity = entity,
                    })
                    break
                end
            end

        end):catch(function() end)
        wait(0.3)
    end
end


ClassSPSceneLib.FlowGanyuUlt = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end

    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


    local centerPos = char:GetAttribute("CombatLocation").Position :: Vector3


    local orb = RepS.Packages.SkillProjectiles:FindFirstChild("FlowGanyuOrb", true):Clone() :: Model
    orb:PivotTo(CFrame.new(centerPos) * CFrame.new(0, 30, 0))
    orb.Parent = workspace
    Debris:AddItem(orb, 10)

    local preSize = orb.PrimaryPart.Size
    orb.PrimaryPart.Size *= 1.4

    HarukaLib:CreateTween(orb.PrimaryPart, AssetBook.TweenInfos.half, {
        Transparency = 0,
        Size = preSize
    }):Play()


    local sequences = RepS.Packages.SkillProjectiles:FindFirstChild("FlowGanyuSequences", true) :: Folder
    Promise.try(function()
        for _, child: Instance in orb:GetDescendants() do
            if child:IsA("Beam") then
                child.Transparency = sequences[child.Name].Transparency
            end
        end
    end):catch(function() end)



    for _ = 1, 15 do
        for i = 1, math.random(1, 2) do
            local droplet = RepS.Packages.SkillProjectiles:FindFirstChild("FlowGanyuDroplet", true):Clone() :: BasePart
            droplet.Position = orb.PrimaryPart.Position + Vector3.new(
                math.random(-20, 20), 0, math.random(-20, 20)
            )
            droplet.Parent = workspace
            Debris:AddItem(droplet, 4)


            local floorPos = ClientLib:FindGroundByRay(droplet.Position)

            HarukaLib:CreateTween(droplet, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
                Position = floorPos
            }):Play()

            Promise.delay(0.4):andThen(function()
                HarukaLib:ZonitoToggleParticles(droplet, false, false, false)

                local impact = RepS.Packages.SkillProjectiles:FindFirstChild("FlowGanyuImpact", true):Clone() :: BasePart
                impact.CFrame = CFrame.new(floorPos) + Vector3.yAxis
                impact.Parent = workspace
                Debris:AddItem(impact, 3)

                HarukaLib:EmitParticles(impact)


                for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                    if not ClientLib:IsCharValid(symbol.Value) then continue end

                    local entity = symbol.Value :: Model
                    local enemyPos = entity.PrimaryPart.Position
                    local dist = (impact.Position - enemyPos).Magnitude :: number

                    if dist < 23 then
                        Events.RequestToDMGEnemyBySkillProjectile.Fire({
                            ProjectileUniqueId = projectileUniqueId,
                            EnemyEntity = entity,
                        })
                        break
                    end
                end

            end):catch(function()  end)
        end
        wait(0.25)
    end

    HarukaLib:CreateTween(orb.PrimaryPart, AssetBook.TweenInfos.one, {
        Transparency = 1
    }):Play()

    HarukaLib:ZonitoToggleParticles(orb, false, false, false)

    Promise.try(function()
        for _, child: Instance in orb:GetDescendants() do
            if child:IsA("Beam") then
                child.Transparency = NumberSequence.new(1, 1)
            end
        end
    end):catch(function() end)
end
ClassSPSceneLib.FlowLightningBlast = function(char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end

    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end


    local directionCF = HarukaLib:CFLookAt(char.PrimaryPart.Position, targetingEnemy.PrimaryPart.Position)



    local launch = RepS.Packages.SkillProjectiles:FindFirstChild("FlowLightningLaunch", true):Clone() :: BasePart
    launch.CFrame = directionCF * CFrame.new(0, -1, 0)
    launch.Parent = workspace
    Debris:AddItem(launch, 10)

    local windBlueMesh = RepS.Packages.SkillProjectiles:FindFirstChild("FlowLightningWindBlue", true):Clone() :: MeshPart
    windBlueMesh.CFrame = directionCF * CFrame.Angles(math.rad(-22), math.rad(-90), math.rad(-90))
    windBlueMesh.Parent = workspace
    Debris:AddItem(windBlueMesh, 10)


    local sineTween = TweenInfo.new(1, Enum.EasingStyle.Sine)
    HarukaLib:CreateTween(windBlueMesh, sineTween, {
        Orientation = windBlueMesh.Orientation + Vector3.xAxis * 45,
        Size = windBlueMesh.Size + Vector3.yAxis * 120,
        Transparency = 1,
        CFrame = windBlueMesh.CFrame * CFrame.new(0, -60, 0)
    }):Play()


    local flowLightningOrb = RepS.Packages.SkillProjectiles:FindFirstChild("FlowLightningOrb", true):Clone() :: MeshPart
    flowLightningOrb.CFrame = directionCF * CFrame.new(0, 0, -5)
    flowLightningOrb.Parent = workspace
    Debris:AddItem(flowLightningOrb, 10)

    local flowDebris = RepS.Packages.SkillProjectiles:FindFirstChild("FlowLightningDebris", true):Clone() :: BasePart
    flowDebris.CFrame = directionCF * CFrame.new(0, -1.5, -75) * CFrame.Angles(0, math.rad(90), 0)
    flowDebris.Parent = workspace
    Debris:AddItem(flowDebris, 10)


    HarukaLib:EmitParticles(flowDebris)
    HarukaLib:EmitParticles(launch)


    Promise.try(function()
        local sineTweenQuick = TweenInfo.new(0.15, Enum.EasingStyle.Sine)

        HarukaLib:CreateTween(flowLightningOrb, sineTweenQuick, {
            Size = flowLightningOrb.Size + Vector3.new(0, 15, 150),
            CFrame = flowLightningOrb.CFrame * CFrame.new(0, 0, -80)
        }):Play()

        wait(0.15)
        HarukaLib:CreateTween(flowLightningOrb, sineTweenQuick, {
            Size = Vector3.new(0, 0, flowLightningOrb.Size.Z)
        }):Play()

        wait(0.15)
        if flowLightningOrb then flowLightningOrb:Destroy() end

    end):catch(function() end)



    local flowLaunchStart = RepS.Packages.SkillProjectiles:FindFirstChild("FlowLaunchShockwave", true).Start:Clone() :: BasePart
    flowLaunchStart.CFrame = directionCF
    flowLaunchStart.Parent = workspace
    Debris:AddItem(flowLaunchStart, 10)

    local flowMark = RepS.Packages.SkillProjectiles:FindFirstChild("FlowMark", true):Clone() :: BasePart
    flowMark.CFrame = directionCF * CFrame.new(0, -2.65, 0) * CFrame.Angles(0, math.rad(90), 0)
    flowMark.Parent = workspace
    Debris:AddItem(flowMark, 10)


    local sineTweenDecent = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
    HarukaLib:CreateTween(flowMark, sineTweenDecent, {
        Size = flowMark.Size + Vector3.new(100, 0, 0),
        CFrame = flowMark.CFrame * CFrame.new(50, 0, 0)
    }):Play()

    Promise.delay(3):andThen(function()
        local sineTweenLong = TweenInfo.new(2, Enum.EasingStyle.Sine)
        HarukaLib:CreateTween(flowMark, sineTweenLong, {
            Size = Vector3.new(80, 0.1, 0)
        }):Play()

        for _, child: Instance in flowMark:GetDescendants() do
            if child:IsA("Decal") then
                HarukaLib:CreateTween(child, sineTweenLong, {
                    Transparency = 1
                }):Play()
            end
        end

    end):catch(function() end)


    HarukaLib:CreateTween(flowLaunchStart.Mesh, sineTween, {
        Scale = Vector3.new(0.040, 0.015, 0.040),
    }):Play()
    HarukaLib:CreateTween(flowLaunchStart.Decal, sineTween, {
        Transparency = 1
    }):Play()
    HarukaLib:CreateTween(flowLaunchStart, sineTween, {
        Orientation = Vector3.new(0, 90, 0),
        Position = flowLaunchStart.Position - Vector3.new(0, 5, 0),
        Size = Vector3.new(18, 7.5, 18)
    }):Play()


    local flowSideBeams = RepS.Packages.SkillProjectiles:FindFirstChild("FlowSideBeams", true):Clone() :: BasePart
    flowSideBeams.CFrame = directionCF * CFrame.new(0, 0, 25) * CFrame.Angles(0, math.rad(180), 0)
    flowSideBeams.Parent = workspace
    Debris:AddItem(flowSideBeams, 10)


    HarukaLib:CreateTween(flowSideBeams, sineTween, {
        CFrame = flowSideBeams.CFrame * CFrame.new(0, 0, 50)
    }):Play()


    local flowSideBeams2 = RepS.Packages.SkillProjectiles:FindFirstChild("FlowSideBeams2", true):Clone() :: BasePart
    flowSideBeams2.CFrame = directionCF * CFrame.new(0, 0, 25) * CFrame.Angles(0, math.rad(180), 0)
    flowSideBeams2.Parent = workspace
    Debris:AddItem(flowSideBeams2, 10)

    HarukaLib:CreateTween(flowSideBeams, sineTween, {
        CFrame = flowSideBeams.CFrame * CFrame.new(0, 0, 50)
    }):Play()
    HarukaLib:CreateTween(flowSideBeams2, sineTween, {
        CFrame = flowSideBeams2.CFrame * CFrame.new(0, 0, 100)
    }):Play()


    local flowProjectile = RepS.Packages.SkillProjectiles:FindFirstChild("FlowProjectile", true):Clone() :: BasePart
    flowProjectile.CFrame = directionCF * CFrame.Angles(0, 0, math.rad(114))
    flowProjectile.Parent = workspace
    Debris:AddItem(flowProjectile, 10)



    local tempMarkedContainer = _createMarkContainer()


    Promise.new(function(resolve)
        while true do
            RunService.Heartbeat:Wait()

            if not flowProjectile then break end
            if flowProjectile.Parent == nil then break end

            local pos = flowProjectile.Position

            for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                if not ClientLib:IsCharValid(symbol.Value) then continue end
                if tempMarkedContainer:FindFirstChild(symbol.Value:GetAttribute("HarukaUniqueId")) then continue end


                local entity = symbol.Value :: Model
                local enemyPos = entity.PrimaryPart.Position
                local dist = (pos - enemyPos).Magnitude :: number

                if dist < 22 then
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

        resolve()
    end):timeout(15):catch(function() end)



    local flowWhiteShockwave = RepS.Packages.SkillProjectiles:FindFirstChild("FlowWhiteShockwave", true):Clone() :: BasePart
    flowWhiteShockwave.CFrame = directionCF * CFrame.Angles(math.rad(-64), math.rad(90), math.rad(-180))
    flowWhiteShockwave.Parent = workspace
    Debris:AddItem(flowWhiteShockwave, 10)

    local flowTornado = RepS.Packages.SkillProjectiles:FindFirstChild("FlowTornado", true):Clone() :: BasePart
    flowTornado.CFrame = directionCF * CFrame.Angles(0, math.rad(90), math.rad(90))
    flowTornado.Parent = workspace
    Debris:AddItem(flowTornado, 10)

    local flowShockwave2 = RepS.Packages.SkillProjectiles:FindFirstChild("FlowShockwave2", true):Clone() :: BasePart
    flowShockwave2.CFrame = directionCF * CFrame.Angles(math.rad(-88), 0, 0)
    flowShockwave2.Parent = workspace
    Debris:AddItem(flowShockwave2, 10)


    HarukaLib:EmitParticles(flowShockwave2)


    HarukaLib:CreateTween(flowTornado, sineTween, {
        Orientation = flowTornado.Orientation + Vector3.new(180, 0, 0)
    }):Play()
    HarukaLib:CreateTween(flowTornado.Decal, sineTween, {
        Transparency = 1
    }):Play()


    Promise.new(function(resolve)
        local count = 1
        local textures = flowTornado.Textures:GetChildren()

        local textureIds = {}
        for _, texture: Texture in textures do
            table.insert(textureIds, texture.Texture)
        end

        while RunService.RenderStepped:Wait() do
            local texture = textureIds[count]
            if texture then
                flowTornado.Decal.Texture = texture
                count += 1

                if count > #textureIds then
                    flowTornado.Decal.Transparency = 1
                    break
                end
            end
        end

        resolve()

    end):timeout(5):catch(function() end)



    local flowBolt = RepS.Packages.SkillProjectiles:FindFirstChild("FlowBolt", true):Clone() :: BasePart
    flowBolt.CFrame = directionCF * CFrame.new(0, 0, -70)
    flowBolt.Parent = workspace
    Debris:AddItem(flowBolt, 10)


    HarukaLib:EmitParticles(flowBolt)


    HarukaLib:CreateTween(flowBolt.a2, AssetBook.TweenInfos.two, {
        Orientation = flowBolt.a2.Orientation + Vector3.new(1200, -1200, 1200)
    }):Play()


    HarukaLib:CreateTween(flowWhiteShockwave.Mesh, sineTween, {
        Scale = Vector3.new(1.5, 0.75, 0.75)
    }):Play()
    HarukaLib:CreateTween(flowWhiteShockwave.Decal, sineTween, {
        Transparency = 1
    }):Play()

    HarukaLib:CreateTween(flowProjectile, AssetBook.TweenInfos.twiceHalf, {
        CFrame = flowProjectile.CFrame * CFrame.new(0, 0, -80)
    }):Play()


    for _, child: Instance in HarukaLib.TableUtils.Merge(flowSideBeams:GetDescendants(), flowSideBeams2:GetDescendants()) do
        if child:IsA("Beam") then
            HarukaLib:CreateTween(child, sineTween, {
                Width1 = 0,
                Width0 = 0
            }):Play()
        end
    end
end


return ClassSPSceneLib
