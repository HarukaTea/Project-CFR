
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")


local EntityLib = {}
EntityLib.__index = EntityLib


local FormulaBook = require(ReplicatedStorage.HarukaShared.Library.FormulaBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local HarukaPathCreator = require(ServerScriptService.HarukaServer.Shared.HarukaPathCreator)
local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)

local EntityBook = require(ReplicatedStorage.HarukaShared.Library.EntityBook)
local EntityTemplate = require(ServerScriptService.HarukaServer.Library.EntityTemplate)
local EntityStatLimitTemplate = require(ServerScriptService.HarukaServer.Library.EntityLimitTemplate)


local allEntityPool = {}

local wait = task.wait


local _, borderSize = ReplicatedStorage.Packages.Unloads.EncounterBorder:GetBoundingBox()
borderSize = borderSize.X

--// Helper functions

local function _getCharsByRadius(pos: Vector3, radius: number)
    local charList = {}

    for _, char: Model in CollectionService:GetTagged("PlayerCharEntity") do
        if not ServerLib:IsCharValid(char) then continue end
        if not char:GetAttribute("_CharDataInited") then continue end

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

local entityStorageContainer = Instance.new("Folder")
entityStorageContainer.Name = "EntityStorage"
entityStorageContainer.Parent = game:GetService("TestService")


--// Init once
local enemyDiedSignal = Signal.new()
local enterCombatSignal = Signal.new()
local destroyEntityObjSignal = Signal.new()

enterCombatSignal:Connect(function(entity: Model, target: Model)
    if not ServerLib:IsCharValid(entity) then return end
    if entity:GetAttribute("IsInCombat") then return end
    if entity:GetAttribute("EnteringCombat") then return end
    if not entity:GetAttribute("IsReady") then return end


    if not ServerLib:IsCharValid(target) then return end
    if target:GetAttribute("IsInCombat") then return end
    if target:GetAttribute("EnteringCombat") then return end


    for _, entityObj in allEntityPool do
        if entityObj.Entity == entity then
            entityObj:_EnterCombat(target)
            break
        end
    end
end)
destroyEntityObjSignal:Connect(function(uniqueId: string)
    local entityObj = allEntityPool[uniqueId]
    if entityObj then
        Promise.delay(1.599):andThenCall(entityObj.Destroy, entityObj)
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
enemyDiedSignal:Connect(function(locator: BasePart)
    local countdown = ReplicatedStorage.Packages.Effects.RespawnTimer:Clone() :: BasePart
    countdown.Transparency = 1
    countdown.CFrame = locator.CFrame
    countdown.Parent = workspace

    Promise.try(function()
        for i = 12, 1, -1 do
            if countdown == nil then break end

            countdown.BillboardGui.TextLabel.Text = tostring(i)
            wait(1)
        end
    end):catch(function() end)

    Promise.delay(12):andThen(function()
        locator.Parent = workspace.Enemies
    end)

    Debris:AddItem(countdown, 12)
end)
Events.RequestToStartCombat.SetCallback(function(plr: Player, data)
    local entity = data.Entity
    if not ServerLib:IsCharValid(entity) then return end

    local char = plr.Character
    if not ServerLib:IsCharValid(char) then return end

    enterCombatSignal:Fire(entity, char)
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





function EntityLib.new(locator: BasePart)
    local self = setmetatable({}, EntityLib)

    self.Locator = locator

    self.WholeAdd, self.WholeEmpty = HarukaLib.Bin()
    self.RoamAdd, self.RoamEmpty = HarukaLib.Bin()
    self.Add, self.Empty = HarukaLib.Bin()

    self.WholeAdd(self.Locator)

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


    self:_SpawnModel()
    self:_ListenStatsTracker()
    self:_ListenStatLimitTracker()

    self:_RoamTask()

    self.IsReady = true

    self.WholeAdd(HarukaLib.Clock(5, function()
        local targetingList = self.Entity.TargetingList

        for _, targetObj: ObjectValue in targetingList:GetChildren() do
            if not ServerLib:IsCharValid(targetObj.Value) then
                targetObj:Destroy()
                continue
            end
        end
    end))

    Promise.delay(1):andThen(function()
        self.Entity:SetAttribute("IsReady", true)
    end)
end


function EntityLib:Destroy(noRespawn: boolean?)
    if self.Destroyed then return end

    self.Destroyed = true
    allEntityPool[self.UniqueId] = nil

    if self.Locator then
        if self.Locator:GetAttribute("NoRespawn") then
            noRespawn = true
        end
    end
    if not noRespawn then
        enemyDiedSignal:Fire(self.Locator:Clone())
    end
    if self.EntityObj then
        self.EntityObj:Destroy()
    end

    self.Empty()
    self.RoamEmpty()
    self.WholeEmpty()
end


--// Private functions


function EntityLib:_SpawnModel()
    if self.HasModel then return end


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
    model:SetAttribute("IsLeader", locator:GetAttribute("IsLeader"))


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


	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.BreakJointsOnDeath = false
	humanoid.UseJumpPower = true
	humanoid.Parent = model


    local enumState = {
        Enum.HumanoidStateType.StrafingNoPhysics,
        Enum.HumanoidStateType.RunningNoPhysics,
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

    self.HasModel = true

    self.Add(model)

    self.Add(self.Entity.Humanoid.HealthChanged:Connect(function(health: number)
		if health <= 0 then
            if self.IsInCombat then
                return
            end
			self:Destroy()
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
                self:Destroy()
                return
            end
        else
            self:Destroy()
        end
	end))

    allEntityPool[uniqueId] = self
end



function EntityLib:_ListenStatsTracker()
    local entity = self.Entity :: Model
    local entityInfo = EntityBook[entity.Name]


    for attr: string, val: any in table.clone(EntityTemplate) do
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
    entity:SetAttribute("BaseMaxHealth", entityInfo.BaseHealth)
    entity:SetAttribute("BaseDMG", entityInfo.BaseDMG)
    entity:SetAttribute("IsBoss", entityInfo.IsBoss)

    entity:SetAttribute("CombatStartClock", DateTime.now().UnixTimestamp)

    local envirBonus = self.Locator:GetAttribute("EnvironmentBonus") or entityInfo.EnvironmentBonus
    entity:SetAttribute("EnvironmentBonus", envirBonus)

    local tier = self.Locator:GetAttribute("Tier") or entityInfo.Tier
    entity:SetAttribute("Tier", tier)


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

        if DateTime.now().UnixTimestamp - entity:GetAttribute("CombatStartClock") <= 5 then
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


function EntityLib:_ListenStatLimitTracker()
    local entity = self.Entity :: Model

    local totalBin = {}


    local function __trackWhichStat(statAttr: string)
        local attr = string.sub(statAttr, 5)
        if entity:GetAttribute(statAttr) == nil then
            warn("Invalid base stat: "..statAttr)
            return
        end
        if EntityStatLimitTemplate[attr.."Min"] == nil or EntityStatLimitTemplate[attr.."Max"] == nil then
            warn("Invalid limit stat: "..attr)
            return
        end

        local function __track()
            local base = entity:GetAttribute(statAttr) :: any
            local limitMin = EntityStatLimitTemplate[attr.."Min"] :: number
            local limitMax = EntityStatLimitTemplate[attr.."Max"] :: number


            if base < limitMin then
                entity:SetAttribute(statAttr, limitMin)
            end
            if base > limitMax then
                entity:SetAttribute(statAttr, limitMax)
            end
        end
        totalBin["Attr-"..statAttr] = __track
    end


    local blackList = {}
    for attr: string, _ in entity:GetAttributes() do
        if table.find(blackList, attr) then continue end
        if string.find(attr, "Base") then
            __trackWhichStat(attr)
        end
    end

    self.Add(HarukaLib:Hydrate(entity, totalBin))
end




function EntityLib:_RoamTask()
    local locator = self.Locator :: BasePart
    local entity = self.Entity :: Model

    local path, pathForDetecting = nil, nil
    if entity.Humanoid.WalkSpeed > 0 then
        local costs = {
            Grass = 0,
            Plastic = 0,
            SmoothPlastic = 0,

            Slate = 10,
            Wood = 10,
            WoodPlanks = 10,
            DangerZone = math.huge
        }


        local canJump = false
        if entity.Humanoid.JumpPower <= 0 then
            canJump = false
        end

        path = HarukaPathCreator.new(entity, {
            Costs = costs,
            AgentCanJump = canJump,
            AgentCanClimb = false,
            PathSettings = {
                SupportPartialPath = true
            }
        })
        pathForDetecting = HarukaPathCreator.new(entity, {
            Costs = costs,
            AgentCanJump = canJump,
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
        self.RoamAdd(function()
            path:Stop()
            pathForDetecting:Destroy()
        end)
    end



    --// roaming
    self.RoamAdd(task.spawn(function()
        if entity.Humanoid.WalkSpeed <= 0 then return end

        local AREA_MAG = 15.99

        while wait(1.5 + math.random(10) / 10) do
            if not ServerLib:IsCharValid(entity) then break end
            if entity:GetAttribute("IsInCombat") then break end

            if self.NearestChar then continue end


            local success, err = pcall(function()
                local randomScatterPos = locator.CFrame.Position + Vector3.new(
                    math.random(-AREA_MAG, AREA_MAG),
                    0,
                    math.random(-AREA_MAG, AREA_MAG)
                )

                local isValid = false
                local repeatTimes = 0
                local rPos = ServerLib:FindGroundByRayForOrb(randomScatterPos)
                while repeatTimes <= 15 do
                    if isValid then break end

                    rPos = ServerLib:FindGroundByRayForOrb(randomScatterPos)

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


        while wait(0.07) do
            if not ServerLib:IsCharValid(entity) then break end


            if entity:GetAttribute("IsInCombat") then break end


            Promise.new(function(resolve)
                local curPos = entity.PrimaryPart.Position :: Vector3

                local nearestChars = _getCharsByRadius(curPos, 60)
                local nearestChar = nil
                local nearestDist = 999

                for _, char: Model in nearestChars do
                    if not ServerLib:IsCharValid(char) then continue end
                    if char:GetAttribute("IsInCombat") then continue end
                    if char:GetAttribute("EnteringCombat") then continue end
                    if char:FindFirstChild("CombatCooldown") then continue end


                    local mag = (char.PrimaryPart.Position - curPos).Magnitude

                    if mag > 0 and mag < nearestDist then
                        if pathForDetecting:IsPathValid(char.PrimaryPart.Position) then
                            nearestDist = mag
                            nearestChar = char
                        end
                    end
                end

                if nearestChar and ServerLib:IsCharValid(nearestChar) then
                    local targetPos = nearestChar.PrimaryPart.Position :: Vector3
                    if (targetPos - locator.CFrame.Position).Magnitude > 70 then
                        path:Run(locator.CFrame.Position)
                        resolve()
                        return
                    end

                    local lastNearestChar = self.NearestChar
                    if lastNearestChar == nil then
                        Events.ApplyFoundStatusToEnemy.FireList(ServerLib:GetNearbyPlayers(curPos), {
                            Enemy = entity
                        })

                        ServerLib:PlayWorldSound(SoundService.SFXs.Found, curPos)
                    end
                    self.NearestChar = nearestChar

                    path:Run(targetPos)
                else
                    self.NearestChar = nil
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


function EntityLib:_EnterCombat(target: Model)
    if self.IsInCombat then return end
    self.IsInCombat = true

    local entity = self.Entity :: Model

    self.RoamEmpty()

    entity:SetAttribute("EnteringCombat", true)
    RunService.Heartbeat:Wait()


    self.EntityObj = require(ServerScriptService.HarukaServer.Library.Entities:FindFirstChild(entity.Name, true)).new(entity)


    local hasPosVal = true
    local combatLocation = target:GetAttribute("CombatLocation_Encounter")
    if not combatLocation then
        hasPosVal = false

        combatLocation = CFrame.new(ServerLib:FindGroundByRayForOrb(target.PrimaryPart.Position))
        target:SetAttribute("CombatLocation_Encounter", combatLocation)

        self.CombatTriggerer = target.Name
    end

    self.CombatStarter = target.Name

    entity:SetAttribute("CombatLocation", combatLocation)


    --// ready to fight
    local nearbyCount = 0
    local function _nearbyEnemyEnterCombat()
        for _, entityObj: table in allEntityPool do
            if nearbyCount >= 5 then break end

            local thatEntity = entityObj.Entity :: Model
            if not ServerLib:IsCharValid(thatEntity) then continue end

            --// we don't call bosses
            if entityObj.HasLeader then continue end
            if entityObj.IsLeader then continue end
            if entityObj.IsInCombat then continue end


            if (thatEntity.PrimaryPart.Position - combatLocation.Position).Magnitude <= 32 then
                enterCombatSignal:Fire(thatEntity, target)
                nearbyCount += 1
            end
        end
    end

    entity.Humanoid.WalkSpeed = 0
    entity.PrimaryPart.CanCollide = false


    local bp = Instance.new("BodyPosition")
    bp.Name = "Blackhole"
    bp.D = 159 * 2
    bp.Position = combatLocation.Position + Vector3.yAxis * self.BoundingSize.Y
    bp.MaxForce = Vector3.one * math.huge
    bp.Parent = entity.PrimaryPart
    Debris:AddItem(bp, 5)


    local encounterBorder: Model = nil
    if not hasPosVal then
        encounterBorder = ReplicatedStorage.Packages.Unloads.EncounterBorder:Clone() :: Model
        encounterBorder:PivotTo(combatLocation)
        encounterBorder:SetAttribute("Owner", target.Name)
        encounterBorder.Parent = workspace
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
                if not thatEntityObj.IsInCombat then continue end
                if not thatEntityObj.CombatTriggerer then continue end
                if thatEntityObj.IsDead then continue end

                if thatEntityObj.CombatTriggerer == target.Name then
                    repeat wait() until thatEntityObj.EnteringCombat_Ready
                    break
                end
            end

            resolve()

        end):timeout(1.1599 * 2.599 + 0.1599):catch(function()

        end):await()
    end


    if not hasPosVal then
        wait(1.1599 * (if self.Entity:GetAttribute("IsBoss") then 2.599 else 1))
    end
    if bp then bp:Destroy() end
    if encounterBorder then encounterBorder:Destroy() end

    entity.PrimaryPart.CanCollide = true


    --- check again!
    if not ServerLib:IsCharValid(target) then self:_ErrorAndRespawn(1) return end


    --// we will check starter enemy
    if hasPosVal then
        Promise.new(function(resolve)
            for _, thatEntityObj in allEntityPool do
                if thatEntityObj.UniqueId == self.UniqueId then continue end
                if not thatEntityObj.IsInCombat then continue end
                if not thatEntityObj.CombatTriggerer then continue end
                if thatEntityObj.IsDead then continue end

                if thatEntityObj.CombatTriggerer == target.Name then
                    resolve(ServerLib:IsCharValid(thatEntityObj.Entity))
                    break
                end
            end

            resolve(false)

        end):andThen(function(state)
            if not state then self:_ErrorAndRespawn(3) return end

        end):catch(function(err)
            warn(tostring(err))
        end)
    end


    --// finally!
    local rLocation = ServerLib:FindGroundByRayForOrb(combatLocation.Position
        + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15)))

    entity:PivotTo(CFrame.new(rLocation) * CFrame.new(0, self.BoundingSize.Y / 2, 0) * CFrame.Angles(0, math.rad(math.random(0, 360)), 0))
    entity:AddTag("EnemyEntity_Combat")

    self.EnteringCombat_Ready = true


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
    local function _addInCombat(char: Model)
        _addAndSetTargetingEnemy(char)

        char:SetAttribute("CombatLocation", combatLocation)
        char:SetAttribute("CombatStartClock", DateTime.now().UnixTimestamp)
        char:SetAttribute("IsInCombat", true)


        local targetSymbol = Instance.new("ObjectValue")
        targetSymbol.Name = char.Name
        targetSymbol.Value = char
        targetSymbol.Parent = entity.TargetingList
    end
    if not hasPosVal then
        --// combat starter enemy
        _addInCombat(target)

        for _, nearbyChar: Model in _getCharsByRadius(combatLocation.Position, borderSize / 1.5) do
            if nearbyChar.Name == target.Name then continue end
            if not ServerLib:IsCharValid(nearbyChar) then continue end
            if nearbyCharCount >= 5 then break end

            if nearbyChar:GetAttribute("IsInCombat") then continue end
            if nearbyChar:FindFirstChild("CombatCooldown") then continue end

            nearbyCharCount += 1
            _addInCombat(nearbyChar)
        end
    else
        --// got pulled by combat starter enemy
        for _, thatEntityObj in allEntityPool do
            if thatEntityObj.UniqueId == self.UniqueId then continue end
            if not thatEntityObj.IsInCombat then continue end
            if not thatEntityObj.CombatTriggerer then continue end
            if thatEntityObj.IsDead then continue end

            if thatEntityObj.CombatTriggerer == target.Name then
                for _, thatEntitySymbol: ObjectValue in thatEntityObj.Entity.TargetingList:GetChildren() do
                    if not ServerLib:IsCharValid(thatEntitySymbol.Value) then continue end

                    local char = thatEntitySymbol.Value :: Model

                    _addAndSetTargetingEnemy(char)

                    nearbyCharCount += 1

                    local targetSymbol = Instance.new("ObjectValue")
                    targetSymbol.Name = char.Name
                    targetSymbol.Value = char
                    targetSymbol.Parent = entity.TargetingList
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
            Events.CreateNotify.FireList(players, "Combat Timeout!")

            warn("Combat Timeout, unknown reason unconfirmed")
        else
            Events.CreateNotify.FireList(players, "An error occurred during combat! We're sorry!")

            warn(tostring(err))
        end
    end):await()


    RunService.Heartbeat:Wait()

    self:_CombatEnd()
end



function EntityLib:_CombatEnd()
    if self.IsDead then return end
    if not self.IsInCombat then return end
    if not self.Entity:GetAttribute("IsInCombat") then return end

    self.IsDead = true
    self.Entity:SetAttribute("IsDead", true)

    local entity = self.Entity :: Model

    if not ServerLib:IsModelValid(entity) then self:_ErrorAndRespawn(4) return end
    if not entity:FindFirstChild("TargetingList") then self:_ErrorAndRespawn(5) return end

    local targetingList = self.Entity.TargetingList:GetChildren() :: { ObjectValue }



     --- search for nearby entities, if there are any, will have to wait for them to die
    local foundTeamUpEnemies = false
    for _, thatEntityObj: table in allEntityPool do
        if thatEntityObj.UniqueId == self.UniqueId then continue end
        if not thatEntityObj.IsInCombat then continue end
        if not thatEntityObj.CombatStarter then continue end
        if thatEntityObj.IsDead then continue end

        if thatEntityObj.CombatStarter == self.CombatStarter then
            foundTeamUpEnemies = true

            local alreadyAdded = false
            local teamUpEnemies = thatEntityObj.Entity.TeamUpEnemies:GetChildren() :: { ObjectValue }

            for _, teamUpEntitySymbol in teamUpEnemies do
                if teamUpEntitySymbol.Name == self.UniqueId then
                    alreadyAdded = true
                    break
                end
            end
            if not alreadyAdded then
                local teamUpEntitySymbol = Instance.new("ObjectValue")
                teamUpEntitySymbol.Name = self.UniqueId
                teamUpEntitySymbol.Value = self.Locator

                teamUpEntitySymbol:SetAttribute("Level", self.Entity:GetAttribute("Level"))

                teamUpEntitySymbol.Parent = thatEntityObj.Entity.TeamUpEnemies
            end
        end
    end
    if not foundTeamUpEnemies then
        local teamUpEnemies = self.Entity.TeamUpEnemies:GetChildren() :: { ObjectValue }

        if #teamUpEnemies > 0 then
            for _, teamUpEntitySymbol in teamUpEnemies do
                destroyEntityObjSignal:Fire(teamUpEntitySymbol.Name)
            end
        end

        destroyEntityObjSignal:Fire(self.UniqueId)
    end


    --// check if entity is dead, if no, then means player failed
    local isEnemyDeadCheck = false
    if entity.Humanoid.Health <= 0 then
        isEnemyDeadCheck = true
    end


    local function _giveLoot(drops: table, char: Model)
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr then return end

        local result, _, _ = HarukaLib:RollLoot(drops)

        ServerLib:PlaceItemDropPart(plr, result, 1, entity.PrimaryPart.Position)
    end
    local function _giveBadge(entityInfo: table, char: Model)
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr then return end

        if entityInfo.BadgeId then
            ServerLib:GiveBadge(entityInfo.BadgeId, plr)
        end
    end
    for _, charSymbol: ObjectValue in targetingList do
        local thatChar = charSymbol.Value :: Model

        if not ServerLib:IsCharValid(thatChar) then continue end


        local charTargetingList = thatChar.TargetingList :: Folder
        for _, targetingSymbol: ObjectValue in charTargetingList:GetChildren() do
            if not ServerLib:IsCharValid(targetingSymbol.Value) then
                targetingSymbol:Destroy()
                continue
            end
        end

        --// check if player has done all the targets
        if #charTargetingList:GetChildren() <= 0 then
            ServerBindables.PlayerCombatEnded:Fire(thatChar.Name)
        else
            --- get the first target again
            thatChar.TargetingEnemy.Value = charTargetingList:FindFirstChildOfClass("ObjectValue").Value
        end


        --- give loots and badges, combat won!
        local success, err = pcall(function()
            if not foundTeamUpEnemies and isEnemyDeadCheck then
                local entityInfo = EntityBook[entity.Name]

                _giveLoot(entityInfo.Drops, thatChar)
                _giveBadge(entityInfo, thatChar)

                for _, diedEntitySymbol: ObjectValue in entity.TeamUpEnemies:GetChildren() do
                    local diedEntityInfo = EntityBook[diedEntitySymbol.Value.Name]

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
                    ServerLib:GiveEXPRewards(plr, totalEXP)

                    HarukaLib:AddAttr(plr, "Gold", totalGold)
                    ServerLib:ShowText(thatChar, `+{totalGold} GOLD`, Color3.fromHex('#ffeaa7'))
                end
            end
        end)
        if not success then warn(err) end
    end
end


return EntityLib