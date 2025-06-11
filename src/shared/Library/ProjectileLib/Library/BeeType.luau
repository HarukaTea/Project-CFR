--!nocheck

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TS = TweenService
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local Maid = require(RepS.HarukaShared.Shared.Maid)

local wait = task.wait

return function (self)
    local ProjectileLib = self


    ProjectileLib.BeeMove1 = function(projectile: Model, container: Folder)
        pcall(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = false,
            Size = "Small"
        })
        pcall(function()
            wait(0.5)
            ProjectileLib._spawnProjectile(projectile, container, 6, function(sProjectile: Model)
                sProjectile:PivotTo(projectile.PrimaryPart.CFrame)
            end)
        end)
    end
    ProjectileLib.LeafDragonMove1 = ProjectileLib.BeeMove1



    ProjectileLib.BeeSpike1 = function(projectile: Model, container: Folder)
        projectile:AddTag("DMGEntity")

        if not projectile:GetAttribute("NoSound") then
            projectile:FindFirstChildWhichIsA("Sound", true):Play()
        end

        HarukaLib:Tween(projectile, AssetBook.TweenInfos.half, {
            Pivot = projectile.PrimaryPart.CFrame * CFrame.new(0, 11, 0)
        })

        Promise.delay(5):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)
    end
end