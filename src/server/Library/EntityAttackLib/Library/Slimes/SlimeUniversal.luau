
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local Types = require(script.Parent.Parent.Parent.Types)
local UniversalEntity = require(script.Parent.Parent.Parent.UniversalEntity)

local SlimeUniversal = {}


local wait = task.wait

SlimeUniversal.SlimeShot = function(entity: Model, target: Model)


    Events.PlayEnemyAnim_S.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SlimeBlast"
    })

    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = ServerLib:FindGroundByRay(target.PrimaryPart.Position)

    Events.SpawnEnemyATKs_S.FireList(UniversalEntity:GetTargets(entity), {
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
        for _, child: BasePart in projectileSupport:QueryDescendants("#Position"..i) do
            if (child.Position - entity:GetAttribute("CombatLocation").Position).Magnitude > 15.99 * 3 then
                child:Destroy()
                hasProjectiles -= 1
                continue
            end

            Promise.delay(0.1 * i):andThen(function()
                local projectileUniqueId = HttpService:GenerateGUID(false)..child.Name
                local projectilePos = child.CFrame

                Events.SpawnEnemyATKs_S.FireList(UniversalEntity:GetTargets(entity), {
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
        for _, child: BasePart in projectileSupport:QueryDescendants("#Position"..hasProjectiles) do
            local postR = ServerLib:FindGroundByRay(child.Position)

            HarukaLib:Tween(entity, AssetBook.TweenInfos.twiceHalfOne, {
                Pivot = CFrame.new(postR) * CFrame.new(0, entity.PrimaryPart.Size.Y / 2, 0)
            })
        end

    end):catch(function(err)
        if RunService:IsStudio() then warn(tostring(err)) end
    end)

    Debris:AddItem(projectileSupport, 10)
end



SlimeUniversal.SlimeBarrageShot = function(entity: Model)


    Events.PlayEnemyAnim_S.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SlimeBlast"
    })

    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = ServerLib:FindGroundByRay(entity:GetAttribute("CombatLocation").Position + Vector3.new(
        math.random(-32, 32), 0,
        math.random(-32, 32)
    ))

    Events.SpawnEnemyATKs_S.FireList(UniversalEntity:GetTargets(entity), {
        ProjectileUniqueId = projectileUniqueId,
        ProjectileId = entity.Name.."Move1_1",
        ProjectileCF = CFrame.new(projectilePos),
        ProjectileOwner = entity
    })

    UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
end


SlimeUniversal.SlimeSpin = function(entity: Model)
    wait(0.35)
    Events.PlayEnemyAnim_S.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SlimeSpin"
    })
    Events.SpawnEnemyATKs_S.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        ProjectileUniqueId = HttpService:GenerateGUID(false),
        ProjectileId = "SlimeSpin",
        ProjectileCF = entity.PrimaryPart.CFrame,
        ProjectileOwner = entity,

        IsUniATK = true
    })
end


SlimeUniversal.SlimeBomb = function(entity: Model)


    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = ServerLib:FindGroundByRay(entity:GetAttribute("CombatLocation").Position + Vector3.new(
        math.random(-32, 32), 0,
        math.random(-32, 32)
    ))


    Events.PlayEnemyAnim_S.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        Entity = entity,
        AnimId = "SlimeSpin"
    })
    Events.SpawnEnemyATKs_S.FireList(UniversalEntity:GetNearbyPlayers(entity), {
        ProjectileUniqueId = HttpService:GenerateGUID(false),
        ProjectileId = "SlimeSpin",
        ProjectileCF = entity.PrimaryPart.CFrame,
        ProjectileOwner = entity,

        IsUniATK = true
    })


    Events.SpawnEnemyATKs_S.FireList(UniversalEntity:GetTargets(entity), {
        ProjectileUniqueId = projectileUniqueId,
        ProjectileId = entity.Name.."Move4",
        ProjectileCF = CFrame.new(projectilePos),
        ProjectileOwner = entity
    })

    UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
end



SlimeUniversal.SlimeDive1 = function(entity: Model, target: Model)


    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = ServerLib:FindGroundByRay(target.PrimaryPart.Position)

    local realProjectilePos = CFrame.new(projectilePos, projectilePos + entity.PrimaryPart.CFrame.LookVector) * CFrame.Angles(0, math.rad(math.random(360)), 0)


    Events.SpawnEnemyATKs_S.FireList(UniversalEntity:GetTargets(entity), {
        ProjectileUniqueId = projectileUniqueId,
        ProjectileId = entity.Name.."Move3",
        ProjectileCF = realProjectilePos,
        ProjectileOwner = entity
    })

    UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)


    local immuneTag = Instance.new("BoolValue")
    immuneTag.Name = "AttackImmune"
    immuneTag.Parent = entity
    Debris:AddItem(immuneTag, 1.5)


    local diveDown = realProjectilePos * CFrame.new(0, -8, 0)

    wait(0.5)
    entity.PrimaryPart.Anchored = true

    HarukaLib:Tween(entity, AssetBook.TweenInfos.half, {
        Pivot = diveDown
    })
end



SlimeUniversal.SlimeDive2 = function(entity: Model, target: Model)


    local projectileUniqueId = HttpService:GenerateGUID(false)
    local projectilePos = ServerLib:FindGroundByRay(target.PrimaryPart.Position)

    local realProjectilePos = CFrame.new(projectilePos, projectilePos + entity.PrimaryPart.CFrame.LookVector) * CFrame.Angles(0, math.rad(math.random(360)), 0)


    Events.SpawnEnemyATKs_S.FireList(UniversalEntity:GetTargets(entity), {
        ProjectileUniqueId = projectileUniqueId,
        ProjectileId = entity.Name.."Move3",
        ProjectileCF = realProjectilePos,
        ProjectileOwner = entity
    })

    UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)

    local diveDown = realProjectilePos * CFrame.new(0, -8, 0)

    entity.PrimaryPart.Anchored = true

    HarukaLib:Tween(entity, AssetBook.TweenInfos.half, {
        Pivot = diveDown
    })

    local diveUp = realProjectilePos * CFrame.new(0, entity.PrimaryPart.Size.Y / 2, 0)

    wait(0.5)
    entity.PrimaryPart.Anchored = false

    HarukaLib:Tween(entity, AssetBook.TweenInfos.half, {
        Pivot = diveUp
    })
end



return SlimeUniversal