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
    local function _moving()
        local projectilePos = ServerLib:FindGroundByRay(entity:GetAttribute("CombatLocation").Position +
            Vector3.new(math.random(-32, 32), 0, math.random(-32, 32)))

        entity:PivotTo(CFrame.new(projectilePos) * CFrame.new(0, entity.PrimaryPart.Size.Y / 2, 0))
    end
    local function _spikeShot(target: Model)
        _lookAt(target)

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
    local function _spikeRain(target: Model)
        Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            Entity = entity,
            AnimId = "SpikeRain"
        })


        local projectileUniqueId = HttpService:GenerateGUID(false)
        local projectilePos = ServerLib:FindGroundByRay(target.PrimaryPart.Position)

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
                local post = ServerLib:FindGroundByRay(projectilePos + random)

                Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
                    ProjectileUniqueId = projectileUniqueId,
                    ProjectileId = "FoxSpike2",
                    ProjectileCF = CFrame.new(post),
                    ProjectileOwner = entity,
                })
            end
        end):catch(function()
        end)
    end


    --// attack functions
    table.insert(self.AttackFuncs, function(target: Model)
        for _ = 1, math.random(2, 3) do
            if not _checkIsTargetOrEntityValid(target) then break end


            _spikeRain(target)
            wait(0.6)
        end
    end)
    table.insert(self.AttackFuncs, function(target: Model)
        if not _checkIsTargetOrEntityValid(target) then return end


        _spikeShot(target)
        wait(0.5)
    end)

    --// combo attack functions
    table.insert(self.ComboAttackFuncs, function(target: Model, _, comboR: number)
        if comboR == 2 then
            for _ = 1, math.random(1, 2) do
                if not _checkIsTargetOrEntityValid(target) then break end


                _moving()
                wait(0.3)
            end
        end
    end)
    table.insert(self.ComboAttackFuncs, function(target: Model, _, comboR: number)
        if comboR == 1 then
            if not _checkIsTargetOrEntityValid(target) then return end


            _spikeShot(target)
            wait(0.5)
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

return Entity
