--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")


local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local Types = require(script.Parent.Parent.Parent.Types)
local UniversalEntity = shared.UniversalEntity :: Types.UniversalEntity

local FoxUniversal = require(script.Parent.FoxUniversal)


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
        if not ServerLib.IsCharValid(entity) then return false end
        if not ServerLib.IsCharValid(target) then return false end

        return true
    end



    local function _lookAt(target: Model)
        entity:PivotTo(HarukaLib:CFLookAt(entity.PrimaryPart.Position, target.PrimaryPart.Position))
    end
    local function _moving()
        local projectilePos = ServerLib.FindGroundByRay(entity:GetAttribute("CombatLocation").Position +
            Vector3.new(math.random(-32, 32), 0, math.random(-32, 32)))

        entity:PivotTo(CFrame.new(projectilePos) * CFrame.new(0, entity.PrimaryPart.Size.Y / 2, 0))
    end
    local function _spikeShot(target: Model)
        _lookAt(target)

        FoxUniversal.SpikeShot(entity, target)
    end
    local function _spikeRain(target: Model)
        FoxUniversal.SpikeRain(entity, target)
    end
    local function _wolfBite(target: Model)
        Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            Entity = entity,
            AnimId = "WolfBite"
        })

        local projectileUniqueId = HttpService:GenerateGUID(false)
        local projectilePos = ServerLib.FindGroundByRay(target.PrimaryPart.Position)

        projectilePos = HarukaLib:CFLookAt(projectilePos, entity.PrimaryPart.Position)


        Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
            ProjectileUniqueId = projectileUniqueId,
            ProjectileId = "WolfMove4",
            ProjectileCF = projectilePos,
            ProjectileOwner = entity
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end



    --// attack functions
    table.insert(self.AttackFuncs, function(target: Model)
        for _ = 1, math.random(2, 3) do
            if not _checkIsTargetOrEntityValid(target) then break end


            _spikeRain(target)
            wait(0.8)
        end
    end)
    table.insert(self.AttackFuncs, function(target: Model)
        for _ = 1, math.random(2, 3) do
            if not _checkIsTargetOrEntityValid(target) then break end


            _wolfBite(target)
            wait(0.8)
        end
    end)


    --// combo attack functions
    table.insert(self.ComboAttackFuncs, function(target: Model, _, comboR: number)
        if comboR == 2 then
            for _ = 1, math.random(1, 2) do
                if not _checkIsTargetOrEntityValid(target) then break end

                _moving()
                wait(0.5)
            end
        end
    end)
    table.insert(self.ComboAttackFuncs, function(target: Model, _, comboR: number)
        if comboR == 1 then
            for _ = 1, math.random(1, 2) do
                if not _checkIsTargetOrEntityValid(target) then break end


                _spikeShot(target)
                wait(0.8)
            end
        end
    end)


    --// attack loop
    wait(0.5)
    UniversalEntity:InitAttackTasks(self, resolveObjPack)


    --// end the promise chain
    resolveObjPack()
end


function Entity:Destroy()
    UniversalEntity:DeadTask(self)
end

return Entity :: Types.EntityAttackLib