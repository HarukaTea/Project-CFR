
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Types = require(script.Parent.Parent.Types)

--// Main

return function(self: Types.VFXSceneLib, char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end

    local targetingEnemy = char.TargetingEnemy.Value
    if not ClientLib:IsCharValid(targetingEnemy) then return end

    local fireball = RepS.Packages.SkillProjectiles:FindFirstChild("Fireball", true):Clone() :: BasePart
    fireball.CFrame = char["Right Arm"].CFrame
    fireball.CFrame = HarukaLib:CFLookAt(fireball.Position, targetingEnemy.PrimaryPart.Position)
    fireball.Anchored = true
    fireball.Parent = workspace.Terrain
    Debris:AddItem(fireball, 1)

    HarukaLib:CreateTween(fireball, AssetBook.TweenInfos.one, {
        Position = targetingEnemy.PrimaryPart.Position
    }):Play()
end