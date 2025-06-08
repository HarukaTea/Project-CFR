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

    ProjectileLib.FoxMove1 = function(projectile: Model, container: Folder)
        Promise.delay(0.5):andThen(function()
            for _, child: BasePart in projectile:GetChildren() do
                if child.Name == "Position" then
                    local sProjectile = projectile.Projectile.Value:Clone() :: Model
                    sProjectile:PivotTo(child.CFrame)

                    sProjectile:SetAttribute("HarukaUniqueId", projectile:GetAttribute("HarukaUniqueId"))

                    sProjectile.Parent = container

                    Maid:AddItem(sProjectile, 3)

                    ProjectileLib.FoxSpike1(sProjectile, container)
                end
            end
            projectile:FindFirstChildWhichIsA("Sound", true):Play()

        end):catch(function() end)
    end
    ProjectileLib.FoxMove2 = ProjectileLib.FoxMove1
    ProjectileLib.HardmodeWolfMove1 = ProjectileLib.FoxMove1
    ProjectileLib.HardmodeWolfMove2 = ProjectileLib.FoxMove1
    ProjectileLib.HardmodeWolfMove5 = ProjectileLib.FoxMove1
    ProjectileLib.LeafDragonMove2 = ProjectileLib.FoxMove1
    ProjectileLib.LeafDragonMove3 = ProjectileLib.FoxMove1
    ProjectileLib.BeeMove2 = ProjectileLib.FoxMove1




    ProjectileLib.FoxMove3 = function(projectile: Model, container: Folder)
        Promise.try(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = false,
            Size = "Big"
        }):catch(function() end)
    end
    ProjectileLib.HardmodeWolfMove3 = ProjectileLib.FoxMove3





    ProjectileLib.WolfMove4 = function(projectile: Model, container: Folder)
        Maid:AddItem(projectile, 5)

        projectile:FindFirstChildWhichIsA("Sound", true):Play()

        HarukaLib:CreateTween(projectile.Fang1.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()
        HarukaLib:CreateTween(projectile.Fang2.Part, AssetBook.TweenInfos.half, { Transparency = 0 }):Play()

        Promise.delay(0.5):andThen(function()
            HarukaLib:Tween(projectile.Fang1, AssetBook.TweenInfos.twiceHalf, { Pivot = projectile.Fang1.Base.CFrame * CFrame.new(0, 0, -6) })
            HarukaLib:Tween(projectile.Fang2, AssetBook.TweenInfos.twiceHalf, { Pivot = projectile.Fang2.Base.CFrame * CFrame.new(0, 0, -6) })

            projectile.Fang1:AddTag("DMGEntity")
            projectile.Fang2:AddTag("DMGEntity")

            projectile.Fang1:AddTag("PierceEntity")
            projectile.Fang2:AddTag("PierceEntity")
        end):catch(function() end)

        Promise.delay(4.5):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)
    end
    ProjectileLib.HardmodeWolfMove4 = ProjectileLib.WolfMove4




    ProjectileLib.FoxSpike1 = function(projectile: Model, container: Folder)
        projectile:AddTag("DMGEntity")
        projectile.Base.CFrame *= CFrame.new(0, 0, -80)

        HarukaLib:CreateTween(projectile.Part, AssetBook.TweenInfos.oneHalf, {
            Position = projectile.Base.Position
        }):Play()

        Promise.delay(1.5):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)
    end
    ProjectileLib.HardmodeWolfSpike1 = ProjectileLib.FoxSpike1




    ProjectileLib.FoxSpike2 = function(projectile: Model, container: Folder)
        projectile:AddTag("DMGEntity")
        projectile:PivotTo(projectile.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(math.random(360)), 0))

        Maid:AddItem(projectile, 10)

        projectile:FindFirstChildWhichIsA("Sound", true):Play()
        projectile:PivotTo(projectile.PrimaryPart.CFrame * CFrame.new(0, 30, 0))

        HarukaLib:Tween(projectile, AssetBook.TweenInfos.half, { Pivot = projectile.PrimaryPart.CFrame * CFrame.new(0, -30, 0) })


        Promise.delay(9.5):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)
    end
    ProjectileLib.HardmodeWolfSpike2 = ProjectileLib.FoxSpike2
end