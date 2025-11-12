
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
    local function _slimeBomb()
        SlimeUniversal.SlimeBomb(entity)
    end
    local function _slimeDive1(target: Model)
        SlimeUniversal.SlimeDive1(entity, target)
    end
    local function _slimeDive2(target: Model)
        SlimeUniversal.SlimeDive2(entity, target)
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


    --// combo attack functions
    table.insert(self.ComboAttackFuncs, function(target: Model, _, comboR: number)
        if comboR == 1 and math.random(1, 2) == 1 then
            if not _checkIsTargetOrEntityValid(target) then return end

            _slimeBomb()
            wait(0.3)
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