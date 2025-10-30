
local HttpService = game:GetService("HttpService")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)

local Types = require(script.Parent.Parent.Parent.Types)
local UniversalEntity = shared.UniversalEntity :: Types.UniversalEntity


local wait = task.wait


local Entity = {} :: Types.EntityAttackObj
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


    local function _spike(target: Model)

        local projectileUniqueId = HttpService:GenerateGUID(false)
        local projectilePos = ServerLib.FindGroundByRay(target.PrimaryPart.Position)

        Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
            ProjectileUniqueId = projectileUniqueId,
            ProjectileId = "LeafDragonMove1",
            ProjectileCF = CFrame.new(projectilePos),
            ProjectileOwner = entity
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end
    local function _allAreaBurnCombo()
        local projectileUniqueId = HttpService:GenerateGUID(false)
        local projectilePos = ServerLib.FindGroundByRay(entity:GetAttribute("CombatLocation").Position)

        Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
            ProjectileUniqueId = projectileUniqueId,
            ProjectileId = "LeafDragonMove2",
            ProjectileCF = CFrame.new(projectilePos),
            ProjectileOwner = entity
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end
    local function _allAreaBurnCombo2(target: Model)

        local projectileUniqueId = HttpService:GenerateGUID(false)
        local projectilePos = ServerLib.FindGroundByRay(target.PrimaryPart.Position)

        Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
            ProjectileUniqueId = projectileUniqueId,
            ProjectileId = "LeafDragonMove3",
            ProjectileCF = CFrame.new(projectilePos),
            ProjectileOwner = entity
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end



    --// attack functions
    table.insert(self.AttackFuncs, function(target)
        for _ = 1, math.random(1, 3) do
            if not _checkIsTargetOrEntityValid(target) then break end


            _spike(target)
            wait(0.25)
        end
    end)

    --// combo attack functions
    table.insert(self.ComboAttackFuncs, function(target, _, comboR: number)
        if comboR == 1 then
            _allAreaBurnCombo()
            wait(0.6)
        end
    end)
    table.insert(self.ComboAttackFuncs, function(target, _, comboR: number)
        if comboR == 2 and math.random(1, 2) == 1 then
            if not _checkIsTargetOrEntityValid(target) then return end


            _allAreaBurnCombo2(target)
            wait(0.6)
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