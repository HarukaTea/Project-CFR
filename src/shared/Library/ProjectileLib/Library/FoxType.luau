--!nocheck
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

    ProjectileLib.FoxMove1 = function(projectile: Model, container: Folder)
        wait(0.5)
        for _, child: BasePart in projectile:GetChildren() do
            if child.Name == "Position" then
                ProjectileLib._spawnProjectile(projectile, container, 3, function(sProjectile: Model)
                    sProjectile:PivotTo(child.CFrame)
                end)
            end
        end
        projectile:FindFirstChildWhichIsA("Sound", true):Play()
    end
    ProjectileLib.FoxMove2 = ProjectileLib.FoxMove1
    ProjectileLib.HardmodeWolfMove1 = ProjectileLib.FoxMove1
    ProjectileLib.HardmodeWolfMove2 = ProjectileLib.FoxMove1
    ProjectileLib.HardmodeWolfMove5 = ProjectileLib.FoxMove1
    ProjectileLib.BeeMove2 = ProjectileLib.FoxMove1




    ProjectileLib.FoxMove3 = function(projectile: Model, container: Folder)
        pcall(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = false,
            Size = "Big"
        })
    end
    ProjectileLib.HardmodeWolfMove3 = ProjectileLib.FoxMove3





    ProjectileLib.WolfMove4 = function(projectile: Model, container: Folder)
        projectile:FindFirstChildWhichIsA("Sound", true):Play()

        HarukaLib:CreateTween(projectile.Fang1.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()
        HarukaLib:CreateTween(projectile.Fang2.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()

        Promise.delay(0.5):andThen(function()
            HarukaLib:Tween(projectile.Fang1, AssetBook.TweenInfos.twiceHalf, { Pivot = projectile.Fang1.Base.CFrame * CFrame.new(0, 0, -6) })
            HarukaLib:Tween(projectile.Fang2, AssetBook.TweenInfos.twiceHalf, { Pivot = projectile.Fang2.Base.CFrame * CFrame.new(0, 0, -6) }, true):Wait()

            projectile.Fang1:AddTag("DMGEntity")
            projectile.Fang2:AddTag("DMGEntity")

            projectile.Fang1:AddTag("PierceEntity")
            projectile.Fang2:AddTag("PierceEntity")
        end):catch(function() end)

        Promise.delay(4.5):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)
    end
    ProjectileLib.HardmodeWolfMove4 = ProjectileLib.WolfMove4




    ProjectileLib.FoxSpike1 = function(projectile: Model, container: Folder)
        projectile.Base.CFrame *= CFrame.new(0, 0, -80)

        HarukaLib:CreateTween(projectile.Part, AssetBook.TweenInfos.oneHalf, {
            Position = projectile.Base.Position
        }):Play()

        projectile:AddTag("DMGEntity")

        Promise.delay(1.5):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)
    end
    ProjectileLib.HardmodeWolfSpike1 = ProjectileLib.FoxSpike1




    ProjectileLib.FoxSpike2 = function(projectile: Model, container: Folder)
        projectile:PivotTo(projectile.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))

        projectile:FindFirstChildWhichIsA("Sound", true):Play()
        projectile:PivotTo(projectile.PrimaryPart.CFrame * CFrame.new(0, 30, 0))

        HarukaLib:Tween(projectile, AssetBook.TweenInfos.half, { Pivot = projectile.PrimaryPart.CFrame * CFrame.new(0, -30, 0) }, true):Wait()

        projectile:AddTag("DMGEntity")

        Promise.delay(6):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)
    end
    ProjectileLib.HardmodeWolfSpike2 = ProjectileLib.FoxSpike2
end