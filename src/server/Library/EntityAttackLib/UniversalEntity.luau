
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local ServerTable = require(SSS.HarukaServer.Library.ServerTable)


local Types = require(script.Parent.Types)


export type UniversalEntity = Types.UniversalEntity

local wait = task.wait

local UniversalEntity = {} :: UniversalEntity


--// Helper functions

local function _getCharsByRadius(pos: Vector3, radius: number)
    local charList = {}

    for _, char: Model in CollectionService:GetTagged("PlayerCharEntity") do
        if not ServerLib:IsCharValid(char) then continue end
        if not char:GetAttribute("Haruka_CriRPGServerInited") then continue end

        local plr = Players:GetPlayerFromCharacter(char)
        if not plr then continue end
        if plr:GetAttribute("IsLeaving") then continue end

        local distance = plr:DistanceFromCharacter(pos)
        if distance > 0 and distance <= radius then
            table.insert(charList, char)
        end
    end

    return charList
end



function UniversalEntity:InitTemplate(t: Types.EntityAttackObj, entity: Model)
    t.EntityId = entity.Name
    t.Entity = entity
    t.Add, t.Empty = HarukaLib.Bin()
end


function UniversalEntity:InitResolveObj(entity: Model, resolveObj: () -> ())
    local function _checkIsValid()
        if not ServerLib:IsModelValid(entity) then
            resolveObj()
        end
    end
    entity.Humanoid.HealthChanged:Connect(function(health: number)
        if health <= 0 then
            pcall(function()
                entity.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
            end)
            resolveObj()
        end
    end)
    entity:GetPropertyChangedSignal("PrimaryPart"):Connect(_checkIsValid)
    entity:GetPropertyChangedSignal("Parent"):Connect(_checkIsValid)
end


function UniversalEntity:InitAttackTables(t: Types.EntityAttackObj)
    t.Anims = {}
    t.AttackFuncs = {}
    t.ComboAttackFuncs = {}
end


function UniversalEntity:InitAttackTasks(t: Types.EntityAttackObj, resolveObj: () -> ())
    table.insert(t.Promises, Promise.try(function()
        while RunService.Stepped:Wait() do
            if UniversalEntity:CheckCombatState(t.Entity) == false then break end
        end

        resolveObj()
    end):catch(function(err)
        warn(tostring(err))
    end))


    local RNG = Random.new()

    local attackFuncPromise: Promise.TypedPromise<any> = nil

    t.Add(t.Entity.ChildAdded:Connect(function(child: Instance)
        if child:IsA("BoolValue") and child.Name == "ShockingSymbol" then
            if attackFuncPromise then
                attackFuncPromise:cancel()
                attackFuncPromise = nil
            end
        end
    end))

    while RunService.Stepped:Wait() do
        if UniversalEntity:CheckCombatState(t.Entity) == false then break end
        if UniversalEntity:CheckShockingState(t.Entity) then
            if attackFuncPromise then
                attackFuncPromise:cancel()
                attackFuncPromise = nil
            end
            continue
        end

        local rTarget = UniversalEntity:GetRandomTarget(t.Entity)
        local rFunc = RNG:NextInteger(1, #t.AttackFuncs)

        if not ServerLib:IsCharValid(rTarget) then continue end

        if attackFuncPromise then
            attackFuncPromise:cancel()
            attackFuncPromise = nil
        end
        attackFuncPromise = Promise.try(function()
            t.AttackFuncs[rFunc](rTarget)

            if #t.ComboAttackFuncs > 0 then
                RunService.Heartbeat:Wait()

                local rComboFunc = RNG:NextInteger(1, #t.ComboAttackFuncs)
                t.ComboAttackFuncs[rComboFunc](rTarget, rFunc, RNG:NextInteger(1, 2))
            end
        end)
        attackFuncPromise:await()
        attackFuncPromise = nil

        wait()
    end
end


--- combat related functions
function UniversalEntity:GetTargets(entity: Model) : { Player }
    local players = {}
    for _, targetingSymbol: ObjectValue in entity.TargetingList:GetChildren() do
        table.insert(players, Players:GetPlayerFromCharacter(targetingSymbol.Value))
    end

    return players
end


function UniversalEntity:GetNearbyPlayers(entity: Model) : { Player }
    local nearbyChars = _getCharsByRadius(entity.PrimaryPart.Position, 486)
    local players = {}

    for _, char: Model in nearbyChars do
        table.insert(players, Players:GetPlayerFromCharacter(char))
    end

    return players
end


function UniversalEntity:EditProjectileList(projectileUniqueId: string, projectilePos: Vector3 | CFrame, entity: Model)
    if typeof(projectilePos) == "CFrame" then
        projectilePos = projectilePos.Position
    end

    local projectileData = {
        UniqueId = projectileUniqueId,
        ProjectilePos = projectilePos,
        ProjectileDMG = entity:GetAttribute("DMG"),
        ProjectileLevel = entity:GetAttribute("Level"),
        Owner = entity,
    }

    --// manually add dot status effect
    if workspace:GetAttribute("_Modifier_BurnInflict") then
        projectileData.DoTStatus = "Burn"
    end

    ServerTable.EnemyProjectileSymbols[projectileUniqueId] = projectileData
    ServerTable:AddItem(ServerTable.EnemyProjectileSymbols, projectileUniqueId, 15)
end


function UniversalEntity:CheckCombatState(entity: Model) : (boolean, "NoTarget" | "Dead" | "Combating")
    if #entity.TargetingList:GetChildren() <= 0 then
        return false, "NoTarget"
    end
    if not ServerLib:IsCharValid(entity) then
        return false, "Dead"
    end

    return true, "Combating"
end


function UniversalEntity:CheckShockingState(entity: Model) : boolean
    return entity:FindFirstChild("ShockingSymbol") ~= nil
end



function UniversalEntity:GetRandomTarget(entity: Model) : Model
    local targetingList = entity.TargetingList:GetChildren()
    local rIndex = Random.new():NextInteger(1, #targetingList)

    return targetingList[rIndex].Value or nil
end


function UniversalEntity:DeadTask(t: Types.EntityAttackObj)
    t.Died = true
    t.Empty()
end


function UniversalEntity:InitFlyingEssentials(entity: Model, offset: number)
    entity.PrimaryPart.CFrame *= CFrame.new(0, offset, 0)

    local linearVel = Instance.new("LinearVelocity")
    linearVel.ForceLimitsEnabled = false
    linearVel.Attachment0 = entity.PrimaryPart:FindFirstChild("CF_RootNode")
    linearVel.VectorVelocity = Vector3.zero
    linearVel.Parent = entity.PrimaryPart
end


return UniversalEntity