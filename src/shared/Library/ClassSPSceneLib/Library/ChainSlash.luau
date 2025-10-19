--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Events = require(RepS.HarukaShared.Library.Events)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local Types = require(script.Parent.Parent.Types)


local wait = task.wait


--// Main

return function(self: Types.ClassSPSceneLib, char: Model, projectileUniqueId: string)
    local ClassSPSceneLib = self
    if not ClientLib.IsCharValid(char) then return end

    local char = char :: Model


    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib.IsCharValid(targetingEnemy) then return end


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


    local tempMarkedContainer = ClassSPSceneLib._createMarkContainer()


    Promise.new(function(resolve)
        while true do
            RunService.Heartbeat:Wait()

            if not vortex then break end
            if vortex.Parent == nil then break end

            local pos = vortex.Blade.Position

            for _, symbol: ObjectValue in char.TargetingList:GetChildren() do
                if not ClientLib.IsCharValid(symbol.Value) then continue end

                local obj = symbol.Value :: Instance
                local uniqueId = obj:GetAttribute("HarukaUniqueId") :: string
                if tempMarkedContainer:FindFirstChild(uniqueId) then continue end


                local entity = obj :: Model
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
            if not ClientLib.IsModelValid(vortex) then break end
            if not ClientLib.IsModelValid(char) then break end


            vortex.PrimaryPart.Position = char.PrimaryPart.Position
            vortex:PivotTo(vortex.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(-2.5), 0))
        end

        resolve()
    end):timeout(15):catch(function() end)
end