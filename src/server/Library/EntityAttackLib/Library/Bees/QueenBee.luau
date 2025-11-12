
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
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


    --// init
    do
        entity.PrimaryPart.CFrame *= CFrame.new(0, 7, 0)


        local linearVel = Instance.new("LinearVelocity")
        linearVel.ForceLimitsEnabled = false
        linearVel.Attachment0 = entity.PrimaryPart:FindFirstChild("AlignMoverAttachment")
        linearVel.VectorVelocity = Vector3.zero
        linearVel.Parent = entity.PrimaryPart
    end


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

        entity:PivotTo(CFrame.new(projectilePos) * CFrame.new(0, 7, 0) * CFrame.new(0, entity.PrimaryPart.Size.Y / 2, 0))
    end
    local function _spike(target: Model)

        _lookAt(target)

        Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            Entity = entity,
            AnimId = "SpikeAttack"
        })


        local projectileUniqueId = HttpService:GenerateGUID(false)
        local projectilePos = ServerLib.FindGroundByRay(target.PrimaryPart.Position)

        Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
            ProjectileUniqueId = projectileUniqueId,
            ProjectileId = "BeeMove1",
            ProjectileCF = CFrame.new(projectilePos),
            ProjectileOwner = entity
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end
    local function _spikeShot(target: Model)

        _lookAt(target)

        Events.PlayAnimForEnemy.FireList(UniversalEntity:GetNearbyPlayers(entity), {
            Entity = entity,
            AnimId = "SpikeAttack"
        })

        local projectileUniqueId = HttpService:GenerateGUID(false)
        local projectilePos = entity.PrimaryPart.CFrame

        projectilePos = CFrame.lookAt(projectilePos.Position, target.PrimaryPart.Position)

        Events.SpawnATKs.FireList(UniversalEntity:GetTargets(entity), {
            ProjectileUniqueId = projectileUniqueId,
            ProjectileId = "BeeMove2",
            ProjectileCF = projectilePos,
            ProjectileOwner = entity
        })

        UniversalEntity:EditProjectileList(projectileUniqueId, projectilePos, entity)
    end
    local function _beeRush(target: Model)

        _lookAt(target)

        local projectileSupport = RepS.Packages.EnemyAttacks:FindFirstChild("BeeMove3", true):Clone() :: Model
        local post = ServerLib.FindGroundByRay(entity.PrimaryPart.Position)

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
                        ProjectileId = "BeeMove3_2",
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

                local postR = ServerLib.FindGroundByRay(child.Position)

                HarukaLib:Tween(entity, AssetBook.TweenInfos.twiceHalfOne, {
                    Pivot = CFrame.new(postR) * CFrame.new(0, 7, 0) * CFrame.new(0, entity.PrimaryPart.Size.Y / 2, 0)
                })
            end

        end):catch(function(err)
            if RunService:IsStudio() then warn(tostring(err)) end
        end)

        Debris:AddItem(projectileSupport, 10)
    end



    --// attack functions
    table.insert(self.AttackFuncs, function(target)
        for _ = 1, math.random(1, 3) do
            if not _checkIsTargetOrEntityValid(target) then break end


            _spike(target)
            wait(0.25)
        end
    end)
    table.insert(self.AttackFuncs, function(target)
        for _ = 1, math.random(1, 3) do
            if not _checkIsTargetOrEntityValid(target) then break end


            _spikeShot(target)
            wait(0.1)
        end
    end)

    --// combo attack functions
    table.insert(self.ComboAttackFuncs, function(target: Model, _, comboR: number)
        if comboR == 2 then
            for _ = 1, math.random(1, 2) do
                if not _checkIsTargetOrEntityValid(target) then break end


                _moving()
                wait(0.15)
            end
        end
    end)
    table.insert(self.ComboAttackFuncs, function(target, _, comboR: number)
        if comboR == 1 then
            if not _checkIsTargetOrEntityValid(target) then return end


            _beeRush(target)
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