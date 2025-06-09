
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local SS = game:GetService("ServerStorage")


local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local Events = require(ReplicatedStorage.HarukaShared.Library.Events)
local ClientLib = require(ReplicatedStorage.HarukaShared.Library.ClientLib)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local EntityBook = require(ReplicatedStorage.HarukaShared.Library.EntityBook)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)

local Add, Empty = HarukaLib.Bin()


local player = Players.LocalPlayer
local char = script:FindFirstAncestorOfClass("Model")


repeat task.wait() until char:GetAttribute("Haruka_CriRPGClientInited")


local entityStorage = nil

if not SS:FindFirstChild("EntitiesAFK") then
    entityStorage = Instance.new("Folder")
    entityStorage.Name = "EntitiesAFK"
    entityStorage.Parent = SS
else
    entityStorage = SS:FindFirstChild("EntitiesAFK")
end



Add(Players.PlayerRemoving:Connect(function(plr: Player)
	if player == plr then
		Empty()
	end
end))
Add(script.Destroying:Connect(function()
    Empty()
end))
Add(char.Humanoid.HealthChanged:Connect(function(health: number)
    if health <= 0 then
        Empty()
    end
end))
Add(char.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
    local newParent = char
    if newParent then
        if newParent.PrimaryPart == nil and not newParent:FindFirstChild("Humanoid") then
            Empty()
            return
        end
    else
        Empty()
    end
end))


local EntityLib = {}
EntityLib.__index = EntityLib


local wait = task.wait


local allEntityPool = {}


Add(Events.ApplyFoundStatusToEnemy.On(function(data)
    local entity = data.Enemy
    if not ClientLib:IsCharValid(entity) then return end

    local distance = player:DistanceFromCharacter(entity.PrimaryPart.Position)
    if distance <= 0 or distance >= 155 then return end

    local encountered = ReplicatedStorage.Packages.Effects.Encountered.BillboardGui:Clone() :: BillboardGui
    encountered.Adornee = entity.PrimaryPart
    encountered.Size = UDim2.fromScale(4, 4)
    encountered.Parent = entity
    Debris:AddItem(encountered, 1.15)


    HarukaLib:CreateTween(encountered.TextButton, AssetBook.TweenInfos.one, {
        TextTransparency = 1, TextStrokeTransparency = 1
    }):Play()
    HarukaLib:CreateTween(encountered, AssetBook.TweenInfos.half, {
        Size = UDim2.fromScale(1.5, 1.5)
    }):Play()


    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = entity
    Debris:AddItem(highlight, 1.15)


    HarukaLib:CreateTween(highlight, AssetBook.TweenInfos.one, {
        FillTransparency = 1,
        OutlineTransparency = 1
    }):Play()
end))
Add(Events.PlayAnimForEnemy.On(function(data)
    if not ClientLib:IsCharValid(data.Entity) then return end


    for _, entityObj in allEntityPool do
        if entityObj.Entity == data.Entity then
            if not entityObj.HasModel then break end

            entityObj:PlayAnim(data.AnimId)
            break
        end
    end
end))
Add(Events.ApplyHighlightForEntity.On(function(data)
    if not ClientLib:IsModelValid(data.Entity) then return end

    local highlight = Instance.new("Highlight")
    highlight.Parent = data.Entity
    Debris:AddItem(highlight, data.Duration)

    HarukaLib:CreateTween(highlight, TweenInfo.new(data.Duration), {
        FillTransparency = 1,
        OutlineTransparency = 1
    }):Play()
end))
local storagePromise = Promise.try(function()
    while wait(0.5) do
        for _, entityObj in allEntityPool do
            if not entityObj.IsReady then continue end
            if not ClientLib:IsModelValid(entityObj.Entity) then continue end

            pcall(function()
                local distance = player:DistanceFromCharacter(entityObj.Entity.PrimaryPart.Position)
                if distance < 189 and distance > 0 then
                    entityObj.Entity.Parent = workspace.Entities
                elseif distance >= 200 and entityObj.HasModel then
                    entityObj.Entity.Parent = entityStorage
                end
            end)
        end
    end
end)
local encounterPromise = Promise.try(function()
    local encounterCD = false
    while wait(0.5) do
        if encounterCD then continue end
        if char:FindFirstChild("CombatCooldown") then continue end

        local nearestEnemy = nil
        local nearestDist = 999

        for _, entityObj in allEntityPool do
            if not entityObj.IsReady then continue end
            if not ClientLib:IsCharValid(entityObj.Entity) then continue end

            local entity = entityObj.Entity

            if entity:GetAttribute("IsInCombat") then continue end
            if entity:GetAttribute("IsDead") then continue end
            if entity:GetAttribute("EnteringCombat") then continue end
            if not entity:GetAttribute("IsReady") then continue end


            local distance = player:DistanceFromCharacter(entity.PrimaryPart.Position)
            if distance > 0 then
                if distance <= nearestDist then
                    nearestEnemy = entity
                    nearestDist = distance
                end
            end
        end

        if nearestDist > 0 and nearestDist < 18 then
            encounterCD = true
            task.delay(2, function()
                encounterCD = false
            end)

            Events.RequestToStartCombat.Fire({
                Entity = nearestEnemy
            })
        end
    end
end)
local bossTrackingPromise = Promise.try(function()
    while wait(1.2) do
        for _, entity: Model in CollectionService:GetTagged("BossEnemyEntity") do
            if entity.Parent ~= workspace.Entities then continue end
            if not entity:IsA("Model") then continue end
            if not entity:GetAttribute("HarukaUniqueId") then continue end
            if not allEntityPool[entity:GetAttribute("HarukaUniqueId")] then continue end

            if not entity:GetAttribute("IsReady") then continue end
            if entity:GetAttribute("IsDead") then continue end
            if entity:GetAttribute("EnteringCombat") then continue end
            if entity:GetAttribute("IsInCombat") then continue end
            if entity:GetAttribute("NoRotate") then continue end
            if entity:GetAttribute("NearestChar") then continue end

            Promise.try(function()
                wait(math.random(5) / 10)
                local rotating = math.random(5, 20)
                local direction = math.random(-2, 2)

                for _ = 1, rotating do
                    if not ClientLib:IsModelValid(entity) then break end
                    if entity:GetAttribute("NearestChar") then break end

                    entity.PrimaryPart.CFrame *= CFrame.Angles(0, math.rad(direction * 5), 0)
                    wait(0.01)
                end
            end)
        end
    end
end)
Add(function()
    storagePromise:cancel()
    encounterPromise:cancel()
    bossTrackingPromise:cancel()
end)
Add(function()
    for _, entityObj in allEntityPool do
        pcall(entityObj.Destroy, entityObj)
    end
end)



function EntityLib.new(enemy: Model)
	if not ClientLib:IsCharValid(enemy) then return nil end
    if allEntityPool[enemy:GetAttribute("HarukaUniqueId")] then return nil end


    local self = setmetatable({}, EntityLib)

    repeat wait() until enemy:WaitForChild("Locator", 999)
    repeat wait() until enemy.Locator.Value

	self.Entity = enemy
    self.Locator = enemy.Locator.Value :: BasePart

    self.UniqueId = enemy:GetAttribute("HarukaUniqueId")
	self.SourceModel = ReplicatedStorage.Packages.EnemyModels:FindFirstChild(enemy.Name, true)

    self.Add, self.Empty = HarukaLib.Bin()


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
    self.Add(self.Locator:GetPropertyChangedSignal("Parent"):Connect(function()
        local newParent = self.Locator
        if newParent then
            newParent = newParent.Parent
        end
        if newParent == nil then
            self:Destroy()
        end
    end))
    self.Add(function()
        self:_DestroyModel()
    end)


    allEntityPool[self.UniqueId] = self


    return self
end


function EntityLib:Init()
    self:_ListenAttributeTracker()
    self:_LoadAnims()
    self:_MakeModel()

    self.IsReady = true
end


function EntityLib:Destroy()
    allEntityPool[self.UniqueId] = nil

    self.Empty()
end



function EntityLib:PlayAnim(animId: string)
    if not self.Anims[animId] then
        if RunService:IsStudio() then
            warn("Invalid enemy entity anim id: "..animId)
        end
        return
    end

    self.Anims[animId]:Play()
end



--// Private functions

function EntityLib:_LoadAnims()
    self.Anims = {}

    local entity = self.Entity
    local entityInfo = EntityBook[entity.Name]

    if entityInfo == nil then
        warn(`Lacking of entity info for {entity.Name}`)
        return
    end

    local animContainer = ReplicatedStorage.Packages.Anims.EnemyAnims:FindFirstChild(entity.Name, true) :: Folder
    if not ClientLib:IsCharValid(entity) then return end

    if not entity.Humanoid:FindFirstChild("Animator") then
        Instance.new("Animator", entity.Humanoid)
    end


    for _, anim: Animation in animContainer:GetChildren() do
        if anim:IsA("ObjectValue") then
            anim = anim.Value
        end
        if not anim:IsA("Animation") then continue end

        local track = entity.Humanoid.Animator:LoadAnimation(anim) :: AnimationTrack
        track.Looped = false
        track.Priority = Enum.AnimationPriority.Action2

        if anim.Name == "Idle" then
            track.Looped = true
            track.Priority = Enum.AnimationPriority.Idle
        end

        self.Anims[anim.Name] = track
    end
end


function EntityLib:_DestroyModel()
    for _, child: Instance in self.Entity:GetDescendants() do
        if child == nil then continue end
        if child:HasTag("EntityBodyPart") then child:Destroy() end
    end

    self.HasModel = false
end

function EntityLib:_MakeModel()
	if self.HasModel then return end

    local entity = self.Entity :: Model
    if not ClientLib:IsModelValid(entity) then return end

    -- already has model
    if entity:FindFirstChild("Torso") then return end

    local model = self.SourceModel:Clone() :: Model

    if model:FindFirstChild("AnimationController") then model.AnimationController:Destroy() end
    if model:FindFirstChild("AnimSaves") then model.AnimSaves:Destroy() end

    entity.PrimaryPart.Anchored = true
    entity.PrimaryPart.Transparency = 1

    model:PivotTo(entity.PrimaryPart.CFrame)

    local motor6d = model.PrimaryPart:FindFirstChildOfClass("Motor6D"):Clone()
    motor6d.Parent = entity.PrimaryPart
    motor6d:AddTag("EntityBodyPart")

    model.PrimaryPart:Destroy()

    --// clone in
    for _, child: Instance in model:GetChildren() do
        child:AddTag("EntityBodyPart")
        child.Parent = entity
    end
    model:Destroy()

    motor6d.Part0 = entity.PrimaryPart
    motor6d.Part1 = entity.Torso
    motor6d.Parent = entity.PrimaryPart

    entity.PrimaryPart.Anchored = false

    HarukaLib:SetCollisionGroup(entity, "EnemyBodyPart")

    self.Anims.Idle:Play()

    self.HasModel = true

    return model
end


function EntityLib:_ListenAttributeTracker()
    local entity = self.Entity :: Model

    local alreadyAttributeEnteringCombat = entity:GetAttribute("EnteringCombat") :: boolean
    local alreadyAttributeEnteredCombat = entity:GetAttribute("EnteredCombat") :: boolean
    local alreadyAttributeIsDead = entity:GetAttribute("IsDead") :: boolean

    self.Add(HarukaLib:Hydrate(entity, {
        ["Attr-EnteringCombat"] = function(state: boolean)
            if not state then return end
            if not self.HasModel then return end
            if alreadyAttributeEnteringCombat then return end
            if not ClientLib:IsCharValid(entity) then return end


            for _, child: Instance in entity:GetDescendants() do
                if child.Parent == entity then continue end
                if child.Name == "Middle" then continue end
                if child.Name == "Base" then continue end


                if HarukaLib:IsBasePartType(child) then
                    child.Transparency = 0.4
                    child.Color = Color3.fromHex('#70a1ff')

                    if child:IsA("UnionOperation") then child.UsePartColor = true end
                end
            end
        end,
        ["Attr-EnteredCombat"] = function(state: boolean)
            if not state then return end
            if not self.HasModel then return end
            if alreadyAttributeEnteredCombat then return end
            if not ClientLib:IsCharValid(entity) then return end


            local cylinderMesh = Instance.new("CylinderMesh")

            local eff = HarukaLib:CreateMockPart()
            eff.Size = Vector3.new(entity.PrimaryPart.Size.X + 1, 100, entity.PrimaryPart.Size.Z + 1)
            eff.CFrame = entity.PrimaryPart.CFrame
            eff.Color = Color3.fromHex('#81ecec')
            eff.Material = Enum.Material.Neon
            eff.Transparency = 0.4

            cylinderMesh.Parent = eff

            eff.Parent = workspace
            Debris:AddItem(eff, 1)

            local afterSize = eff.Size + Vector3.new(15.99 * 2, 0, 15.99 * 2)

            HarukaLib:CreateTween(eff, AssetBook.TweenInfos.half, {
                Size = afterSize,
                Transparency = 1
            }):Play()

            self:_DestroyModel()
            self:_MakeModel()
        end,
        ["Attr-IsDead"] = function(state: boolean)
            if not state then return end
            if not self.HasModel then return end
            if alreadyAttributeIsDead then return end
            if not ClientLib:IsModelValid(entity) then return end

            for _, child: Instance in entity:GetDescendants() do
                if child.Parent == entity then continue end
                if child.Name == "Middle" then continue end
                if child.Name == "Base" then continue end

                if HarukaLib:IsBasePartType(child) then
                    child.Transparency = 0.4
                    child.Color = Color3.new(1, 1, 1)

                    HarukaLib:CreateTween(child, AssetBook.TweenInfos.one, {
                        Transparency = 1
                    }):Play()


                    if child:IsA("UnionOperation") then child.UsePartColor = true end
                end
            end

            local location = entity.PrimaryPart.CFrame

            Promise.delay(1):andThen(function()
                local deathEffect = ReplicatedStorage.Packages.Effects.DefeatedEffect:Clone() :: BasePart
                deathEffect.CFrame = location
                deathEffect.Parent = workspace

                Debris:AddItem(deathEffect, 2)

                ClientLib:PlayWorldSound(SoundService.SFXs.EnemyCorpsed, deathEffect.Position)

            end):catch(function() end)
        end
    }))
end



local function initEntity(enemy: Model)
    local entityObj = EntityLib.new(enemy)
    if entityObj then
        entityObj:Init()
    end
end
for _, enemy: Model in CollectionService:GetTagged("EnemyEntity") do
    Promise.try(initEntity, enemy)
end
CollectionService:GetInstanceAddedSignal("EnemyEntity"):Connect(initEntity)
