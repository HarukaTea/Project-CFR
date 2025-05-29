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
        Promise.try(ProjectileLib._rotateAttentionPoint, projectile.PrimaryPart, container, {
            ShouldDetail = true,
            Size = "Small"
        }):catch(function() end)


        Promise.delay(0.5):andThen(function()
            local sProjectile = projectile.Projectile.Value:Clone() :: Model
            sProjectile:PivotTo(projectile.PrimaryPart.CFrame)

            sProjectile:SetAttribute("HarukaUniqueId", projectile:GetAttribute("HarukaUniqueId"))

            sProjectile.Parent = container

            Maid:AddItem(sProjectile, 6)

            ProjectileLib.BeeSpike1(sProjectile, container)

        end):catch(function() end)
    end
    ProjectileLib.LeafDragonMove1 = ProjectileLib.BeeMove1



    ProjectileLib.BeeSpike1 = function(projectile: Model, container: Folder)
        projectile:AddTag("DMGEntity")

        if not projectile:GetAttribute("NoSound") then
            projectile:FindFirstChildWhichIsA("Sound", true):Play()
        end

        Bindables.ClientTween:Fire({
            Objs = { projectile },
            Goal = { Pivot = projectile.PrimaryPart.CFrame * CFrame.new(0, 11, 0) },
            TweenInfo = "half",
            UseHarukaTween = true
        })

        Promise.delay(5):andThen(function()
            Bindables.ClientTween:Fire({
                Objs = { projectile },
                Goal = { Pivot = projectile.PrimaryPart.CFrame * CFrame.new(0, -11, 0) },
                TweenInfo = "one",
                UseHarukaTween = true
            })
        end):catch(function() end)
    end
end