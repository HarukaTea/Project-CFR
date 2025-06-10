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
local SlimeUniversal = require(script.Parent.SlimeUniversal)


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
    local function _slimeBomb()
        SlimeUniversal.SlimeBomb(entity)
    end
    local function _slimeDive1(target: Model)
        SlimeUniversal.SlimeDive1(entity, target)
    end
    local function _slimeDive2(target: Model)
        SlimeUniversal.SlimeDive2(entity, target)
    end
    local function _slimePurge(target: Model)
        Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            Entity = entity,
            AnimId = "SlimeSpin"
        })
        Events.SpawnUniATKs.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            ProjectileUniqueId = HttpService:GenerateGUID(false),
            ProjectileId = "SlimeSpin",
            ProjectileCF = entity.PrimaryPart.CFrame,
            ProjectileOwner = entity
        })

        _lookAt(target)
        local projectileUniqueId = HttpService:GenerateGUID(false)
        local projectilePos = ServerLib:FindGroundByRay(entity.PrimaryPart.Position)

        projectilePos = CFrame.new(projectilePos, projectilePos + entity.PrimaryPart.CFrame.LookVector)


        Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
            ProjectileUniqueId = projectileUniqueId,
            ProjectileId = entity.Name.."Move5",
            ProjectileCF = projectilePos,
            ProjectileOwner = entity
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end
    local function _slimeMassivePurge(target: Model)
        Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            Entity = entity,
            AnimId = "SlimeSpin"
        })
        Events.SpawnUniATKs.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            ProjectileUniqueId = HttpService:GenerateGUID(false),
            ProjectileId = "SlimeSpin",
            ProjectileCF = entity.PrimaryPart.CFrame,
            ProjectileOwner = entity
        })

        local projectileUniqueId = HttpService:GenerateGUID(false)
        local projectilePos = ServerLib:FindGroundByRay(entity:GetAttribute("CombatLocation").Position)

        projectilePos = CFrame.new(projectilePos) * CFrame.Angles(0, math.rad(math.random(360)), 0)


        Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
            ProjectileUniqueId = projectileUniqueId,
            ProjectileId = entity.Name.."Move6",
            ProjectileCF = projectilePos,
            ProjectileOwner = entity
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end

    --// attack functions
    table.insert(self.AttackFuncs, function(target: Model)
        if not _checkIsTargetOrEntityValid(target) then return end

        _slimeDive1(target)
        wait(0.5 + math.random(5) / 10)
        _slimeDive2(target)

        wait(0.4)
    end)
    table.insert(self.AttackFuncs, function(target: Model)
        for _ = 1, math.random(1, 3) do
            if not _checkIsTargetOrEntityValid(target) then break end

            _slimeBomb()
            wait(0.5)
        end
    end)
    table.insert(self.AttackFuncs, function(target: Model)
        if not _checkIsTargetOrEntityValid(target) then return end

        _slimePurge(target)
        wait(0.7)
    end)


    --// combo attack functions
    table.insert(self.ComboAttackFuncs, function(target: Model, _, comboR: number)
        if comboR == 1 and math.random(1, 2) == 1 then
            if not _checkIsTargetOrEntityValid(target) then return end

            _slimeBomb()
            wait(0.3)
        end
    end)
    table.insert(self.ComboAttackFuncs, function(target: Model, _, comboR: number)
        if comboR == 2 and math.random(1, 2) == 2 then
            if not _checkIsTargetOrEntityValid(target) then return end

            _slimeMassivePurge(target)
            wait(1)
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
