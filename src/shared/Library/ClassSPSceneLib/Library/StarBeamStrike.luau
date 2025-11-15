
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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


    local tempMarkedContainer = ClassSPSceneLib._createMarkContainer()


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
                if not ClientLib.IsCharValid(symbol.Value) then continue end


                local obj = symbol.Value :: Instance
                local uniqueId = obj:GetAttribute("HarukaUniqueId") :: string
                if tempMarkedContainer:FindFirstChild(uniqueId) then continue end


                local entity = obj :: Model
                local enemyPos = entity.PrimaryPart.Position
                local dist = (pos - enemyPos).Magnitude :: number

                if dist < 15 then
                    local bool = Instance.new("BoolValue")
                    bool.Name = entity:GetAttribute("HarukaUniqueId")
                    bool.Value = true
                    bool.Parent = tempMarkedContainer
                    Debris:AddItem(bool, 2)


                    Events.DMGEnemyBySkills_C.Fire({
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