--!nocheck

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TS = TweenService
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local wait = task.wait

return function (self)
    local ProjectileLib = self

    ProjectileLib.SlimeMove1_1 = function(projectile: Model, container: Folder)
        local entity = projectile.Owner.Value :: Model

        pcall(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = true,
            Size = "Small"
        })


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
            HarukaLib:Tween(projectile.Shot, AssetBook.TweenInfos.half, { Pivot = projectile.Shot.Base.CFrame * CFrame.Angles(-rotatingangle, 0, 0) }, true):Wait()

            projectile.Shot:Destroy()
        end):catch(function()  end)


        Promise.delay(0.9):andThen(function()
            ProjectileLib._spawnProjectile(projectile, container, 5, function(sProjectile: Model)
                sProjectile:PivotTo(CFrame.new(projectile.PrimaryPart.Position) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))
            end)
        end):catch(function() end)
    end
    ProjectileLib.GreenSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.WheatSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.IceSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.BlueSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.LapisSlimeMove1_1 = ProjectileLib.SlimeMove1_1
    ProjectileLib.SandSlimeMove1_1 = ProjectileLib.SlimeMove1_1




    ProjectileLib.SlimeMove2_2 = function(projectile: Model, container: Folder)
        pcall(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = true,
            Size = "Small"
        })

        wait(0.5)
        if projectile:FindFirstChildWhichIsA("Sound", true) then
            projectile:FindFirstChildWhichIsA("Sound", true):Play()
        end

        local postR = ClientLib:FindGroundByRay(projectile.PrimaryPart.Position)

        ProjectileLib._spawnProjectile(projectile, container, 5, function(sProjectile: Model)
            sProjectile:PivotTo(CFrame.new(postR) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))
        end)
    end
    ProjectileLib.GreenSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.WheatSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.BeeMove3_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.BlueSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.LapisSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.SandSlimeMove2_2 = ProjectileLib.SlimeMove2_2
    ProjectileLib.IceSlimeMove2_2 = ProjectileLib.SlimeMove2_2



    ProjectileLib.CrimsonSlimeMove4 = function(projectile: Model, container: Folder)
        ProjectileLib.SlimeMove1_1(projectile, container)

        wait(0.9)
        local sProjectile = projectile.Projectile2.Value:Clone() :: Model

        sProjectile:PivotTo(CFrame.new(projectile.PrimaryPart.Position) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))
        sProjectile:SetAttribute("HarukaUniqueId", projectile:GetAttribute("HarukaUniqueId"))

        projectile.Owner:Clone().Parent = sProjectile
        sProjectile.Parent = container

        ProjectileLib.CrimsonSlimeBomb(sProjectile, container)
    end
    ProjectileLib.PurpleSlimeMove4 = ProjectileLib.CrimsonSlimeMove4
    ProjectileLib.EvolvedGreenSlimeMove4 = ProjectileLib.CrimsonSlimeMove4
    ProjectileLib.KingSlimeMove4 = ProjectileLib.CrimsonSlimeMove4



    ProjectileLib.PurpleSlimeMove3 = function(projectile: Model, container: Folder)
        pcall(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = true,
            Size = "Big"
        })

        wait(0.5)
        for i = 1, 2 do
            for _, part: BasePart in projectile:GetDescendants() do
                if part.Name == "Position"..i then
                    local pos = ClientLib:FindGroundByRay(part.Position)

                    ProjectileLib._spawnProjectile(projectile, container, 5, function(sProjectile: Model)
                        sProjectile:PivotTo(CFrame.new(pos, pos + part.CFrame.LookVector) * CFrame.Angles(0, math.rad(math.random(1, 360)), 0))
                    end)
                end
            end
            wait(0.1)
        end
    end
    ProjectileLib.IceSlimeMove3 = ProjectileLib.PurpleSlimeMove3
    ProjectileLib.WheatSlimeMove3 = ProjectileLib.PurpleSlimeMove3
    ProjectileLib.LapisSlimeMove3 = ProjectileLib.PurpleSlimeMove3
    ProjectileLib.EvolvedGreenSlimeMove3 = ProjectileLib.PurpleSlimeMove3
    ProjectileLib.KingSlimeMove3 = ProjectileLib.PurpleSlimeMove3
    ProjectileLib.CrimsonSlimeMove3 = ProjectileLib.PurpleSlimeMove3



    ProjectileLib.SlimeSpin = function(projectile: Model, container: Folder)
        HarukaLib:CreateTween(projectile.Blast1, AssetBook.TweenInfos.twiceHalf, {
            Size = Vector3.new(16, 16, 16),
            Transparency = 1
        }):Play()
        HarukaLib:CreateTween(projectile.Blast2, AssetBook.TweenInfos.twiceHalf, {
            Size = Vector3.new(22, 26, 26),
            Transparency = 1
        }):Play()
    end



    ProjectileLib.SlimeBlast = function(projectile: Model, container: Folder)
        local noSound = false
        if projectile:GetAttribute("NoSound") then
            noSound = true
        end
        if not noSound then projectile:FindFirstChildWhichIsA("Sound", true):Play() end


        Promise.delay(4.5):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)

        local blastInfo = TweenInfo.new(0.3)

        HarukaLib:CreateTween(projectile.BlastCenter, blastInfo, {
            Size = projectile.BlastCenter.Size + Vector3.yAxis * 22,
        }):Play()
        HarukaLib:CreateTween(projectile.Blast1, blastInfo, {
            Size = projectile.Blast1.Size + Vector3.yAxis * 11
        }):Play()
        HarukaLib:CreateTween(projectile.Blast2, blastInfo, {
            Size = projectile.Blast2.Size + Vector3.yAxis * 15
        }):Play()
        HarukaLib:CreateTween(projectile.Blast3, blastInfo, {
            Size = projectile.Blast3.Size + Vector3.yAxis * 11
        }):Play()
        HarukaLib:CreateTween(projectile.Blast4, blastInfo, {
            Size = projectile.Blast4.Size + Vector3.yAxis * 15
        }):Play()

        projectile:AddTag("DMGEntity")

        local fadeInfo = TweenInfo.new(0.45)
        for _, part: BasePart in projectile:GetChildren() do
            if string.find(part.Name, "Blast") then
                HarukaLib:CreateTween(part, fadeInfo, {
                    Transparency = 1
                }):Play()
            end
        end

        pcall(function()
            wait(0.3)
            HarukaLib:CreateTween(projectile.BlastCenter, blastInfo, {
                Size = projectile.BlastCenter.Size - Vector3.yAxis * 22,
            }):Play()
            HarukaLib:CreateTween(projectile.Blast1, blastInfo, {
                Size = projectile.Blast1.Size - Vector3.yAxis * 11
            }):Play()
            HarukaLib:CreateTween(projectile.Blast2, blastInfo, {
                Size = projectile.Blast2.Size - Vector3.yAxis * 15
            }):Play()
            HarukaLib:CreateTween(projectile.Blast3, blastInfo, {
                Size = projectile.Blast3.Size - Vector3.yAxis * 11
            }):Play()
            HarukaLib:CreateTween(projectile.Blast4, blastInfo, {
                Size = projectile.Blast4.Size - Vector3.yAxis * 15
            }):Play()
        end)
    end
    ProjectileLib.WheatSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.CrimsonSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.BlueSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.LapisSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.SandSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.PurpleSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.IceSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.EvolvedGreenSlimeBlast = ProjectileLib.SlimeBlast
    ProjectileLib.KingSlimeBlast = ProjectileLib.SlimeBlast



    ProjectileLib.CrimsonSlimeBomb = function(projectile: Model, container: Folder)
        pcall(function()
            wait(1)
            projectile:FindFirstChildWhichIsA("Sound", true):Play()

            projectile.Bomb1.Transparency = 0
            projectile.Bomb2.Transparency = 0
            projectile.Bomb1.CanTouch = true
            projectile.Bomb2.CanTouch = true

            projectile.Blob:Destroy()
            projectile.Core:Destroy()
            projectile:AddTag("DMGEntity")
            projectile:AddTag("PierceEntity")

            Debris:AddItem(projectile, 0.35)

            HarukaLib:CreateTween(projectile.Bomb1, AssetBook.TweenInfos.half, {
                Size = projectile.Bomb1.Size + Vector3.one * 9,
                Transparency = 1
            }):Play()
            HarukaLib:CreateTween(projectile.Bomb2, AssetBook.TweenInfos.half, {
                Size = projectile.Bomb2.Size + Vector3.one * 14,
                Transparency = 1
            }):Play()
        end)
    end
    ProjectileLib.PurpleSlimeBomb = ProjectileLib.CrimsonSlimeBomb
    ProjectileLib.EvolvedGreenSlimeBomb = ProjectileLib.CrimsonSlimeBomb
    ProjectileLib.KingSlimeBomb = ProjectileLib.CrimsonSlimeBomb
end