
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local Types = require(script.Parent.Parent.Types)


--// Main

return function(self: Types.ClassSPSceneLib, char: Model, projectileUniqueId: string)
    if not ClientLib:IsCharValid(char) then return end

    local projectile = RepS.Packages.SkillProjectiles:FindFirstChild("ExtraJumpFade", true):Clone() :: Model
    projectile:PivotTo(char.PrimaryPart.CFrame * CFrame.new(0, -3, 0))

    projectile.Parent = workspace.Terrain
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