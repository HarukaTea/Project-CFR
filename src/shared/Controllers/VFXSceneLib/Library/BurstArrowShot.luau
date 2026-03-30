
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local BezierMath = require(RepS.HarukaShared.Shared.HarmonyLib.BezierMath)

local Types = require(script.Parent.Parent.Types)

--// Main

return function(self: Types.VFXSceneLib, char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end

    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end

    local angles = {
        CFrame.new(math.random(10, 20), 0, 0),
        CFrame.new(math.random(-20, -10), 0, 0),
        CFrame.new(0, math.random(5, 10), 0)
    }

    local endCF = targetingEnemy.PrimaryPart.CFrame

    local arrow = RepS.Packages.SkillProjectiles:FindFirstChild("BurstArrowSplitUlt", true):Clone() :: BasePart
    arrow.Anchored = false
    arrow.CFrame = char["Left Arm"].CFrame
    arrow.CFrame = CFrame.new(arrow.Position, endCF.Position)
    arrow.Parent = workspace.Terrain

    local start = arrow.CFrame
    local mid1 = (start:Lerp(endCF, 0.3) * angles[math.random(#angles)]).Position
    local mid2 = (start:Lerp(endCF, 0.6) * angles[math.random(#angles)]).Position

    task.spawn(function()
        local elapsed = 0

        while true do
            elapsed += RunService.RenderStepped:Wait() * 1.5

            local curvePos = BezierMath.CubicBezier(elapsed, start.Position, mid1, mid2, endCF.Position)

            if elapsed >= 1 then
                arrow:Destroy()
                break
            else
                arrow.Position = curvePos
            end
        end
    end)
end