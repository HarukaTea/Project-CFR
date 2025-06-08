local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local UniversalEntity = require(script.Parent.Parent.UniversalEntity)

local SlimeUniversal = {}


local wait = task.wait

SlimeUniversal.SlimeShot = function(entity: Model, target: Model)
    Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SlimeBlast"
    })

    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = ServerLib:FindGroundByRay(target.PrimaryPart.Position)

    Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
        ProjectileUniqueId = projectileUniqueId,
        ProjectileId = entity.Name.."Move1_1",
        ProjectileCF = CFrame.new(projectilePos),
        ProjectileOwner = entity
    })

    UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
end


SlimeUniversal.SlimeWave = function(entity: Model, target: Model)
    local projectileSupport = RepS.Packages.EnemyAttacks:FindFirstChild("SlimeMove2", true):Clone() :: Model
    local post = ServerLib:FindGroundByRay(entity.PrimaryPart.Position)

    projectileSupport:PivotTo(CFrame.new(post, post + entity.PrimaryPart.CFrame.LookVector))


    local hasProjectiles = 5
    for i = 1, hasProjectiles do
        for _, child: BasePart in projectileSupport:GetDescendants() do
            if child.Name ~= "Position"..i then continue end

            if (child.Position - entity:GetAttribute("CombatLocation").Position).Magnitude > 15.99 * 3 then
                child:Destroy()
                hasProjectiles -= 1
                continue
            end

            Promise.delay(0.1 * i):andThen(function()
                local projectileUniqueId = HttpService:GenerateGUID(false)..child.Name
                local projectilePos = child.CFrame

                Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
                    ProjectileUniqueId = projectileUniqueId,
                    ProjectileId = entity.Name.."Move2_2",
                    ProjectileCF = projectilePos,
                    ProjectileOwner = entity
                })

                UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)

            end):catch(function(err)
                if RunService:IsStudio() then warn(tostring(err)) end
            end)
        end
    end


    Promise.delay(0.5):andThen(function()
        for _, child: BasePart in projectileSupport:GetDescendants() do
            if child.Name ~= "Position"..hasProjectiles then continue end

            local postR = ServerLib:FindGroundByRay(child.Position, { projectileSupport })

            HarukaLib:Tween(entity, AssetBook.TweenInfos.twiceHalfOne, {
                Pivot = CFrame.new(postR) * CFrame.new(0, entity.PrimaryPart.Size.Y / 2, 0)
            })
        end

    end):catch(function(err)
        if RunService:IsStudio() then warn(tostring(err)) end
    end)

    Debris:AddItem(projectileSupport, 10)
end



SlimeUniversal.SlimeBarrageShot = function(entity: Model, target: Model)
    Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SlimeBlast"
    })

    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = ServerLib:FindGroundByRay(entity:GetAttribute("CombatLocation").Position + Vector3.new(
        math.random(-32, 32), 0,
        math.random(-32, 32)
    ))

    Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
        ProjectileUniqueId = projectileUniqueId,
        ProjectileId = entity.Name.."Move1_1",
        ProjectileCF = CFrame.new(projectilePos),
        ProjectileOwner = entity
    })

    UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
end


SlimeUniversal.SlimeBarrage = function(entity: Model)
    wait(0.35)
    Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SlimeSpin"
    })
    Events.SpawnUniATKs.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        ProjectileUniqueId = HttpService:GenerateGUID(false),
        ProjectileId = "SlimeSpin",
        ProjectileCF = CFrame.new(Vector3.one * 1599),
        ProjectileOwner = entity
    })
end


SlimeUniversal.SlimeBomb = function(entity: Model)
    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = ServerLib:FindGroundByRay(entity:GetAttribute("CombatLocation").Position + Vector3.new(
        math.random(-32, 32), 0,
        math.random(-32, 32)
    ))


    Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SlimeSpin"
    })
    Events.SpawnUniATKs.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        ProjectileUniqueId = HttpService:GenerateGUID(false),
        ProjectileId = "SlimeSpin",
        ProjectileCF = CFrame.new(Vector3.one * 1599),
        ProjectileOwner = entity
    })


    Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
        ProjectileUniqueId = projectileUniqueId,
        ProjectileId = entity.Name.."Move4",
        ProjectileCF = CFrame.new(projectilePos),
        ProjectileOwner = entity
    })

    UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
end




return SlimeUniversal
