--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local wait = task.wait


--// Main

return function(self: table, char: Model, projectileUniqueId: string)
    local ClassSPSceneLib = self
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
