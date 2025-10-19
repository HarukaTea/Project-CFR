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
local Events = require(RepS.HarukaShared.Library.Events)
local Promise = require(RepS.HarukaShared.Shared.Promise)



local Types = require(script.Parent.Parent.Types)


local wait = task.wait


--// Main

return function(self: Types.ClassSPSceneLib, char: Model, projectileUniqueId: string)
    local ClassSPSceneLib = self
    if not ClientLib.IsCharValid(char) then return end

    local targetingEnemy = (char :: any).TargetingEnemy.Value
    if not ClientLib.IsCharValid(targetingEnemy) then return end


    local combatLocation = char:GetAttribute("CombatLocation") :: CFrame
    local centerPos = combatLocation.Position :: Vector3
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
            astral.CFrame = CFrame.new(ClientLib.FindGroundByRay(pos))
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


            for _, symbol: ObjectValue in (char :: any).TargetingList:GetChildren() do
                if not ClientLib.IsCharValid(symbol.Value) then continue end

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