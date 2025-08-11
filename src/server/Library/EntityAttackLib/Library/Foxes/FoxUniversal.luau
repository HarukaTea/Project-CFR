--!nocheck

local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local Types = require(script.Parent.Parent.Parent.Types)
local UniversalEntity = shared.UniversalEntity :: Types.UniversalEntity


local wait = task.wait


local FoxUniversal = {}



FoxUniversal.SpikeShot = function(entity: Model, target: Model)
    Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SpikeShot"
    })

    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = entity.PrimaryPart.CFrame

    projectilePos = CFrame.lookAt(projectilePos.Position, target.PrimaryPart.Position)

    local r = math.random(1, 2)

    Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
        ProjectileUniqueId = projectileUniqueId,
        ProjectileId = "FoxMove"..r,
        ProjectileCF = projectilePos,
        ProjectileOwner = entity,
    })

    UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
end


FoxUniversal.SpikeRain = function(entity: Model, target: Model)
    Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SpikeRain"
    })


    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = ServerLib.FindGroundByRay(target.PrimaryPart.Position)

    Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
        ProjectileUniqueId = projectileUniqueId,
        ProjectileId = "FoxMove3",
        ProjectileCF = CFrame.new(projectilePos),
        ProjectileOwner = entity,
    })

    UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)


    Promise.delay(0.5):andThen(function()
        for i = 1, math.random(5, 6) do
            RunService.Heartbeat:Wait()
            wait()

            local random = Vector3.new(math.random(-15, 15), 0, math.random(-15, 15))
            if i == 1 then
                random = Vector3.zero
            end
            local post = ServerLib.FindGroundByRay(projectilePos + random)

            Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
                ProjectileUniqueId = projectileUniqueId,
                ProjectileId = "FoxSpike2",
                ProjectileCF = CFrame.new(post),
                ProjectileOwner = entity,
            })
        end
    end):catch(function() end)
end


return FoxUniversal
