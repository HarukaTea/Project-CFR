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

    ProjectileLib.SlimeMove1_1 = function(projectile: Model, container: Folder)
        local entity = projectile.Owner.Value :: Model

        Promise.try(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = true,
            Size = "Small"
        }):catch(function() end)


        Promise.delay(0.4):andThen(function()
            local length = (entity.PrimaryPart.Position - projectile.Base.Position).Magnitude
            local height = 8
            projectile.Shot:PivotTo(CFrame.new(entity.PrimaryPart.Position, projectile.Base.Position) * CFrame.new(0, 0, -length/2) * CFrame.new(0, -height, 0))

            local radius = (entity.PrimaryPart.Position - projectile.Shot.Base.Position).Magnitude
            for _, part: BasePart in projectile.Shot:GetChildren() do
                if part.Name == "Part" then
                    part.CFrame *= CFrame.new(0, radius, 0)
                end
            end

            local angle = math.sinh((length / 2) / radius)
            projectile.Shot:PivotTo(projectile.Shot.Base.CFrame * CFrame.Angles(angle, 0, 0))

            local rotatingangle = angle * 2
            HarukaLib:Tween(projectile.Shot, AssetBook.TweenInfos.half, { Pivot = projectile.Shot.Base.CFrame * CFrame.Angles(-rotatingangle, 0, 0) }):Wait()

            projectile.Shot:Destroy()
        end):catch(function()  end)


        Promise.delay(0.9):andThen(function()
            local sProjectile = projectile.Projectile.Value:Clone() :: Model
            sProjectile:PivotTo(CFrame.new(projectile.PrimaryPart.Position) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))

            sProjectile:SetAttribute("HarukaUniqueId", projectile:GetAttribute("HarukaUniqueId"))

            sProjectile.Parent = container

            Maid:AddItem(sProjectile, 10)

            ProjectileLib.SlimeBlast(sProjectile, container)

        end):catch(function() end)
    end
    ProjectileLib.GreenSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.WheatSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.CrimsonSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.IceSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.BlueSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.LapisSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.SandSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.PurpleSlimeMove1_1 = ProjectileLib.SlimeMove1_1




    ProjectileLib.SlimeMove2_2 = function(projectile: Model, container: Folder)
        Promise.try(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = true,
            Size = "Small"
        }):catch(function() end)


        Promise.delay(0.5):andThen(function()
            local postR = ClientLib:FindGroundByRay(projectile.PrimaryPart.Position, { projectile })

            local sProjectile = projectile.Projectile.Value:Clone()
            sProjectile:PivotTo(CFrame.new(postR) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))
            sProjectile:SetAttribute("NoSound", true)

            sProjectile:SetAttribute("HarukaUniqueId", projectile:GetAttribute("HarukaUniqueId"))

            sProjectile.Parent = container

            Maid:AddItem(sProjectile, 10)

            ProjectileLib.SlimeBlast(sProjectile, container)

        end):catch(function() end)
    end
    ProjectileLib.GreenSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.WheatSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.CrimsonSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.BeeMove3_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.BlueSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.LapisSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.SandSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.PurpleSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.IceSlimeMove2_2 = ProjectileLib.SlimeMove2_2



    ProjectileLib.CrimsonSlimeMove4 = function(projectile: Model, container: Folder)
        ProjectileLib.SlimeMove1_1(projectile, container)

        Promise.delay(0.9):andThen(function()
            local sProjectile = projectile.Projectile2.Value:Clone() :: Model

            sProjectile:PivotTo(CFrame.new(projectile.PrimaryPart.Position) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))
            sProjectile:SetAttribute("HarukaUniqueId", projectile:GetAttribute("HarukaUniqueId"))

            sProjectile.Parent = container

            Maid:AddItem(sProjectile, 10)

            ProjectileLib.CrimsonSlimeBomb(sProjectile, container)

        end):catch(function() end)
    end
    ProjectileLib.PurpleSlimeMove4 = ProjectileLib.CrimsonSlimeMove4



    ProjectileLib.SlimeSpin = function(projectile: Model, container: Folder)
        TS:Create(projectile.Blast1, AssetBook.TweenInfos.twiceHalf, {
            Size = Vector3.new(16, 16, 16),
            Transparency = 1
        }):Play()
        TS:Create(projectile.Blast2, AssetBook.TweenInfos.twiceHalf, {
            Size = Vector3.new(22, 26, 26),
            Transparency = 1
        }):Play()
    end



    ProjectileLib.SlimeBlast = function(projectile: Model, container: Folder)
        projectile:AddTag("DMGEntity")

        local noSound = false
        if projectile:GetAttribute("NoSound") then
            noSound = true
        end
        if not noSound then projectile:FindFirstChildWhichIsA("Sound", true):Play() end

        projectile:PivotTo(projectile.PrimaryPart.CFrame * CFrame.new(0, 0.7, 0))


        Promise.delay(8):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)

        local blastInfo = TweenInfo.new(0.3)

        TS:Create(projectile.BlastCenter, blastInfo, {
            Size = projectile.BlastCenter.Size + Vector3.yAxis * 23,
        }):Play()
        TS:Create(projectile.Blast1, blastInfo, {
            Size = projectile.Blast1.Size + Vector3.yAxis * 12
        }):Play()
        TS:Create(projectile.Blast2, blastInfo, {
            Size = projectile.Blast2.Size + Vector3.yAxis * 16
        }):Play()
        TS:Create(projectile.Blast3, blastInfo, {
            Size = projectile.Blast3.Size + Vector3.yAxis * 12
        }):Play()
        TS:Create(projectile.Blast4, blastInfo, {
            Size = projectile.Blast4.Size + Vector3.yAxis * 16
        }):Play()

        local fadeInfo = TweenInfo.new(0.45)

        for _, part: BasePart in projectile:GetChildren() do
            if string.find(part.Name, "Blast") then
                TS:Create(part, fadeInfo, {
                    Transparency = 1
                }):Play()
            end
        end

        Promise.delay(0.3):andThen(function()
            TS:Create(projectile.BlastCenter, blastInfo, {
                Size = projectile.BlastCenter.Size - Vector3.yAxis * 22,
            }):Play()
            TS:Create(projectile.Blast1, blastInfo, {
                Size = projectile.Blast1.Size - Vector3.yAxis * 11
            }):Play()
            TS:Create(projectile.Blast2, blastInfo, {
                Size = projectile.Blast2.Size - Vector3.yAxis * 15
            }):Play()
            TS:Create(projectile.Blast3, blastInfo, {
                Size = projectile.Blast3.Size - Vector3.yAxis * 11
            }):Play()
            TS:Create(projectile.Blast4, blastInfo, {
                Size = projectile.Blast4.Size - Vector3.yAxis * 15
            }):Play()

        end):catch(function() end)
    end
    ProjectileLib.WheatSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.CrimsonSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.BlueSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.LapisSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.SandSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.PurpleSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.IceSlimeBlast = ProjectileLib.SlimeBlast



    ProjectileLib.CrimsonSlimeBomb = function(projectile: Model, container: Folder)
        Promise.delay(1):andThen(function()
            projectile:FindFirstChildWhichIsA("Sound", true):Play()

            projectile.Bomb1.Transparency = 0
            projectile.Bomb2.Transparency = 0

            Maid:AddItem(projectile.Blob, 0)
            Maid:AddItem(projectile.Core, 0)
            Maid:AddItem(projectile.Bomb1, 0.3)
            Maid:AddItem(projectile.Bomb2, 0.3)

            projectile:AddTag("DMGEntity")
            projectile:AddTag("PierceEntity")

            TS:Create(projectile.Bomb1, AssetBook.TweenInfos.twiceHalf, {
                Size = projectile.Bomb1.Size + Vector3.one * 10,
            }):Play()
            TS:Create(projectile.Bomb2, AssetBook.TweenInfos.twiceHalf, {
                Size = projectile.Bomb2.Size + Vector3.one * 15.99,
            }):Play()

            TS:Create(projectile.Bomb1, AssetBook.TweenInfos.half, {
                Transparency = 1
            }):Play()
            TS:Create(projectile.Bomb2, AssetBook.TweenInfos.half, {
                Transparency = 1
            }):Play()

        end):catch(function()
        end)
    end
    ProjectileLib.PurpleSlimeBomb = ProjectileLib.CrimsonSlimeBomb
end