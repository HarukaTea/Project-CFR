--!nocheck

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local wait = task.wait

local UniversalEntity = {}


--// Helper functions

local function _getCharsByRadius(pos: Vector3, radius: number)
    local charList = {}

    for _, char: Model in CollectionService:GetTagged("PlayerCharEntity") do
        if not ServerLib:IsCharValid(char) then continue end
        if not char:GetAttribute("_CharDataInited") then continue end

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



UniversalEntity.InitTemplate = function(_, self: table, entity: Model)
    self.EntityId = entity.Name
    self.Entity = entity

    self.Add, self.Empty = HarukaLib.Bin()
end


UniversalEntity.InitResolveObj = function(_, entity: Model, resolveObj: () -> ())
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


UniversalEntity.InitAttackTables = function(_, self: table)
    self.Anims = {}
    self.AttackFuncs = {}
    self.ComboAttackFuncs = {}
end


UniversalEntity.InitAttackTasks = function(_, self: table, resolveObj: () -> ())
    table.insert(self.Promises, Promise.try(function()
        while RunService.Stepped:Wait() do
            if UniversalEntity:CheckCombatState(self.Entity) == false then break end
        end

        resolveObj()
    end):catch(function(err)
        warn(tostring(err))
    end))


    local lastFunc = 0
    local lastFuncCount = 0

    while RunService.Stepped:Wait() do
        if UniversalEntity:CheckCombatState(self.Entity) == false then break end

        local rTarget = UniversalEntity:GetRandomTarget(self.Entity)
        local rFunc = math.random(1, #self.AttackFuncs)

        if rFunc ~= lastFunc then
            lastFuncCount = 0
        else
            lastFuncCount += 1
            if lastFuncCount >= 3 then
                rFunc = math.random(1, #self.AttackFuncs)

                local retry = 0
                while rFunc ~= lastFunc and retry <= 3 do
                    rFunc = math.random(1, #self.AttackFuncs)
                    if rFunc == lastFunc then
                        retry += 1
                    end
                    RunService.Stepped:Wait()
                end
            end
        end
        lastFunc = rFunc

        if not ServerLib:IsCharValid(rTarget) then continue end


        self.AttackFuncs[rFunc](rTarget)
        if #self.ComboAttackFuncs > 0 then
            RunService.Heartbeat:Wait()

            local rComboFunc = math.random(1, #self.ComboAttackFuncs)
            self.ComboAttackFuncs[rComboFunc](rTarget, rFunc, math.random(1, 2))
        end

        wait()
    end
end


--- combat related functions
UniversalEntity.GetTargets = function(_, entity: Model) : { Player }
    local players = {}
    for _, targetingSymbol: ObjectValue in entity.TargetingList:GetChildren() do
        table.insert(players, Players:GetPlayerFromCharacter(targetingSymbol.Value))
    end

    return players
end


UniversalEntity.GetNearbyPlayers = function(_, entity: Model) : { Player }
    local nearbyChars = _getCharsByRadius(entity.PrimaryPart.Position, 486)
    local players = {}

    for _, char: Model in nearbyChars do
        table.insert(players, Players:GetPlayerFromCharacter(char))
    end

    return players
end


UniversalEntity.EditProjectileList = function(_, projectileUniqueId: string, projectilePos: Vector3 | CFrame, entity: Model)
    if typeof(projectilePos) == "CFrame" then
        projectilePos = projectilePos.Position
    end

    local projectileSymbol = Instance.new("Vector3Value")
    projectileSymbol.Name = projectileUniqueId
    projectileSymbol.Value = projectilePos
    projectileSymbol:SetAttribute("Damage", entity:GetAttribute("DMG"))
    projectileSymbol:SetAttribute("Level", entity:GetAttribute("Level"))
    projectileSymbol.Parent = ServerStorage.ProjectileSymbolContainer

    Debris:AddItem(projectileSymbol, 15.99 * 2)
end


UniversalEntity.CheckCombatState = function(_, entity: Model) : (boolean, string)
    if #entity.TargetingList:GetChildren() <= 0 then
        return false, "NoTarget"
    end
    if not ServerLib:IsCharValid(entity) then
        return false, "Dead"
    end

    return true, "Combating"
end


UniversalEntity.GetRandomTarget = function(_, entity: Model) : Model
    local targetingList = entity.TargetingList:GetChildren()
    local rIndex = math.random(1, #targetingList)

    return targetingList[rIndex].Value or nil
end


UniversalEntity.DeadTask = function(_, self: table)
    self.Died = true
    self.Empty()

    self = nil
end


return UniversalEntity
