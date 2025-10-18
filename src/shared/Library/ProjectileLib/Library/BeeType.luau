--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)



local Types = require(script.Parent.Parent.Types)



local wait = task.wait

return function (self: Types.ProjectileTable)
    local ProjectileLib = self


    ProjectileLib.BeeMove1 = function(projectile: Model, container: Folder)
        pcall(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = false,
            Size = "Small"
        })
        pcall(function()
            wait(0.5)
            ProjectileLib._spawnProjectile(projectile, container, 6, function(sProjectile: Model)
                sProjectile:PivotTo(projectile.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(math.random(360)), 0))
            end)
        end)
    end
    ProjectileLib.LeafDragonMove1 = ProjectileLib.BeeMove1



    ProjectileLib.BeeSpike1 = function(projectile: Model, container: Folder)
        if not projectile:GetAttribute("NoSound") then
            projectile:FindFirstChildWhichIsA("Sound", true):Play()
        end

        Promise.delay(5):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)

        HarukaLib:Tween(projectile, AssetBook.TweenInfos.half, {
            Pivot = projectile.PrimaryPart.CFrame * CFrame.new(0, 11, 0)
        }, true):Wait()

        projectile:AddTag("DMGEntity")
    end
    ProjectileLib.LeafDragonSpike1 = ProjectileLib.BeeSpike1
end