
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")



local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local FormulaBook = require(ReplicatedStorage.HarukaShared.Library.FormulaBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local PathCreator = require(ServerScriptService.HarukaServer.Shared.PathCreator)
local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)
local DoTLib = require(ServerScriptService.HarukaServer.Services.DoTLib)
local EntityAttackLib = require(ServerScriptService.HarukaServer.Library.EntityAttackLib)

local EntityBook = require(ReplicatedStorage.HarukaShared.Library.EntityBook)
local EntityTemplate = require(ServerScriptService.HarukaServer.Library.EntityTemplate)




type EntityLibClass = {
    __index: EntityLibClass,

    new: (locator: BasePart) -> EntityLibClass,

    Destroy: (self: EntityLibClass) -> nil,
    Init: (self: EntityLibClass) -> nil,
    EntityInit: (self: EntityLibClass) -> nil,
    EntityDestroy: (self: EntityLibClass) -> nil,

    _SpawnModel: (self: EntityLibClass) -> nil,
    _ListenStatsTracker: (self: EntityLibClass) -> nil,
    _RoamTask: (self: EntityLibClass) -> nil,
    _ErrorAndRespawn: (self: EntityLibClass, step: number) -> nil,
    _EnterCombat: (self: EntityLibClass, target: Model, combatMode: string?) -> nil,
    _ClearEffectListTask: (self: EntityLibClass) -> nil,
    _CombatEnd: (self: EntityLibClass) -> nil,


    Locator: BasePart,
    LocatorUniqueId: string,

    WholeAdd: <T>(item: T) -> T,
    RoamAdd: <T>(item: T) -> T,
    Add: <T>(item: T) -> T,
    WholeEmpty: () -> nil,
    RoamEmpty: () -> nil,
    Empty: () -> nil,

    UniqueId: string,
    Entity: Model,
    BoundingSize: number,
    NearestChar: Model?,


    EntityObj: EntityAttackLib.EntityAttackLib,

    CombatInfo: {
        CombatStarterUniqueId: string,
        CombatTriggererUniqueId: string?,

        IsInCombat: boolean,
        CombatLocation: CFrame,

        EnteringCombat_Ready: boolean,
        IsDead: boolean
    },


    EntityDestroyed: boolean,
    Destroyed: boolean,
}




local EntityLib = {} :: EntityLibClass
EntityLib.__index = EntityLib




local PATH_COSTS = {
    Grass = 0,
    Plastic = 0,
    SmoothPlastic = 0,

    Slate = 10,
    Wood = 10,
    WoodPlanks = 10,
    DangerZone = math.huge
}


local allEntityPool = {}

local wait = task.wait


local _, borderSize = ReplicatedStorage.Packages.Unloads.EncounterBorder:GetBoundingBox()
borderSize = borderSize.X

--// Helper functions

local function _getCharsByRadius(pos: Vector3, radius: number)
    local charList = {}
    local chars = CollectionService:GetTagged("PlayerCharEntity") :: { Model }

    for _, char in chars do
        if not ServerLib.IsCharValid(char) then continue end
        if not char:GetAttribute("Haruka_CriRPGServerInited") then continue end

        if (char.PrimaryPart.Position - pos).Magnitude < radius then
            table.insert(charList, char)
        end
    end

    return charList
end


--// Init once
local entityContainer = Instance.new("Folder")
entityContainer.Name = "Entities"
entityContainer.Parent = workspace



--// Init once
local enemyDiedSignal = Signal.new()
local enterCombatSignal = Signal.new()
local joinCombatSignal = Signal.new()
local destroyEntityObjSignal = Signal.new()

enterCombatSignal:Connect(function(entity: Model, target: Model, combatMode: string)
    if not ServerLib.IsCharValid(entity) then return end
    if entity:GetAttribute("IsInCombat") then return end
    if entity:GetAttribute("EnteringCombat") then return end

    local clock = entity:GetAttribute("SpawnClock") :: number
    if DateTime.now().UnixTimestamp - clock <= 1 then return end


    if not ServerLib.IsCharValid(target) then return end
    if target:GetAttribute("IsInCombat") then return end


    for _, entityObj in allEntityPool do
        if entityObj.Entity == entity then
            entityObj:_EnterCombat(target, combatMode)
            break
        end
    end
end)
joinCombatSignal:Connect(function(entity: Model, target: Model)
    if not ServerLib.IsCharValid(entity) then return end
    if entity:GetAttribute("IsInCombat") then return end
    if entity:GetAttribute("EnteringCombat") then return end

    local clock = entity:GetAttribute("SpawnClock") :: number
    if DateTime.now().UnixTimestamp - clock < 1 then return end

    if not ServerLib.IsCharValid(target) then return end

    for _, entityObj in allEntityPool do
        if entityObj.Entity == entity then
            entityObj:_EnterCombat(target)
            break
        end
    end
end)
destroyEntityObjSignal:Connect(function(uniqueId: string)
    if uniqueId == nil then return end


    local entityObj = allEntityPool[uniqueId]
    if entityObj then
        Promise.delay(1.599):andThenCall(entityObj.EntityDestroy, entityObj)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    for _, entityObj in allEntityPool do
        pcall(function()
            local targetingList = entityObj.Entity.TargetingList
            for _, targetObj: ObjectValue in targetingList:GetChildren() do
                if targetObj.Name == player.Name then
                    targetObj:Destroy()
                    continue
                end
            end
        end)
    end
end)
enemyDiedSignal:Connect(function(uniqueId: string)
    local entityObj = allEntityPool[uniqueId]
    if not entityObj then
        warn("Error finding entity object when respawning enemy")
        return
    end

    allEntityPool[uniqueId] = nil


    local respawnTime = 12
    if workspace:GetAttribute("AbyssId") then
        respawnTime = 1
    end

    Promise.delay(respawnTime):andThen(function()
        entityObj:EntityInit()
    end)

    local countdown = ReplicatedStorage.Packages.Effects.RespawnTimer:Clone() :: BasePart
    countdown.Transparency = 1
    countdown.CFrame = entityObj.Locator.CFrame
    countdown.Parent = workspace.MapComponents
    Debris:AddItem(countdown, respawnTime)

    Promise.try(function()
        for i = respawnTime, 1, -1 do
            if countdown == nil then break end

            countdown.BillboardGui.TextLabel.Text = tostring(i)
            wait(1)
        end
    end):catch(function() end)
end)
Events.StartCombat_C.SetCallback(function(plr: Player, data)
    local entity = data.Entity
    local combatMode = data.CombatMode
    if not combatMode then return end


    if not ServerLib.IsCharValid(entity) then return end

    local char = plr.Character
    if not ServerLib.IsCharValid(char) then return end

    enterCombatSignal:Fire(entity, char, combatMode)
end)
ServerBindables.PlayerDied:Connect(function(charId: string)
    for _, entityObj in allEntityPool do
        pcall(function()
            local targetingList = entityObj.Entity.TargetingList

            for _, targetObj: ObjectValue in targetingList:GetChildren() do
                if targetObj.Name == charId then
                    targetObj:Destroy()
                end
            end
        end)
    end
end)


local function _enemyVariant(locator: BasePart)
    if locator:GetAttribute("NoRandomName") then return end

    for _, variantTable in AssetBook.EnemyVariants do
        if table.find(variantTable, locator.Name) then
            locator.Name = variantTable[math.random(1, #variantTable)]
            break
        end
    end
end





function EntityLib.new(locator: BasePart)
    if locator:GetAttribute("HarukaUniqueId") then return end

    local self = setmetatable({}, EntityLib)

    self.Locator = locator
    self.LocatorUniqueId = HttpService:GenerateGUID(false)

    locator:SetAttribute("HarukaUniqueId", self.LocatorUniqueId)


    self.WholeAdd, self.WholeEmpty = HarukaLib.Bin()
    self.RoamAdd, self.RoamEmpty = HarukaLib.Bin()
    self.Add, self.Empty = HarukaLib.Bin()

    self.WholeAdd(self.Locator)
    self.CombatInfo = {}

    return self
end


function EntityLib:Init()
    self.WholeAdd(self.Locator:GetPropertyChangedSignal("Parent"):Connect(function()
        local newParent = self.Locator
        if newParent then
            newParent = newParent.Parent
        end
        if newParent == nil then
            self:Destroy()
        end
    end))
    self:EntityInit()


    self.WholeAdd(HarukaLib:Hydrate(self.Locator, {
        ["Attr-_RESPAWN_SYMBOL"] = function(state: boolean)
            if state == nil then return end

            destroyEntityObjSignal:Fire(self.UniqueId)
        end
    }))
end


function EntityLib:EntityInit()
    self:_SpawnModel()
    self:_ListenStatsTracker()
    self:_RoamTask()

    self.Add(HarukaLib.Clock(5, function()
        local targetingList = self.Entity.TargetingList :: Folder

        for _, targetObj in targetingList:GetChildren() do
            if not ServerLib.IsCharValid(targetObj.Value) then
                targetObj:Destroy()
            end
        end
        for _, targetObj in targetingList:GetChildren() do
            if not targetObj.Value:GetAttribute("IsInCombat") then
                wait(1)
                if not targetObj.Value:GetAttribute("IsInCombat") then
                    targetObj:Destroy()
                end
            end
        end
    end, true))


    table.clear(self.CombatInfo)
    self.EntityDestroyed = false
end


function EntityLib:EntityDestroy()
    if self.Destroyed then return end
    if self.EntityDestroyed then return end

    self.EntityDestroyed = true


    local noRespawn = false
    if self.Locator then
        if self.Locator:GetAttribute("NoRespawn") then
            noRespawn = true
        end
    end
    if not noRespawn then
        enemyDiedSignal:Fire(self.UniqueId)
    end


    self.RoamEmpty()
    self.Empty()

    if self.EntityObj then
        self.EntityObj:Destroy()
        self.EntityObj = nil
    end

    if noRespawn then
        self:Destroy()
    end
end


function EntityLib:Destroy()
    if self.Destroyed then return end

    self.Destroyed = true

    self.RoamEmpty()
    self.Empty()
    self.WholeEmpty()

    allEntityPool[self.UniqueId] = nil
end


--// Private functions


function EntityLib:_SpawnModel()
    if ServerLib.IsModelValid(self.Entity) then return end

    _enemyVariant(self.Locator)


    local locator = self.Locator :: BasePart
	local enemyModel = ReplicatedStorage.Packages.EnemyModels:FindFirstChild(locator.Name, true) :: Model

	if not enemyModel then
		error("Model not found for entity: ".. locator.Name)
		return
	end

    local model = Instance.new("Model")
    model.Name = locator.Name

    local uniqueId = HttpService:GenerateGUID(false)
    model:SetAttribute("HarukaUniqueId", uniqueId)


    self.UniqueId = uniqueId

    local hrp = enemyModel.PrimaryPart:Clone() :: BasePart
    hrp.Color = Color3.new(1, 1, 1)
    hrp.Anchored = false
    hrp.CanCollide = true
    hrp.CanQuery = false
    hrp.CanTouch = false
    hrp.CastShadow = false
    hrp.EnableFluidForces = false
    hrp.Transparency = 1
    hrp.Massless = false
    hrp.Parent = model

    if hrp:FindFirstChildOfClass("Motor6D") then
        hrp:FindFirstChildOfClass("Motor6D"):Destroy()
    end

    local alignMoverAtt = Instance.new("Attachment")
    alignMoverAtt.Name = "AlignMoverAttachment"
    alignMoverAtt.Parent = hrp

    model.PrimaryPart = hrp
	model.PrimaryPart.CollisionGroup = "EnemyBodyPart"

    model:AddTag("EnemyEntity")
    model:SetAttribute("SpawnClock", DateTime.now().UnixTimestamp)


	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.BreakJointsOnDeath = false
	humanoid.UseJumpPower = true
	humanoid.Parent = model


    local enumState = {
        Enum.HumanoidStateType.Climbing,
        Enum.HumanoidStateType.Seated,
        Enum.HumanoidStateType.Swimming
    }
    for _, state: Enum.HumanoidStateType in enumState do
        humanoid:SetStateEnabled(state, false)
    end


    local locatorSymbol = Instance.new("ObjectValue")
    locatorSymbol.Name = "Locator"
    locatorSymbol.Value = locator
    locatorSymbol.Parent = model


	model:PivotTo(locator.CFrame * CFrame.Angles(0, math.rad(math.random(360)), 0))

    model:SetAttribute("MusicId", enemyModel:GetAttribute("MusicId"))

	model.Parent = entityContainer

	self.Entity = model
    self.BoundingSize = select(2, model:GetBoundingBox())

    self.Add(model)

    self.Add(self.Entity.Humanoid.HealthChanged:Connect(function(health: number)
		if health <= 0 then
            if self.CombatInfo.IsInCombat then
                return
            end
			self:EntityDestroy()
		end
	end))
	self.Add(self.Entity.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
        local newParent = self.Entity
        if newParent then
            if newParent.PrimaryPart == nil and newParent:FindFirstChild("Humanoid") then
                newParent.Humanoid.Health = -1
                return
            end
            if newParent.PrimaryPart == nil and not newParent:FindFirstChild("Humanoid") then
                self:EntityDestroy()
                return
            end
        else
            self:EntityDestroy()
        end
	end))


    allEntityPool[uniqueId] = self
end



function EntityLib:_ListenStatsTracker()
    local entity = self.Entity :: Model
    local entityInfo = EntityBook[entity.Name]


    for attr, val in table.clone(EntityTemplate) do
        if typeof(val) == "table" then
            local folder = Instance.new("Folder")
            folder.Name = attr
            folder.Parent = entity
            continue
        end
        if val == "_OBJECT" then
            local objVal = Instance.new("ObjectValue")
            objVal.Name = attr
            objVal.Value = nil
            objVal.Parent = entity
            continue
        end

        entity:SetAttribute(attr, val)
    end

    entity:SetAttribute("Level", self.Locator:GetAttribute("Level"))
    entity:SetAttribute("Tier", entityInfo.Tier)
    entity:SetAttribute("SpawnClock", DateTime.now().UnixTimestamp)
    entity:SetAttribute("IsBoss", entityInfo.IsBoss)

    entity:SetAttribute("CombatStartClock", DateTime.now().UnixTimestamp)

    local envirBonus = self.Locator:GetAttribute("EnvironmentBonus") or entityInfo.EnvironmentBonus
    entity:SetAttribute("EnvironmentBonus", envirBonus)

    local tier = self.Locator:GetAttribute("Tier") or entityInfo.Tier
    entity:SetAttribute("Tier", tier)

    if entityInfo.IsBoss then
        entity:AddTag("BossEnemyEntity")
    end


    local function _updateHealth()
        local healthBuff = entity:GetAttribute("MaxHealthEx") :: number
        local healthExBuff = entity:GetAttribute("MaxHealthExPower") :: number
        local targeting = entity:GetAttribute("TotalTargeting") :: number

        local isBoss = entity:GetAttribute("IsBoss") :: boolean


        local finalHealth = FormulaBook.EnemyHealthCurveCal({
            Level = entity:GetAttribute("Level"),
            IsBoss = isBoss,
            EnvironmentBonus = entity:GetAttribute("EnvironmentBonus"),
        })

        if isBoss then
            targeting = math.max(targeting, 1)

            finalHealth *= targeting
        end

        entity.Humanoid.MaxHealth = math.ceil(finalHealth * healthExBuff + healthBuff)

        if DateTime.now().UnixTimestamp - entity:GetAttribute("CombatStartClock") <= 2 then
            entity.Humanoid.Health = entity.Humanoid.MaxHealth
        end
        if entity.Humanoid.Health > entity.Humanoid.MaxHealth then
            entity.Humanoid.Health = entity.Humanoid.MaxHealth
        end
    end
    self.Add(HarukaLib:Hydrate(entity, {
        ["Attr-MaxHealthEx"] = _updateHealth,
        ["Attr-MaxHealthExPower"] = _updateHealth,
        ["Attr-TotalTargeting"] = _updateHealth,
        ["Attr-Level"] = _updateHealth,
        ["Attr-EnvironmentBonus"] = _updateHealth,
    }))



    local function _updateDMG()
        local ex = entity:GetAttribute("DMGEx") :: number
        local exPower = entity:GetAttribute("DMGExPower") :: number

        local finalDMG = FormulaBook.EnemyDMGCurveCal({
            Level = entity:GetAttribute("Level"),
            EnvironmentBonus = entity:GetAttribute("EnvironmentBonus"),
        })

        entity:SetAttribute("DMG", math.ceil(finalDMG * exPower + ex))
    end
    self.Add(HarukaLib:Hydrate(entity, {
        ["Attr-DMGEx"] = _updateDMG,
        ["Attr-DMGExPower"] = _updateDMG,
    }))



    entity.Humanoid.WalkSpeed = entityInfo.BaseSpeed
    entity.Humanoid.JumpPower = entityInfo.BaseJumpPower


    entity:SetAttribute("_EntityDataInited", true)
end



function EntityLib:_RoamTask()
    local locator = self.Locator :: BasePart
    local entity = self.Entity :: Model

    local path = nil
    if entity.Humanoid.WalkSpeed > 0 and not locator:GetAttribute("NoEnemyRoaming") then
        path = PathCreator.new(entity, {
            Costs = PATH_COSTS,
            AgentCanJump = false,
            AgentCanClimb = false,
            PathSettings = {
                SupportPartialPath = false
            }
        })
        path.Visualize = RunService:IsStudio()

        path.Events.Errored:Connect(function(errorType: string)
            if errorType == "AgentStuck" or errorType == "AgentUnreachable" then
                entity:PivotTo(locator.CFrame * CFrame.new(0, self.BoundingSize.Y / 2, 0) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0))
            end
        end)

        self.RoamAdd(function()
            path:Stop()
            path:Destroy()
        end)
    end

    self.NearestChar = nil


    --// roaming
    self.RoamAdd(task.spawn(function()
        if entity.Humanoid.WalkSpeed <= 0 then return end
        if locator:GetAttribute("NoEnemyRoaming") then return end

        local AREA_MAG = 15.99

        while wait(1.5 + math.random(10) / 10) do
            if not ServerLib.IsCharValid(entity) then break end
            if entity:GetAttribute("IsInCombat") then break end

            if self.NearestChar then continue end
            if self.CombatInfo.IsInCombat then break end
            if DateTime.now().UnixTimestamp - entity:GetAttribute("SpawnClock") <= 1 then continue end


            local success, err = pcall(function()
                local randomScatterPos = locator.CFrame.Position + Vector3.new(
                    math.random(-AREA_MAG, AREA_MAG),
                    0,
                    math.random(-AREA_MAG, AREA_MAG)
                )

                local isValid = false
                local repeatTimes = 0
                local rPos = ServerLib.FindGroundByRayForOrb(randomScatterPos)
                while repeatTimes <= 15 do
                    if isValid then break end

                    rPos = ServerLib.FindGroundByRayForOrb(randomScatterPos)

                    isValid = path:IsPathValid(rPos)
                    repeatTimes += 1
                end

                path:Stop()
                path:Run(rPos)
            end)
            if not success then warn(err) end


            RunService.Heartbeat:Wait()
        end
    end))

    --// tracking
    self.RoamAdd(task.spawn(function()
        if entity.Humanoid.WalkSpeed <= 0 then return end
        if locator:GetAttribute("NoEnemyRoaming") then return end

        while wait(0.07) do
            if not ServerLib.IsCharValid(entity) then break end


            if entity:GetAttribute("IsInCombat") then break end
            if self.CombatInfo.IsInCombat then break end
            if DateTime.now().UnixTimestamp - entity:GetAttribute("SpawnClock") <= 1 then continue end



            Promise.new(function(resolve)
                local curPos = entity.PrimaryPart.Position :: Vector3

                local nearestChars = _getCharsByRadius(curPos, 70)
                local nearestChar = nil
                local nearestDist = 999

                for _, char in nearestChars do
                    if not ServerLib.IsCharValid(char) then continue end

                    if char:GetAttribute("IsInCombat") then continue end
                    if char:FindFirstChild("CombatCooldown") then continue end


                    local mag = (char.PrimaryPart.Position - curPos).Magnitude

                    if mag > 0 and mag < nearestDist and ServerLib.IsCharValid(char) then
                        if path:IsPathValid(char.PrimaryPart.Position) then
                            nearestDist = mag
                            nearestChar = char
                        end
                    end
                end

                if nearestChar and ServerLib.IsCharValid(nearestChar) then
                    local targetPos = nearestChar.PrimaryPart.Position :: Vector3
                    if (targetPos - locator.CFrame.Position).Magnitude > 80 then
                        path:Run(locator.CFrame.Position)
                        resolve()
                        return
                    end

                    local lastNearestChar = self.NearestChar
                    if lastNearestChar == nil then
                        Events.PlayVFXStatusToEntity_S.FireList(ServerLib.GetNearbyPlayers(curPos), {
                            StatusId = "Found",
                            Entity = entity
                        })

                        ServerLib.PlayWorldSound(SoundService.SFXs.Found, curPos)
                    end

                    self.NearestChar = nearestChar:GetAttribute("HarukaUniqueId")
                    entity:SetAttribute("NearestChar", nearestChar.Name)

                    path:Run(targetPos)
                else
                    self.NearestChar = nil
                    entity:SetAttribute("NearestChar", nil)
                end

                resolve()
            end):catch(function(err)
                warn(tostring(err))
            end):await()
        end
    end))


    --// encountering
    self.RoamAdd(task.spawn(function()
        while wait(2) do
            if not ServerLib.IsCharValid(entity) then break end

            if entity:GetAttribute("IsInCombat") then break end
            if self.CombatInfo.IsInCombat then break end
            if DateTime.now().UnixTimestamp - entity:GetAttribute("SpawnClock") <= 1 then continue end

            Promise.new(function(resolve)
                local curPos = entity.PrimaryPart.Position :: Vector3

                local nearestChars = _getCharsByRadius(curPos, 20)
                local nearestChar = nil
                local nearestDist = 999

                for _, char in nearestChars do
                    if not ServerLib.IsCharValid(char) then continue end

                    if char:GetAttribute("IsInCombat") then continue end
                    if char:FindFirstChild("CombatCooldown") then continue end
                    if char:GetAttribute("IsClimbing") then continue end
                    if char:GetAttribute("IsSwimming") then continue end


                    local mag = (char.PrimaryPart.Position - curPos).Magnitude

                    if mag > 0 and mag < nearestDist and ServerLib.IsCharValid(char) then
                        nearestDist = mag
                        nearestChar = char
                    end
                end

                if nearestChar and ServerLib.IsCharValid(nearestChar) then
                    local player = Players:GetPlayerFromCharacter(nearestChar)
                    if not player then
                        resolve()
                        return
                    end

                    local criRPGSettings = player.CriRPGSettings :: Configuration
                    local combatMode = "Public"
                    if criRPGSettings:FindFirstChild("CombatMode") then
                        combatMode = criRPGSettings.CombatMode.Value
                    end

                    enterCombatSignal:Fire(entity, nearestChar, combatMode)
                end

                resolve()
            end):catch(function(err)
                warn(tostring(err))
            end):await()
        end
    end))
end


function EntityLib:_ErrorAndRespawn(step: number)
    warn("Error in entity: STEP "..tostring(step))

    destroyEntityObjSignal:Fire(self.UniqueId)
end


function EntityLib:_EnterCombat(target: Model, combatMode: string?)
    if self.CombatInfo.IsInCombat then return end
    self.CombatInfo.IsInCombat = true

    local entity = self.Entity :: Model

    self.RoamEmpty()

    entity:SetAttribute("EnteringCombat", true)
    RunService.Heartbeat:Wait()

    pcall(function()
        if self.EntityObj then
            self.EntityObj:Destroy()
            self.EntityObj = nil
        end
    end)
    self.EntityObj = EntityAttackLib[entity.Name].new(entity)


    local hasPosVal = true

    self.CombatInfo.CombatStarterUniqueId = target:GetAttribute("HarukaUniqueId")

    if self.CombatInfo.CombatTriggererUniqueId == nil then
        Promise.new(function(resolve)
            for _, thatEntityObj in allEntityPool do
                if thatEntityObj.UniqueId == self.UniqueId then continue end
                if not thatEntityObj.CombatInfo.IsInCombat then continue end
                if not thatEntityObj.CombatInfo.CombatTriggererUniqueId then continue end
                if thatEntityObj.CombatInfo.IsDead then continue end

                if thatEntityObj.CombatInfo.CombatTriggererUniqueId == self.CombatInfo.CombatStarterUniqueId then
                    resolve(true, thatEntityObj.CombatInfo.CombatLocation)
                end
            end

            resolve(false)

        end):andThen(function(state: boolean, location: CFrame?)
            if not state then
                hasPosVal = false

                self.CombatInfo.CombatTriggererUniqueId = self.CombatInfo.CombatStarterUniqueId
                self.CombatInfo.CombatLocation = CFrame.new(ServerLib.FindGroundByRayForCombatLocation(target.PrimaryPart.Position))
            else
                self.CombatInfo.CombatLocation = location
            end
        end):await()
    end

    local combatLocation = self.CombatInfo.CombatLocation :: CFrame
    entity:SetAttribute("CombatLocation", combatLocation)


    --// ready to fight
    entity.Humanoid.WalkSpeed = 0
    entity:PivotTo(combatLocation * CFrame.Angles(0, math.rad(math.random(360)), 0) + Vector3.yAxis * self.BoundingSize.Y)


    local encounterBorder: Model = nil
    local nearbyCount = 0
    local function _nearbyEnemyEnterCombat()
        for _, entityObj: EntityLibClass in allEntityPool do
            if nearbyCount >= 5 then break end

            local thatEntity = entityObj.Entity :: Model
            if not ServerLib.IsCharValid(thatEntity) then continue end

            if entityObj.CombatInfo.IsInCombat then continue end

            if (thatEntity.PrimaryPart.Position - combatLocation.Position).Magnitude <= 35 then
                joinCombatSignal:Fire(thatEntity, target)
                nearbyCount += 1
            end
        end
    end
    if not hasPosVal then
        encounterBorder = ReplicatedStorage.Packages.Unloads.EncounterBorder:Clone() :: Model
        encounterBorder:PivotTo(combatLocation)
        encounterBorder:SetAttribute("Owner", target.Name)
        encounterBorder:SetAttribute("CombatMode", combatMode)
        encounterBorder.Parent = workspace.MapComponents
        Debris:AddItem(encounterBorder, 5)


        if (target.PrimaryPart.Position - combatLocation.Position).Magnitude >= borderSize / 1.5 then
            target:PivotTo(combatLocation * CFrame.new(0, 6, 0))
        end

        _nearbyEnemyEnterCombat()
    else
        --// called from combat starter enemy
        Promise.new(function(resolve)
            for _, thatEntityObj in allEntityPool do --- force late enemies to wait
                if thatEntityObj.UniqueId == self.UniqueId then continue end
                if not thatEntityObj.CombatInfo.IsInCombat then continue end
                if not thatEntityObj.CombatInfo.CombatTriggererUniqueId then continue end
                if thatEntityObj.CombatInfo.IsDead then continue end

                if thatEntityObj.CombatInfo.CombatTriggererUniqueId == self.CombatInfo.CombatStarterUniqueId then
                    repeat wait() until thatEntityObj.CombatInfo.EnteringCombat_Ready
                    break
                end
            end

            resolve(true)

        end):timeout(5):catch(function(err)
            warn(tostring(err))

            self:_ErrorAndRespawn(7)
        end):await()
    end


    if not hasPosVal then
        local waitTime = 1.599

        if self.Entity:HasTag("BossEnemyEntity") then
            waitTime *= 2.599
        end
        if combatMode then
            if combatMode == "Solo" then
                waitTime = 1
            elseif combatMode == "Party" then
                waitTime = 2

                if self.Entity:HasTag("BossEnemyEntity") then
                    waitTime *= 2.599
                end
            end
        end
        wait(waitTime)
    end
    if encounterBorder then encounterBorder:Destroy() end


    --- check again!
    if not ServerLib.IsCharValid(target) then self:_ErrorAndRespawn(1) return end


    target = nil

    for _, char: Model in CollectionService:GetTagged("PlayerCharEntity") do
        if char:GetAttribute("HarukaUniqueId") == self.CombatInfo.CombatStarterUniqueId then
            target = char
            break
        end
    end
    if not ServerLib.IsCharValid(target) then self:_ErrorAndRespawn(2) return end


    --// we will check starter enemy
    if hasPosVal then
        Promise.new(function(resolve)
            for _, thatEntityObj in allEntityPool do
                if thatEntityObj.UniqueId == self.UniqueId then continue end
                if not thatEntityObj.CombatInfo.IsInCombat then continue end
                if not thatEntityObj.CombatInfo.CombatTriggererUniqueId then continue end
                if thatEntityObj.CombatInfo.IsDead then continue end

                if thatEntityObj.CombatInfo.CombatTriggererUniqueId == self.CombatInfo.CombatStarterUniqueId then
                    resolve(ServerLib.IsCharValid(thatEntityObj.Entity))
                    break
                end
            end
            resolve(false)

        end):andThen(function(state)
            if not state then self:_ErrorAndRespawn(3) return end

        end):catch(function(err)
            warn(tostring(err))

            self:_ErrorAndRespawn(0)
        end)
    end


    --// finally!
    local rLocation = ServerLib.FindGroundByRayForOrb(combatLocation.Position
        + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15)))

    entity:PivotTo(CFrame.new(rLocation) * CFrame.new(0, self.BoundingSize.Y / 2, 0) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0))
    entity:AddTag("EnemyEntity_Combat")

    self.CombatInfo.EnteringCombat_Ready = true


    --- make players into combat
    local nearbyCharCount = 1
    local function _addAndSetTargetingEnemy(char: Model)
        local targetSymbol = Instance.new("ObjectValue")
        targetSymbol.Name = entity.Name
        targetSymbol.Value = entity
        targetSymbol.Parent = char.TargetingList

        if not char.TargetingEnemy.Value then
            char.TargetingEnemy.Value = entity
        end
    end
    local function _addInCombat(char: Model, withoutSettingAttr: boolean?)
        _addAndSetTargetingEnemy(char)

        if not withoutSettingAttr then
            char:SetAttribute("CombatLocation", combatLocation)
            char:SetAttribute("CombatStartClock", DateTime.now().UnixTimestamp)
            char:SetAttribute("IsInCombat", true)
        end

        local targetSymbol = Instance.new("ObjectValue")
        targetSymbol.Name = char.Name
        targetSymbol.Value = char
        targetSymbol.Parent = entity.TargetingList
    end
    if not hasPosVal then
        --// combat starter enemy
        _addInCombat(target)

        if combatMode then
            if combatMode == "Public" then
                for _, nearbyChar: Model in _getCharsByRadius(combatLocation.Position, borderSize / 1.5) do
                    if nearbyChar.Name == target.Name then continue end
                    if not ServerLib.IsCharValid(nearbyChar) then continue end

                    if nearbyChar:GetAttribute("IsInCombat") then continue end
                    if nearbyChar:FindFirstChild("CombatCooldown") then continue end

                    nearbyCharCount += 1
                    _addInCombat(nearbyChar)
                end

            elseif combatMode == "Party" then
                local partyContainer = workspace.MapComponents.PartyHolder:FindFirstChild(target.Name, true) :: Instance?

                if partyContainer then
                    if partyContainer:IsA("ObjectValue") then
                        partyContainer = partyContainer.Parent
                    end
                end
                if partyContainer then
                    for _, nearbyChar: Model in _getCharsByRadius(combatLocation.Position, borderSize / 1.5) do
                        if nearbyChar.Name == target.Name then continue end
                        if not ServerLib.IsCharValid(nearbyChar) then continue end
                        if not partyContainer:FindFirstChild(nearbyChar.Name) then continue end

                        if nearbyChar:GetAttribute("IsInCombat") then continue end
                        if nearbyChar:FindFirstChild("CombatCooldown") then continue end

                        nearbyCharCount += 1
                        _addInCombat(nearbyChar)
                    end
                end
            end
        end
    else
        --// got pulled by combat starter enemy
        nearbyCharCount = 0

        for _, thatEntityObj in allEntityPool do
            if thatEntityObj.UniqueId == self.UniqueId then continue end
            if not thatEntityObj.CombatInfo.IsInCombat then continue end
            if not thatEntityObj.CombatInfo.CombatTriggererUniqueId then continue end
            if thatEntityObj.CombatInfo.IsDead then continue end

            if thatEntityObj.CombatInfo.CombatTriggererUniqueId == self.CombatInfo.CombatStarterUniqueId then
                for _, thatEntitySymbol in thatEntityObj.Entity.TargetingList:GetChildren() do
                    if not ServerLib.IsCharValid(thatEntitySymbol.Value) then continue end

                    local char = thatEntitySymbol.Value :: Model
                    _addInCombat(char, true)

                    nearbyCharCount += 1
                end
            end
        end
    end

    entity:SetAttribute("CombatStartClock", DateTime.now().UnixTimestamp)
    entity:SetAttribute("TotalTargeting", nearbyCharCount)


    --// do attack tasks
    RunService.Heartbeat:Wait()

    wait(0.5)
    entity:SetAttribute("EnteredCombat", true)
    entity:SetAttribute("IsInCombat", true)


    Promise.new(function(resolve)
        self.EntityObj:DoAttackTasks(resolve)

    end):timeout(60 * 10):catch(function(err)
        local players = {}
        for _, thatCharSymbol: ObjectValue in entity.TargetingList:GetChildren() do
            table.insert(players, Players:GetPlayerFromCharacter(thatCharSymbol.Value))
        end

        if Promise.Error.isKind(err, Promise.Error.Kind.TimedOut) then
            Events.CreateNotify_S.FireList(players, "Combat Timeout!")

            warn("Combat Timeout, unknown reason unconfirmed")
        else
            Events.CreateNotify_S.FireList(players, "An error occurred during combat! We're sorry!")

            warn(tostring(err))
        end
    end):await()


    RunService.Heartbeat:Wait()

    self:_CombatEnd()
end



function EntityLib:_ClearEffectListTask()
    for _, effectTask in DoTLib.GetEffectsByTarget(self.Entity) do
        effectTask:Cancel()
    end
end


function EntityLib:_CombatEnd()
    if self.CombatInfo.IsDead then return end
    if not self.CombatInfo.IsInCombat then return end

    self.CombatInfo.IsDead = true
    self.Entity:SetAttribute("IsDead", true)

    pcall(self._ClearEffectListTask, self)

    local entity = self.Entity :: Model

    if not entity then self:_ErrorAndRespawn(4) return end
    if not entity.Parent then self:_ErrorAndRespawn(4) return end


    --- search for nearby entities, if there are any, will have to wait for them to die
    local foundTeamUpEnemies = false

    Promise.new(function(resolve)
        local check = false

        for _, thatEntityObj: EntityLibClass in allEntityPool do
            if thatEntityObj.UniqueId == self.UniqueId then continue end
            if not thatEntityObj.CombatInfo.IsInCombat then continue end
            if not thatEntityObj.CombatInfo.CombatStarterUniqueId then continue end
            if thatEntityObj.CombatInfo.IsDead then continue end

            if thatEntityObj.CombatInfo.CombatStarterUniqueId == self.CombatInfo.CombatStarterUniqueId then
                local thatEntity = thatEntityObj.Entity :: Model

                local alreadyAdded = thatEntity.TeamUpEnemies:FindFirstChild(self.UniqueId) ~= nil
                if not alreadyAdded then
                    local teamUpEntitySymbol = Instance.new("ObjectValue")
                    teamUpEntitySymbol.Name = self.UniqueId
                    teamUpEntitySymbol.Value = self.Locator

                    teamUpEntitySymbol:SetAttribute("Level", entity:GetAttribute("Level"))

                    teamUpEntitySymbol.Parent = thatEntity.TeamUpEnemies
                end

                check = true
            end
        end

        foundTeamUpEnemies = check

        resolve(check)
    end):await()


    --// respawn team enemies
    Promise.new(function(resolve)
        if not foundTeamUpEnemies then
            destroyEntityObjSignal:Fire(self.UniqueId)

            for _, teamUpEntitySymbol in entity.TeamUpEnemies:GetChildren() do
                destroyEntityObjSignal:Fire(teamUpEntitySymbol.Name)
            end
        end

        resolve(true)

    end):catch(function(err)
        destroyEntityObjSignal:Fire(self.UniqueId)

        warn(tostring(err))
    end):await()


    local function _giveLoot(drops: { [string]: number }, char: Model)
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr then return end

        local result, _, _ = HarukaLib:RollLoot(drops)

        if not ServerLib.IsModelValid(entity) then
            ServerLib.PlaceItemDropPart(plr, result, 1, self.Locator.Position, true)
        else
            ServerLib.PlaceItemDropPart(plr, result, 1, entity.PrimaryPart.Position, false)
        end
    end
    local function _giveBadge(entityInfo: EntityBook.EntityJSON, char: Model)
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr then return end

        if entityInfo.BadgeId then
            ServerLib.GiveBadge(entityInfo.BadgeId, plr)
        end
    end


    local abyssId = workspace:GetAttribute("AbyssId")
    local dungeonId = workspace:GetAttribute("DungeonId")
    local isSPWorldType = abyssId ~= nil or dungeonId ~= nil


    --// give loots
    Promise.new(function(resolve)
        --// check if entity is dead, if no, then means player failed
        local isEnemyDeadCheck = false
        if entity.Humanoid.Health <= 0 then
            isEnemyDeadCheck = true
        end

        --// FIX: there was a bug if enemy fall into void it would die
        if not ServerLib.IsModelValid(entity) then
            isEnemyDeadCheck = false
        end

        for _, charSymbol: ObjectValue in entity.TargetingList:GetChildren() do
            local thatChar = charSymbol.Value :: Model

            if not ServerLib.IsCharValid(thatChar) then continue end


            local charTargetingList = thatChar.TargetingList :: Folder
            for _, targetingSymbol in charTargetingList:GetChildren() do
                if not ServerLib.IsCharValid(targetingSymbol.Value) then
                    targetingSymbol:Destroy()
                    continue
                end
                if targetingSymbol.Value == entity then
                    targetingSymbol:Destroy()
                    continue
                end
            end

            --// check if player has done all the targets
            if #charTargetingList:GetChildren() <= 0 then
                thatChar.PlayerCombatEnded:Fire(thatChar.Name)
            else
                --- get the first target again
                thatChar.TargetingEnemy.Value = charTargetingList:FindFirstChildOfClass("ObjectValue").Value
            end


            --- give loots and badges, combat won!
            local success, err = pcall(function()
                if not foundTeamUpEnemies and isEnemyDeadCheck then
                    if isSPWorldType then
                        self.Locator:SetAttribute("NoRespawn", true)
                    end

                    local entityInfo = EntityBook[entity.Name]

                    _giveLoot(entityInfo.Drops, thatChar)
                    _giveBadge(entityInfo, thatChar)

                    for _, diedEntitySymbol in entity.TeamUpEnemies:GetChildren() do
                        local diedEntityInfo = EntityBook[diedEntitySymbol.Value.Name]

                        if isSPWorldType then
                            diedEntitySymbol.Value:SetAttribute("NoRespawn", true)
                        end

                        _giveLoot(diedEntityInfo.Drops, thatChar)
                        _giveBadge(diedEntityInfo, thatChar)
                    end

                    --// give exp
                    local totalEXP = 0
                    totalEXP += FormulaBook.EnemyEXPCurveCal({
                        Level = entity:GetAttribute("Level"),
                    })

                    for _, diedEntitySymbol: ObjectValue in entity.TeamUpEnemies:GetChildren() do
                        totalEXP += FormulaBook.EnemyEXPCurveCal({
                            Level = diedEntitySymbol:GetAttribute("Level"),
                        })
                    end


                    --// give gold
                    local totalGold = 0
                    totalGold += FormulaBook.EnemyGoldCurveCal({
                        Level = entity:GetAttribute("Level"),
                    })

                    for _, diedEntitySymbol: ObjectValue in entity.TeamUpEnemies:GetChildren() do
                        totalGold += FormulaBook.EnemyGoldCurveCal({
                            Level = diedEntitySymbol:GetAttribute("Level"),
                        })
                    end


                    local plr = Players:GetPlayerFromCharacter(thatChar)
                    if plr then
                        ServerLib.GiveEXPRewards(plr, math.floor(totalEXP))

                        HarukaLib:AddAttr(plr, "Gold", math.floor(totalGold))
                        ServerLib.ShowText(thatChar, `+{totalGold} GOLD`, Color3.fromHex('#ffeaa7'))

                        HarukaLib:AddAttr(plr, "CombatWonTimes", 1)
                    end
                end
            end)
            if not success then warn(err) end
        end

        resolve(true)
    end):await()
end



local function initLocator(locator: BasePart)
    if not locator:IsA("BasePart") then return end
    if locator.Parent:IsA("BasePart") then return end


    locator.Transparency = 1


    local entityObj = EntityLib.new(locator)
    if entityObj then
        entityObj:Init()
    end
end
for _, locator: BasePart in CollectionService:GetTagged("EnemyLocatorEntity") do
    Promise.try(initLocator, locator)
end
CollectionService:GetInstanceAddedSignal("EnemyLocatorEntity"):Connect(initLocator)