
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")


local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local Types = require(script.Parent.Parent.Parent.Types)
local UniversalEntity = require(script.Parent.Parent.Parent.UniversalEntity)


local SlimeUniversal = require(script.Parent.SlimeUniversal)


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


    local function _lookAt(target: Model)


        entity:PivotTo(HarukaLib:CFLookAt(entity.PrimaryPart.Position, target.PrimaryPart.Position))
    end
    local function _slimeShot(target: Model)
        _lookAt(target)

        SlimeUniversal.SlimeShot(entity, target)
    end
    local function _slimeWave(target: Model)
        _lookAt(target)

        SlimeUniversal.SlimeWave(entity, target)
    end


    --// attack functions
    table.insert(self.AttackFuncs, function(target: Model)
        for _ = 1, math.random(1, 2) do
            for _ = 1, 3 do
                if not _checkIsTargetOrEntityValid(target) then break end

                _slimeShot(target)
                wait(1.5)
            end
        end
    end)
    table.insert(self.AttackFuncs, function(target: Model)
        for _ = 1, math.random(1, 3) do
            if not _checkIsTargetOrEntityValid(target) then break end

            _slimeWave(target)
            wait(1.5)
        end
    end)

    --// combo attack functions
    table.insert(self.ComboAttackFuncs, function(target: Model, attackR: number, comboR: number)
        if attackR == 2 then return end
        if comboR == 1 then
            if not _checkIsTargetOrEntityValid(target) then return end



            _slimeWave(target)
            wait(1.2)
        end
    end)


    --// attack loop
    wait(1)
    UniversalEntity:InitAttackTasks(self, resolveObjPack)


    --// end the promise chain
    resolveObjPack()
end


function Entity:Destroy()
    UniversalEntity:DeadTask(self)
end

return Entity