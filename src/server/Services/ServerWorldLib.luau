local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")


local ServerWorldLib = {}

local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local CollisionBook = require(ServerScriptService.HarukaServer.Library.CollisionBook)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ItemLib = require(ReplicatedStorage.HarukaShared.Library.ItemLib)


function ServerWorldLib:Init()
    if not workspace:FindFirstChild("Maps") then
        error("Maps folder not found in workspace")
    end
    if not workspace:FindFirstChild("MapComponents") then
        error("MapComponents folder not found in workspace")
    end


    for funcId: string, func: (self) -> nil in ServerWorldLib do
        if string.find(funcId, "_Do") and typeof(func) == "function" then
            func(self)
        end
    end
end


--// Private functions



function ServerWorldLib:_DoCreateEssentialFolders()
    local projectileContainer = Instance.new("Folder")
    projectileContainer.Name = "ProjectileSymbolContainer"
    projectileContainer.Parent = ServerStorage

    local itemCDSymbolContainer = Instance.new("Folder")
    itemCDSymbolContainer.Name = "ItemCDSymbolContainer"
    itemCDSymbolContainer.Parent = ServerStorage

    local itemSphereSymbolContainer = Instance.new("Folder")
    itemSphereSymbolContainer.Name = "ItemSphereSymbolContainer"
    itemSphereSymbolContainer.Parent = ServerStorage

    local entityContainer = Instance.new("Folder")
    entityContainer.Name = "EntitiesPlayerChar"
    entityContainer.Parent = workspace

    local orbContainer = Instance.new("Folder")
    orbContainer.Name = "OrbSymbolContainer"
    orbContainer.Parent = ServerStorage

    local skillProjectileContainer = Instance.new("Folder")
    skillProjectileContainer.Name = "SkillProjectileContainer"
    skillProjectileContainer.Parent = ServerStorage

    local craftingProductContainer = Instance.new("Folder")
    craftingProductContainer.Name = "CraftingProductContainer"
    craftingProductContainer.Parent = workspace
end


function ServerWorldLib:_DoCreateCraftingProductEntities()
    for _, product in ItemLib:GetAllItems() do
        local info = ItemLib:GetItemInfo(product)

        if HarukaLib.TableUtils().IsEmpty(info.RecipeDesync) then continue end

        local productVal = Instance.new("IntConstrainedValue")
        productVal.Name = info.ItemId
        productVal.Value = 1

        productVal:AddTag("CraftingProductEntity")

        productVal:SetAttribute("ItemStat", ServerLib:GiveRandomStatForItem(info.ItemId))
        productVal:SetAttribute("Level", info.Level)
        productVal:SetAttribute("HarukaUniqueId", HttpService:GenerateGUID(false))

        productVal.Parent = workspace.CraftingProductContainer
    end
end


function ServerWorldLib:_DoTrees()
    local pathModifier = Instance.new("PathfindingModifier")
    pathModifier.Label = "DangerZone"
    pathModifier.PassThrough = false


    local treeContainer = Instance.new("Folder")
    treeContainer.Name = "TreeContainer"
    treeContainer.Parent = workspace


    for _, tree: Model in workspace:GetDescendants() do
        if tree:IsA("Model") and string.find(string.lower(tree.Name), "tree") then
            tree:AddTag("TreeEntity")
            tree.Parent = treeContainer

            for _, part: BasePart in tree:GetDescendants() do
                if HarukaLib:IsBasePartType(part) and part.Material == Enum.Material.Grass then
                    part.CanCollide = false
                    part.CastShadow = math.random(1, 2) == 1
                    part.CanQuery = false
                    part.CanTouch = false
                    part.Massless = true
                end
            end
        end
    end
    for _, tree: Model in CollectionService:GetTagged("TreeEntity") do
        local part = HarukaLib:CreateMockPart()
        part.Name = "TreeBoundingBox"
        part.Size = select(2, tree:GetBoundingBox()) * 1.599
        part.CFrame = tree.WorldPivot
        part.CanQuery = true
        part.Parent = tree

        pathModifier:Clone().Parent = part
    end
end


function ServerWorldLib:_DoMapOptimization()
    for _, pathLink: PackageLink in ReplicatedStorage:GetDescendants() do
        if pathLink:IsA("PackageLink") then
            pathLink:Destroy()
        end
    end
    for _, part: BasePart in workspace:GetDescendants() do
        if HarukaLib:IsBasePartType(part) then
            if part:HasTag("ZoneEntity") then continue end

            part.EnableFluidForces = false
            part.CanTouch = false
            part.Massless = true
            part.Locked = true
        end
    end


    local function _optimize(container: Instance)
        for _, part: BasePart in container:GetDescendants() do
            if HarukaLib:IsBasePartType(part) then
                part.EnableFluidForces = false
            end
        end
        for _, part: Model in container:GetDescendants() do
            if part:IsA("Model") then
                if #part:GetChildren() <= 0 then
                    part:Destroy()
                end
            end
        end
    end
    _optimize(workspace)
    _optimize(ReplicatedStorage)

    if workspace.MapComponents:FindFirstChild("Titlescreen") then
        for _, part: BasePart in workspace.MapComponents.Titlescreen:GetDescendants() do
            if HarukaLib:IsBasePartType(part) then
                part.CanTouch = false
                part.CanQuery = false
                part.CastShadow = false
                part.CollisionGroup = "NoCollision"
            end
        end
    end
end


function ServerWorldLib:_DoPlayerBorderInit()
    local function _updateBorder(border: Model)
        for _, child: Instance in border.Border:GetChildren() do
            if child:IsA("BasePart") and child.Name == "Part" then
                local beam = child:FindFirstChildOfClass("Beam")

                beam.Transparency = NumberSequence.new(1, 1)
                beam.LightInfluence = 0
                beam.LightEmission = 1
            end
        end
    end
    for _, border: Model in CollectionService:GetTagged("CombatBorder") do
        _updateBorder(border)
    end
    for _, border: Model in CollectionService:GetTagged("EncounterBorder") do
        _updateBorder(border)
    end
end


function ServerWorldLib:_DoPlayerOrbInit()
    for _, orb: Model in ReplicatedStorage.Packages.ClassAttacks:GetDescendants() do
        if not orb:HasTag("OrbEntity") then continue end

        for _, part: BasePart in orb:GetDescendants() do
            if not part:IsA("BasePart") then continue end

            part.CanTouch = false
            part.CanQuery = false
            part.CanCollide = false
            part.CastShadow = false
            part.Massless = true
        end

        --// orb rotation support
        local alignMoverAttachment = Instance.new("Attachment")
        alignMoverAttachment.Name = "AlignMoverAttachment"
        alignMoverAttachment.Parent = orb.PrimaryPart

        local linearVel = Instance.new("LinearVelocity")
        linearVel.ForceLimitsEnabled = false
        linearVel.Attachment0 = alignMoverAttachment
        linearVel.VectorVelocity = Vector3.zero
        linearVel.Parent = orb.PrimaryPart

        local angularVelocity = Instance.new("AngularVelocity")
        angularVelocity.Attachment0 = alignMoverAttachment
        angularVelocity.AngularVelocity = Vector3.yAxis * 2
        angularVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        angularVelocity.MaxTorque = math.huge
        angularVelocity.Parent = orb.PrimaryPart

        orb.Hitbox.CanTouch = true
    end
end


function ServerWorldLib:_DoTerrainTag()
    local terrainFolders = {}

    for _, folder: Folder in workspace.Maps:GetDescendants() do
        if folder:IsA("Folder") and folder.Name == "Terrain" then
            table.insert(terrainFolders, folder)
        end
    end


    for _, part: BasePart in workspace.Maps:GetDescendants() do
        if HarukaLib:IsBasePartType(part) then
            local isInTerrainFolder = false
            for _, folder: Folder in terrainFolders do
                if part:IsDescendantOf(folder) then
                    isInTerrainFolder = true
                    break
                end
            end
            if isInTerrainFolder then
                part:AddTag("TerrainPart")
            end
        end
    end
end


function ServerWorldLib:_DoInitSoundGroups()
    for _, material in Enum.Material:GetEnumItems() do
        if not ReplicatedStorage.Packages.Audio.FS_SFXs:FindFirstChild(material.Name) then
            local airReplacement = ReplicatedStorage.Packages.Audio.FS_SFXs.Air:Clone()
            airReplacement.Name = material.Name
            airReplacement.Parent = ReplicatedStorage.Packages.Audio.FS_SFXs
        end
    end
    for _, sGroup: SoundGroup in ReplicatedStorage.Packages.Audio:GetChildren() do
        if sGroup:IsA("SoundGroup") then
            sGroup.Parent = SoundService

            for _, sound: Sound in sGroup:GetChildren() do
                if sound:IsA("Sound") then
                    sound.SoundGroup = sGroup
                end
            end
        end
    end
    for _, child: Instance in ReplicatedStorage.Packages.EnemyAttacks:GetDescendants() do
        if child:IsA("Sound") then child.SoundGroup = SoundService.SFXs end
    end
end


function ServerWorldLib:_DoInitCollision()
    HarukaLib:SetCollisionGroup(ReplicatedStorage.Packages.Unloads.CombatBorder, CollisionBook.Group.Hitbox)
    HarukaLib:SetCollisionGroup(ReplicatedStorage.Packages.Unloads.EncounterBorder, CollisionBook.Group.Hitbox)
    HarukaLib:SetCollisionGroup(ReplicatedStorage.Packages.EnemyModels, CollisionBook.Group.EnemyBodyPart)
    HarukaLib:SetCollisionGroup(ReplicatedStorage.Packages.EnemyAttacks, CollisionBook.Group.EnemyProjectile)
    HarukaLib:SetCollisionGroup(ReplicatedStorage.Packages.ClassWeapons, CollisionBook.Group.NoCollision)
    HarukaLib:SetCollisionGroup(ReplicatedStorage.Packages.ClassAttacks, CollisionBook.Group.Hitbox)
    HarukaLib:SetCollisionGroup(ReplicatedStorage.Packages.SkillProjectiles, CollisionBook.Group.NoCollision)


    CollectionService:GetInstanceAddedSignal("NPCEntity"):Connect(function(npc: Model)
        HarukaLib:SetCollisionGroup(npc, CollisionBook.Group.NPCBodyPart)
    end)
end



function ServerWorldLib:_DoMarketNPCOptimizeInit()
    if not workspace.MapComponents:FindFirstChild("Markets") then return end


    for _, npc: Model in workspace.MapComponents.Markets:GetDescendants() do
        if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
            HarukaLib:SetCollisionGroup(npc, "NoCollision")


            if not npc.Humanoid:FindFirstChildOfClass("Animator") then
                local animator = Instance.new("Animator")
                animator.Parent = npc.Humanoid
            end

            local npcAnim = npc:GetAttribute("IdleAnim") or "DefaultIdle"
            local animTrack = npc.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Packages.Anims.NPCAnims[npcAnim]) :: AnimationTrack

            animTrack.Looped = true
            animTrack.Priority = Enum.AnimationPriority.Idle

            animTrack:Play()
        end
    end
    for _, product: Instance in workspace.MapComponents.Markets:GetDescendants() do
        if product.Parent and product.Parent:IsA("Folder") and product.Parent.Name == "Products" then
            if ItemLib:GetItemInfo(product.Name) then
                product:AddTag("MarketProductEntity")
                product:SetAttribute("HarukaUniqueId", HttpService:GenerateGUID(false))

                product:SetAttribute("ItemStat", ServerLib:GiveRandomStatForItem(product.Name))
                product:SetAttribute("Level", ItemLib:GetItemInfo(product.Name).Level)
            end
        end
    end
end


function ServerWorldLib:_DoInitNPCs()
    if not workspace.MapComponents:FindFirstChild("NPCs") then return end


    for _, npc: Model in workspace.MapComponents.NPCs:GetDescendants() do
        if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
            npc:AddTag("NPCEntity")
            npc.PrimaryPart = npc.Humanoid.RootPart

            if npc.Humanoid:FindFirstChildOfClass("Animator") then
                local anim = npc:GetAttribute("IdleAnim") or "DefaultIdle"
                local animTrack = npc.Humanoid.Animator:LoadAnimation(ReplicatedStorage.Packages.Anims.NPCAnims[anim]) :: AnimationTrack

                animTrack.Looped = true
                animTrack.Priority = Enum.AnimationPriority.Idle

                animTrack:Play()
            end
        end
    end
end


function ServerWorldLib:_DoZoneAreasInit()
    local areaZones = Instance.new("Folder")
    areaZones.Name = "AreaZones"

    if ServerStorage:FindFirstChild("Packages") and ServerStorage.Packages:FindFirstChild("AreaZones") then
        areaZones:Destroy()
        areaZones = ServerStorage.Packages.AreaZones
    end

    for _, part: BasePart in areaZones:GetDescendants() do
        if HarukaLib:IsBasePartType(part) then
            part.Transparency = 1
            part.CanCollide = false
            part.CanQuery = false
            part.Massless = true
            part.CastShadow = false
            part.Locked = true
            part.CanTouch = false
            part:AddTag("ZoneEntity")
        end
    end
    areaZones.Parent = workspace:FindFirstChild("MapComponents") or workspace
end





function ServerWorldLib:_DoFlowerBushCastShadowInit()
    local flowerContainer = Instance.new("Folder")
    flowerContainer.Name = "FlowerContainer"
    flowerContainer.Parent = workspace


    local whiteList = { "Flower", "Grass", "Bush" }
    for _, child: Instance in workspace.Maps:GetDescendants() do
        if child:IsA("Model") then
            local check = false
            for _, name in whiteList do
                if string.find(child.Name, name) then
                    check = true
                    break
                end
            end
            if child.Parent:IsA("Model") then
                for _, name in whiteList do
                    if string.find(child.Parent.Name, name) then
                        check = false
                        break
                    end
                end
            end
            if not check then continue end

            child:AddTag("FlowerEntity")
            child:AddTag("RaycastIgnoreEntity")
            child.Parent = flowerContainer

            for _, meshPart: MeshPart in child:GetDescendants() do
                if HarukaLib:IsBasePartType(meshPart) then
                    meshPart.CastShadow = false
                    meshPart.CanCollide = false
                    meshPart.CanQuery = false
                    meshPart.CanTouch = false
                    meshPart.CollisionGroup = CollisionBook.Group.NoCollision
                end
            end
        end
    end
end



function ServerWorldLib:_DoTagPrompts()
    local mapComponents = workspace.MapComponents :: Folder

	local function _updatePrompt(prompt: ProximityPrompt)
		if not prompt:IsA("ProximityPrompt") then return end


		local part = prompt.Parent :: BasePart
		if not part:IsA("BasePart") then
			warn("Invalid prompt parent object")
			return
		end

		prompt:SetAttribute("HarukaUniqueId", HttpService:GenerateGUID(false))
		prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
		prompt.Style = Enum.ProximityPromptStyle.Custom
		prompt.KeyboardKeyCode = Enum.KeyCode.Home
		prompt.RequiresLineOfSight = false
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 15.99

        prompt:AddTag("PromptEntity")
	end
	for _, child: Instance in mapComponents:GetDescendants() do
		_updatePrompt(child)
	end
	mapComponents.DescendantAdded:Connect(_updatePrompt)
end


function ServerWorldLib:_DoTrashcanServerStorageClear()
    if ServerStorage:FindFirstChild("Trashcan") then
        ServerStorage.Trashcan:Destroy()
    end
    if ServerStorage:FindFirstChild("Brushtool2_Plugin_Storage") then
        ServerStorage.Brushtool2_Plugin_Storage:Destroy()
    end
end


function ServerWorldLib:_DoShutdownTracker()
    local function shutdownSetup(closeReason: Enum.CloseReason)
        if RunService:IsStudio() then return end
        if closeReason ~= Enum.CloseReason.DeveloperUpdate then return end

        Events.CreateFSNotify.FireList(Players:GetPlayers(), string.upper("game is updating and restarting, please wait..."), 15)
    end
    game:BindToClose(shutdownSetup)
end


function ServerWorldLib:_DoChests()
    if not workspace.MapComponents:FindFirstChild("Chests") then return end


    for _, chest: Model in workspace.MapComponents.Chests:GetChildren() do
        if chest:IsA("Model") and chest:FindFirstChild("Giver") then
            chest:AddTag("ChestEntity")
        end
    end
end


function ServerWorldLib:_DoTrusses()
    for _, truss: TrussPart in workspace:GetDescendants() do
        if truss.ClassName == "TrussPart" then
            truss:AddTag("TrussEntity")
            truss.CanCollide = false
        end
    end
end


function ServerWorldLib:_DoMobInit()
    for _, mob: Model in ReplicatedStorage.Packages.EnemyModels:GetDescendants() do
        if not mob:IsA("Model") then continue end

        for _, child: Instance in mob:GetChildren() do
            if child:IsA("BasePart") and mob:FindFirstChild(child.Name .. "Model") then
                ServerLib:WeldModel(child, mob[child.Name .. "Model"])
            end
        end
    end
end


function ServerWorldLib:_DoStatuesInit()
    if not workspace.MapComponents:FindFirstChild("Statues") then return end

    for _, statue: Model in workspace.MapComponents.Statues:GetChildren() do
        if statue:IsA("Model") then
            statue:AddTag("StatueEntity")
        end
    end
end


return ServerWorldLib
