--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Promise = require(RepS.HarukaShared.Shared.Promise)


local Types = require(script.Parent.Parent.Types)



local wait = task.wait

return function (self: Types.ProjectileTable)
    local ProjectileLib = self

    ProjectileLib.LeafDragonMove2 = function(projectile: Model, container: Folder)
        local r = if math.random(1, 2) == 1 then -90 else 0

        projectile:PivotTo(projectile.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(r), 0))
        projectile:PivotTo(projectile.PrimaryPart.CFrame * CFrame.new(0, 1.2, 0))

        local delayTime = 0.2

        for _, part: BasePart in projectile:GetDescendants() do
            if part.Name == "Part" then
                Promise.delay(delayTime):andThen(function()
                    ProjectileLib._spawnProjectile(projectile, container, 6, function(sProjectile: Model)
                        sProjectile:PivotTo(part.CFrame)
                    end)

                end):catch(function() end)

                delayTime += 0.1
            end
        end
    end

    ProjectileLib.LeafDragonMove3 = function(projectile: Model, container: Folder)
        Promise.delay(2):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)


        projectile:PivotTo(projectile.PrimaryPart.CFrame * CFrame.new(0, 1.2, 0))


        for _, part: BasePart in projectile:GetDescendants() do
            if part.Name == "Part" then
                part.Transparency = 0.8
            end
        end
        pcall(function()
            wait(0.5)
            for _, part: BasePart in projectile:GetDescendants() do
                if part.Name == "Part" then
                    part.Transparency = 0
                end
            end
            projectile:AddTag("DMGEntity")
        end)
    end


    ProjectileLib.LeafDragonSpike3 = function(projectile: Model, container: Folder)
        Promise.delay(2):andThenCall(ProjectileLib._fadeAwayAndDestroy, projectile):catch(function() end)

        projectile.Part.Transparency = 0.8

        pcall(function()
            wait(0.5)
            projectile.Part.Transparency = 0
            projectile:AddTag("DMGEntity")
        end)
    end
end