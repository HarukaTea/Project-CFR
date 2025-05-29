--!nocheck

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
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


local wait = task.wait


local Entity = {}
Entity.__index = Entity


function Entity.new(entity: Model)
    local self = setmetatable({}, Entity)

    UniversalEntity:InitTemplate(self, entity)

    return self
end



function Entity:DoAttackTasks(resolveObj: () -> nil)
    local entity = self.Entity :: Model

    self.Promises = {}
    local resolveObjPack = function()
        pcall(function()
            for _, promise in self.Promises do
                promise:cancel()
            end
        end)
        resolveObj()
    end


    UniversalEntity:InitResolveObj(entity, resolveObjPack)
    UniversalEntity:InitAttackTables(self)



    local function _checkIsTargetOrEntityValid(target: Model)
        if not ServerLib:IsCharValid(entity) then return false end
        if not ServerLib:IsCharValid(target) then return false end

        return true
    end

    local function _lookAt(target: Model)
        entity:PivotTo(HarukaLib:CFLookAt(entity.PrimaryPart.Position, target.PrimaryPart.Position))
    end
    local function _slimeShotButBarrage(target: Model)
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
            ProjectileId = "CrimsonSlimeMove1_1",
            ProjectileCF = CFrame.new(projectilePos),
            ProjectileOwner = entity,
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end
    local function _slimeBarrage(target: Model)
        for _ = 1, math.random(5, 6) do
            _slimeShotButBarrage()
            RunService.Stepped:Wait()
        end

        wait(0.35)
        Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            Entity = entity,
            AnimId = "SlimeSpin"
        })
        Events.SpawnUniATKs.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            ProjectileUniqueId = HttpService:GenerateGUID(false),
            ProjectileId = "SlimeSpin",
            ProjectileCF = CFrame.new(Vector3.one * 1599),
            ProjectileOwner = entity,
        })
    end
    local function _slimeWave(target: Model)
        _lookAt(target)

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
                        ProjectileId = "CrimsonSlimeMove2_2",
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
    local function _slimeBomb()
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
            ProjectileId = "CrimsonSlimeMove4",
            ProjectileCF = CFrame.new(projectilePos),
            ProjectileOwner = entity
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end

    --// attack functions
    table.insert(self.AttackFuncs, function(target: Model)
        for _ = 1, math.random(1, 2) do
            if not _checkIsTargetOrEntityValid(target) then break end

            _slimeBarrage()
            wait(0.1599 * 3)
        end
    end)
    table.insert(self.AttackFuncs, function(target: Model)
        for _ = 1, math.random(1, 2) do
            if not _checkIsTargetOrEntityValid(target) then break end


            _slimeBomb()
            wait(0.1599 * 3)
        end
    end)

    --// combo attack functions
    table.insert(self.ComboAttackFuncs, function(target: Model, _, comboR: number)
        if comboR == 2 and math.random(1, 2) == 1 then
            if not _checkIsTargetOrEntityValid(target) then return end


            _slimeWave(target)
            wait(0.5)
        end
    end)


   --// attack loop
   wait(0.1)
   UniversalEntity:InitAttackTasks(self, resolveObjPack)


   --// end the promise chain
   resolveObjPack()
end


function Entity:Destroy()
    UniversalEntity:DeadTask(self)
end

return Entity
