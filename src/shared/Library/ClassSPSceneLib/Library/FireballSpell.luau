
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
                if not ClientLib.IsCharValid(symbol.Value) then continue end

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