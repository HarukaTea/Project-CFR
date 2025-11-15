
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
    if not ClientLib.IsCharValid(char) then return end


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib.IsCharValid(targetingEnemy) then return end


    local centerPos = char:GetAttribute("CombatLocation").Position :: Vector3


    local orb = RepS.Packages.SkillProjectiles:FindFirstChild("FlowGanyuOrb", true):Clone() :: Model
    orb:PivotTo(CFrame.new(centerPos) * CFrame.new(0, 30, 0))
    orb.Parent = workspace.Terrain
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
            droplet.Parent = workspace.Terrain
            Debris:AddItem(droplet, 4)


            local floorPos = ClientLib.FindGroundByRay(droplet.Position)

            HarukaLib:CreateTween(droplet, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
                Position = floorPos
            }):Play()

            Promise.delay(0.4):andThen(function()
                HarukaLib:ZonitoToggleParticles(droplet, false, false, false)

                local impact = RepS.Packages.SkillProjectiles:FindFirstChild("FlowGanyuImpact", true):Clone() :: BasePart
                impact.CFrame = CFrame.new(floorPos) + Vector3.yAxis
                impact.Parent = workspace.Terrain
                Debris:AddItem(impact, 3)

                HarukaLib:EmitParticles(impact)


                for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                    if not ClientLib.IsCharValid(symbol.Value) then continue end

                    local entity = symbol.Value :: Model
                    local enemyPos = entity.PrimaryPart.Position
                    local dist = (impact.Position - enemyPos).Magnitude :: number

                    if dist < 23 then
                        Events.DMGEnemyBySkills_C.Fire({
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