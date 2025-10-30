
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local Types = require(script.Parent.Parent.Types)


local wait = task.wait


--// Main

return function(self: Types.ClassSPSceneLib, char: Model, projectileUniqueId: string)
    local ClassSPSceneLib = self
    if not ClientLib.IsCharValid(char) then return end

    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib.IsCharValid(targetingEnemy) then return end


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



    local tempMarkedContainer = ClassSPSceneLib._createMarkContainer()


    Promise.new(function(resolve)
        while true do
            RunService.Heartbeat:Wait()

            if not flowProjectile then break end
            if flowProjectile.Parent == nil then break end

            local pos = flowProjectile.Position

            for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                if not ClientLib.IsCharValid(symbol.Value) then continue end

                local obj = symbol.Value :: Instance
                local uniqueId = obj:GetAttribute("HarukaUniqueId") :: string
                if tempMarkedContainer:FindFirstChild(uniqueId) then continue end


                local entity = obj :: Model
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