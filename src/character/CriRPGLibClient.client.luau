
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassSPSceneLib = require(RepS.HarukaShared.Library.ClassSPSceneLib)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local LocationBook = require(RepS.HarukaShared.Library.LocationBook)
local Events = require(RepS.HarukaShared.Library.Events)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local ProjectileLib = require(RepS.HarukaShared.Library.ProjectileLib)
local Maid = require(RepS.HarukaShared.Shared.Maid)


local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer

repeat task.wait() until char:GetAttribute("Haruka_CharClientInited")

local Add, Empty = HarukaLib.Bin()


local CriRPGLib = {}


local wait = task.wait


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		CriRPGLib:Destroy()
	end
end))
Add(script.Destroying:Connect(function()
    CriRPGLib:Destroy()
end))

--// Helper functions

local function _fadeOrb(orb: Model)
    orb:RemoveTag("OrbEntity")

    --// fade tween
    local orbMiddle = orb:FindFirstChild("Middle") or orb:FindFirstChild("Base") :: BasePart

    orb.Part.Anchored = false
    orb.ForceField.Anchored = false

    Bindables.ClientTween:Fire({
        Objs = { orbMiddle.Beam1, orbMiddle.Beam2 },
        Goal = { Transparency = NumberSequence.new(1, 1) },
        TweenInfo = "onceHalf",
        UseHarukaTween = true
    })


    HarukaLib:CreateTween(orb.ForceField, AssetBook.TweenInfos.onceHalf, {
        Transparency = 1,
        Position = orb.ForceField.Position + Vector3.new(0, -6, 0)
    }):Play()

    HarukaLib:CreateTween(orb.Part, AssetBook.TweenInfos.half, {
        Transparency = 1
    }):Play()

    HarukaLib:CreateTween(orb.Part, AssetBook.TweenInfos.onceHalf, {
        Position = orb.Part.Position + Vector3.new(0, 6, 0)
    }):Play()

    Debris:AddItem(orb, 0.35)
end


function CriRPGLib:Init()
    for funcId: string, func: (self) -> nil in CriRPGLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            func(self)
        end
    end


    Add(char.Humanoid.HealthChanged:Connect(function(health: number)
		if health <= 0 then
			self:Destroy()
		end
	end))
	Add(char.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
		local newParent = char
        if newParent then
            if newParent.PrimaryPart == nil and not newParent:FindFirstChild("Humanoid") then
                self:Destroy()
                return
            end
        else
            self:Destroy()
        end
	end))
end


function CriRPGLib:Destroy()
    Empty()
end


--// Private Methods

function CriRPGLib:_ListenCombatTracker()
    local isInCombat = false

    local function _destroyCombatBorder()
        for _, border: Model in CollectionService:GetTagged("CombatBorder") do
            if border:IsDescendantOf(workspace) then border:Destroy() end
        end
    end
    local function _checkCombatState(state: boolean)
        if state == nil then return end

        if state then
            if isInCombat then return end
            isInCombat = true

            _destroyCombatBorder()
            Bindables.CreateCenterNotify:Fire("COMBAT START!", true)

            local border = RepS.Packages.Unloads.CombatBorder:Clone() :: Model
            local entityPos = char:GetAttribute("CombatLocation") :: CFrame

            border:PivotTo(entityPos)
            border.Parent = workspace

            HarukaLib:SetCollisionGroup(border, "Hitbox")

            local distance = plr:DistanceFromCharacter(entityPos.Position)
            if distance >= 28 then
                char:PivotTo(entityPos * CFrame.new(math.random(-8, 8), 5.99, math.random(-8, 8)))
            end


            local isBoss = false
            local targetMusicId = "None"
            Promise.new(function(resolve)
                local targetingEnemy = char:FindFirstChild("TargetingEnemy") :: ObjectValue
                if targetingEnemy then
                    targetingEnemy = targetingEnemy.Value
                    if ClientLib:IsCharValid(targetingEnemy) then
                        if targetingEnemy:GetAttribute("IsBoss") then
                            isBoss = true
                            targetMusicId = targetingEnemy:GetAttribute("MusicId")
                        end
                    end
                end
                resolve()

            end):catch(function() end):await()


            pcall(function()
                if isBoss then
                    local targetSoundId = SoundService.Musics.Areas.Combat:FindFirstChild(targetMusicId) :: Sound
                    if targetSoundId then
                        if targetSoundId.SoundId ~= SoundService.Musics.Overworld.SoundId then
                            SoundService.Musics.Overworld:Pause()

                            SoundService.Musics.BossCombat.SoundId = targetSoundId.SoundId
                            SoundService.Musics.BossCombat:Play()
                        end
                    end
                else
                    if SoundService.Musics.Combat.SoundId ~= SoundService.Musics.Overworld.SoundId then
                        SoundService.Musics.Overworld:Pause()
                        SoundService.Musics.Combat:Play()
                    end
                end
            end)
            SoundService.SFXs.CombatStart:Play()

            task.delay(0.2, function()
                SoundService.SFXs.MobPhase:Play()
            end)
        else
            if not isInCombat then return end

            isInCombat = false

            SoundService.SFXs.CombatFinish:Play()
            SoundService.Musics.Combat:Stop()
            SoundService.Musics.BossCombat:Stop()
            SoundService.Musics.Overworld:Resume()

            _destroyCombatBorder()
        end
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _checkCombatState
    }))
    Add(_destroyCombatBorder)
    Add(function()
        if char.Humanoid.Health <= 0 and char:GetAttribute("IsInCombat") then
            SoundService.SFXs.CombatFailed:Play()
        end
    end)

    _destroyCombatBorder()
end


function CriRPGLib:_ListenAreaTracker()
    local areaAdd, areaEmpty = HarukaLib.Bin()

    local areaQueue = HarukaLib.Queue()
    Add(areaEmpty)
    Add(areaQueue)


    local function _calculateColor(x: number) : Color3
        x %= 24

        local y, amplitude = 0, 200
        y = if x <= 12 then 0 + amplitude * (x / 12) else amplitude - amplitude * ((x - 12) / 12)

        return Color3.fromRGB(y, y, y)
    end
    local function _changeLocation()
        if areaQueue:IsLocked() then return end
        if areaQueue:IsEmpty() then return end

        areaQueue:SetLockState(true)

        local location = areaQueue:Pop() :: string

        if location and location ~= "" and location ~= "None" and LocationBook[location] then
            areaEmpty()

            ---// apply sound
            areaAdd(task.spawn(function()
                local owMusic, cbMusic = LocationBook[location].Music, LocationBook[location].CombatMusic
                if owMusic == "_DUNGEON" or cbMusic == "_DUNGEON" then return end

                local musicLib = SoundService.Musics.Areas :: Folder

                local overworldMusic = SoundService.Musics.Overworld :: Sound
                local combatMusic = SoundService.Musics.Combat :: Sound

                local targetSoundOW = musicLib.Overworld:FindFirstChild(owMusic) :: Sound
                local targetSoundCB = musicLib.Combat:FindFirstChild(cbMusic) :: Sound

                if not targetSoundCB or not targetSoundOW then return end

                if overworldMusic.SoundId ~= targetSoundOW.SoundId then
                    HarukaLib:CreateTween(overworldMusic, AssetBook.TweenInfos.twiceHalf, {
                        Volume = 0
                    }):Play()

                    wait(0.3)
                    overworldMusic.SoundId = targetSoundOW.SoundId

                    if combatMusic.Playing then return end

                    overworldMusic:Play()

                    HarukaLib:CreateTween(overworldMusic, AssetBook.TweenInfos.half, {
                        Volume = LocationBook[location].MusicVolume
                    }):Play()
                end
                if combatMusic.SoundId ~= targetSoundCB.SoundId then
                    combatMusic.SoundId = targetSoundCB.SoundId

                    if overworldMusic.Playing then return end

                    combatMusic:Play()
                    combatMusic.Volume = LocationBook[location].CombatMusicVolume
                end
            end))

            ---// apply lighting
            HarukaLib:CreateTween(Lighting, AssetBook.TweenInfos.half, LocationBook[location].LightingInfo):Play()
            HarukaLib:CreateTween(Lighting, AssetBook.TweenInfos.one, {
                ClockTime = LocationBook[location].ClockTime
            }):Play()

            if workspace.Terrain:FindFirstChildOfClass("Clouds") then
                HarukaLib:CreateTween(workspace.Terrain:FindFirstChildOfClass("Clouds"), AssetBook.TweenInfos.one, {
                    Color = _calculateColor(LocationBook[location].LightingInfo.ClockTime)
                }):Play()
            end

            --- apply rain
            Lighting:SetAttribute("RainLevel", LocationBook[location].RainLevel)


            --- apply atmosphere
            if Lighting:FindFirstChildOfClass("ColorCorrectionEffect") then
                HarukaLib:CreateTween(Lighting:FindFirstChildOfClass("ColorCorrectionEffect"), AssetBook.TweenInfos.half, LocationBook[location].AtmosphereInfo.ColorCorrection):Play()
            end
            if Lighting:FindFirstChildOfClass("DepthOfFieldEffect") then
                HarukaLib:CreateTween(Lighting:FindFirstChildOfClass("DepthOfFieldEffect"), AssetBook.TweenInfos.half, LocationBook[location].AtmosphereInfo.DepthOfField):Play()
            end
            if workspace.Terrain:FindFirstChildOfClass("Clouds") then
                HarukaLib:CreateTween(workspace.Terrain:FindFirstChildOfClass("Clouds"), AssetBook.TweenInfos.half, LocationBook[location].AtmosphereInfo.Clouds):Play()
            end
        end

        wait(1.5)
        areaQueue:SetLockState(false)
        _changeLocation()
    end
    areaQueue.ElementAdded:Connect(_changeLocation)

    Add(HarukaLib:Hydrate(char, {
        ["Attr-AreaIn"] = function(region: string)
            areaQueue:Push(region)
        end
    }))
end


function CriRPGLib:_ListenOrbSpawnTracker()
    local orbContainer = Instance.new("Folder")
    orbContainer.Name = "OrbContainer_"..plr.UserId
    orbContainer.Parent = ServerStorage
    Add(orbContainer)

    self.OrbContainer = orbContainer

    Add(Events.PlaceOrb.On(function(data)
        if not char:GetAttribute("IsInCombat") then return end


        local orbId, orbPos = data.OrbId, data.OrbLocationPos
        local orb = RepS.Packages.ClassAttacks:FindFirstChild(orbId, true) :: Model

        if orb == nil then
            warn("Invalid orb Id when spawning")
            return
        end
        if data.OrbUniqueId == nil then
            warn("Invalid orb UniqueId when spawning")
        end
        orb = orb:Clone()

        orb:SetAttribute("HarukaUniqueId", data.OrbUniqueId)
        orb:SetAttribute("Duration", data.OrbDuration)
        orb:PivotTo(CFrame.new(orbPos))

        ClientLib:WeldModel(orb:FindFirstChild("Base") or orb:FindFirstChild("Middle"), orb)

        orb.Parent = orbContainer

        Maid:AddItem(orb, data.OrbDuration)
    end))


    local function _checkCombatState(state: boolean)
        if not state then
            orbContainer.Parent = ServerStorage

            RunService.Heartbeat:Wait()
            orbContainer:ClearAllChildren()
        else
            orbContainer:ClearAllChildren()
            orbContainer.Parent = workspace
        end
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _checkCombatState
    }))
end


function CriRPGLib:_ListenHumanoidTouchedTracker()
    --[[
        I've used workspce:GetPartBoundsInRadius before, but then
        players in community complain about the hitbox and its poor performance.
    ]]
    local orbCD = false
    local animStep = 1

    local dmgCD = false

    Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
        if not hit then return end
        if not hit.Parent then return end

        if not ClientLib:IsCharValid(char) then return end

        if hit.Parent:HasTag("OrbEntity") then
            local orb = hit.Parent
            local whiteList = { "HEAL_ATTACK", "BUFF_ATTACK" }
            local style = orb:GetAttribute("Style") :: string

            if orbCD then return end

            local class = plr:GetAttribute("Class") :: string
            if not table.find(whiteList, style) then
                if style ~= class then return end
            end
            if not ClientLib:IsCharValid(char) then return end

            local humanoid = char.Humanoid :: Humanoid
            local orbUniqueId = orb:GetAttribute("HarukaUniqueId") :: string

            if not orbUniqueId then
                warn("Invalid orb uniqueId when attacking")

                Bindables.CreateNotify:Fire("Invalid Orb UniqueId")
                return
            end


            task.delay(0.25, function()
                humanoid.AutoRotate = true
            end)
            pcall(_fadeOrb, orb)

            Events.RequestToDMGEnemy.Fire({
                OrbUniqueId = orbUniqueId or "nil",
            })

            local SFXId = orb:GetAttribute("SFXId") :: string
            local SFX: Sound = if SFXId then SoundService.SFXs:FindFirstChild(SFXId) else SoundService.SFXs.OrbHit
            SFX:Play()

            if not orb:GetAttribute("DontBounce") then
                humanoid.Jump = true

                if char.PrimaryPart:FindFirstChild("OrbBV") then
                    char.PrimaryPart.OrbBV:Destroy()
                    char.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
                end
                if char.PrimaryPart:FindFirstChild("Dash") then
                    char.PrimaryPart.Dash:Destroy()
                    char.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
                end

                local bounceWeight = 36
                local bounceBuff = char:GetAttribute("OrbBounce") / 100

                bounceWeight *= bounceBuff

                local linearVelocity = Instance.new("LinearVelocity")
                linearVelocity.Name = "OrbBV"
                linearVelocity.Attachment0 = char.PrimaryPart.AlignMoverAttachment
                linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
                linearVelocity.ForceLimitsEnabled = false
                linearVelocity.VectorVelocity = char.Humanoid.MoveDirection * 10 + Vector3.yAxis * bounceWeight
                linearVelocity.Parent = char.PrimaryPart
                Debris:AddItem(linearVelocity, 0.05)

                humanoid.AutoRotate = false

                local customAnim = orb:GetAttribute("CustomAnim") :: string
                if customAnim then
                    Bindables.PlayAnimation:Fire(customAnim)
                else
                    Bindables.PlayAnimation:Fire(`{class}Attack{if animStep == 1 then "" else "2"}`)
                end

                animStep = if animStep == 1 then 2 else 1

                local enemy = char.TargetingEnemy :: ObjectValue?
                if not ClientLib:IsCharValid(enemy.Value) then return end

                char.PrimaryPart.CFrame = HarukaLib:CFLookAt(char.PrimaryPart.Position, enemy.Value.PrimaryPart.Position)
            end

        elseif hit.Parent:HasTag("DMGEntity") then
            if dmgCD then return end

            dmgCD = true
            task.delay(0.6, function()
                dmgCD = false
            end)

            local uniqueId = hit.Parent:GetAttribute("HarukaUniqueId") :: string
            if uniqueId == nil then
                local ancestor = hit.Parent:FindFirstAncestorOfClass("Model")
                if ancestor then
                    uniqueId = ancestor:GetAttribute("HarukaUniqueId")
                end
            end

            local shouldPierce = false
            if hit.Parent:HasTag("PierceEntity") then
                shouldPierce = true
            end

            local DoTStatus = "Normal"
            if hit.Parent:HasTag("PoisonEntity") then
                DoTStatus = "Poison"
            end
            if hit.Parent:HasTag("BurnEntity") then
                DoTStatus = "Burn"
            end
            if hit.Parent:HasTag("FreezeEntity") then
                DoTStatus = "Freeze"
            end
            if hit.Parent:HasTag("ShockingEntity") then
                DoTStatus = "Shocking"
            end

            Events.RequestToDMGPlayer.Fire({
                ProjectileUniqueId = uniqueId,
                IsPierce = shouldPierce,
                DoTStatus = DoTStatus
            })
        end
    end))
end


function CriRPGLib:_ListenProjectileSpawnTracker()
    local projectileContainer = Instance.new("Folder")
    projectileContainer.Name = "ProjectileContainer_"..plr.UserId
    projectileContainer.Parent = ServerStorage
    Add(projectileContainer)

    Add(Events.SpawnATKs.On(function(data)
        if not char:GetAttribute("IsInCombat") then return end

        projectileContainer = projectileContainer or workspace.Terrain


        local projectileId, projectileCF = data.ProjectileId, data.ProjectileCF
        local projectileOwner = data.ProjectileOwner

        if projectileOwner == nil then return end
        if not ClientLib:IsCharValid(projectileOwner) then return end

        local projectile = RepS.Packages.EnemyAttacks:FindFirstChild(projectileId, true) :: Model

        if not projectile then
            warn("[ProjectileLib] You might forgot to add :Clone() to "..projectileId.."?")
            return
        end
        projectile = projectile:Clone() :: Model
        Maid:AddItem(projectile, 10)


        projectile:SetAttribute("HarukaUniqueId", data.ProjectileUniqueId)
        projectile:SetAttribute("CombatLocation", projectileOwner:GetAttribute("CombatLocation"))
        projectile:PivotTo(projectileCF)


        local ownerSymbol = Instance.new("ObjectValue")
        ownerSymbol.Name = "Owner"
        ownerSymbol.Value = projectileOwner
        ownerSymbol.Parent = projectile

        projectile:AddTag("EnemyProjectile")
        projectile.Parent = projectileContainer
    end))
    Add(CollectionService:GetInstanceAddedSignal("EnemyProjectile"):Connect(function(projectile: Model)
        if ProjectileLib[projectile.Name] then
            local success, err = pcall(ProjectileLib[projectile.Name], projectile, projectileContainer)
            if not success and RunService:IsStudio() then
                warn(err)
            end
        else
            warn("Invalid projectile ID: ".. projectile.Name)
        end
    end))


    local function _checkCombatState(state: boolean)
        if not state then
            projectileContainer.Parent = ServerStorage

            RunService.Heartbeat:Wait()
            projectileContainer:ClearAllChildren()
        else
            projectileContainer:ClearAllChildren()
            projectileContainer.Parent = workspace
        end
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _checkCombatState
    }))
end


function CriRPGLib:_ListenUniProjectileSpawnTracker()
    local projectileContainer = Instance.new("Folder")
    projectileContainer.Name = "UniProjectileContainer_"..plr.UserId
    projectileContainer.Parent = workspace
    Add(projectileContainer)


    Add(Events.SpawnUniATKs.On(function(data)
        projectileContainer = projectileContainer or workspace.Terrain


        local projectileId, projectileCF = data.ProjectileId, data.ProjectileCF
        local projectileOwner = data.ProjectileOwner


        if projectileOwner == nil then return end
        if not ClientLib:IsCharValid(projectileOwner) then return end

        local projectile = RepS.Packages.EnemyAttacks:FindFirstChild(projectileId, true) :: Model

        if not projectile then
            warn("[ProjectileLib] You might forgot to add :Clone() to "..projectileId.."?")
            return
        end
        projectile = projectile:Clone() :: Model
        Maid:AddItem(projectile, 5)


        projectile:SetAttribute("HarukaUniqueId", data.ProjectileUniqueId)
        projectile:SetAttribute("CombatLocation", projectileOwner:GetAttribute("CombatLocation"))
        projectile:PivotTo(projectileCF)


        local ownerSymbol = Instance.new("ObjectValue")
        ownerSymbol.Name = "Owner"
        ownerSymbol.Value = projectileOwner
        ownerSymbol.Parent = projectile

        projectile:AddTag("EnemyProjectile")
        projectile.Parent = projectileContainer
    end))
end


function CriRPGLib:_ListenTrussTracker()
    Add(HarukaLib:Hydrate(char, {
        ["Attr-CanClimb"] = function(state: boolean)
            state = state or false

            for _, truss: TrussPart in CollectionService:GetTagged("TrussEntity") do
                truss.CanCollide = state
            end
        end
    }))
end


function CriRPGLib:_ListenClassSPSceneTracker()
    Add(Events.PlayClassSPScene.On(function(data)
        local sceneId = data.SceneId

        if ClassSPSceneLib[sceneId] == nil then
            warn(`Invalid class SP scene id: {sceneId}`)
            return
        end

        local success, err = pcall(ClassSPSceneLib[sceneId], data.Caster, data.ProjectileUniqueId)
        if not success and RunService:IsStudio() then
            warn(err)
        end
    end))
end


function CriRPGLib:_ListenEnemyFacingTracker()
    Add(Events.FaceToTargetingEnemy.On(function()
        local targeting = char.TargetingEnemy :: ObjectValue?

        if not ClientLib:IsCharValid(targeting.Value) then return end

        targeting = targeting.Value :: Model

        if targeting.PrimaryPart then
            char.Humanoid.AutoRotate = false
            char.PrimaryPart.CFrame = HarukaLib:CFLookAt(char.PrimaryPart.Position, targeting.PrimaryPart.Position)

            wait(0.2)
            char.Humanoid.AutoRotate = true
        end
    end))
end



function CriRPGLib:_ListenCombatStateTreesTracker()
    local function _clearAnyTransparentTrees()
        for _, tree: Model in CollectionService:GetTagged("TreeEntity_Transparent") do
            tree:RemoveTag("TreeEntity_Transparent")

            for _, part: BasePart in tree:GetDescendants() do
                if HarukaLib:IsBasePartType(part) then
                    part.LocalTransparencyModifier = 0

                    local material = part.Material
                    local oriMaterial = part:GetAttribute("OriMaterial")

                    material = oriMaterial or material

                    if material ~= Enum.Material.Grass then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = function(state: boolean)
            if state then
                for _, tree: Model in CollectionService:GetTagged("TreeEntity") do
                    local distance = plr:DistanceFromCharacter(tree.WorldPivot.Position)

                    if distance < 115.99 and distance > 0 then
                        tree:AddTag("TreeEntity_Transparent")

                        for _, part: BasePart in tree:GetDescendants() do
                            if HarukaLib:IsBasePartType(part) then
                                part.CanCollide = false
                                part.LocalTransparencyModifier = 0.7
                            end
                        end
                    end
                end
            else
                _clearAnyTransparentTrees()
            end
        end
    }))
    Add(_clearAnyTransparentTrees)
end


function CriRPGLib:_ListenSpellExtraJumpOnlyTracker()
    Add(Events.Spell_ExtraJumpSupport.On(function()
        SoundService.SFXs.EXP:Play()

        local vel = char.PrimaryPart.AssemblyLinearVelocity
        vel = vel.Y
        if vel > 0 then
            vel = 0
        end

        vel = math.abs(vel)
        vel = math.min(50, vel)

        char.PrimaryPart.AssemblyLinearVelocity = Vector3.zero


        local linearVelocity = Instance.new("LinearVelocity")
        linearVelocity.Name = "DoubleJumpVel"
        linearVelocity.Attachment0 = char.PrimaryPart.AlignMoverAttachment
        linearVelocity.ForceLimitsEnabled = false
        linearVelocity.VectorVelocity = char.PrimaryPart.CFrame.LookVector + Vector3.yAxis * 80 + Vector3.yAxis * vel
        linearVelocity.Parent = char.PrimaryPart
        Debris:AddItem(linearVelocity, 0.05)
    end))
end


function CriRPGLib:_ListenDungeonStarterTracker()
    if not workspace:GetAttribute("DungeonId") then return end


    local function _playOverworldMusic(soundId: string)
        local overworldMusic = SoundService.Musics.Overworld :: Sound

        overworldMusic.SoundId = soundId
        overworldMusic.Volume = 0
        overworldMusic:Play()

        HarukaLib:CreateTween(overworldMusic, AssetBook.TweenInfos.one, {
            Volume = 0.7
        }):Play()
    end
    Add(Events.DUNGEON_StartDungeon.On(function()
        _playOverworldMusic(SoundService.Musics.Overworld.SoundId)
    end))
    Add(Events.DUNGEON_StartBossFight.On(function()
        SoundService.Musics.Combat.SoundId = SoundService.Musics.BossCombat.SoundId

        _playOverworldMusic(SoundService.Musics.BossCombat.SoundId)
    end))
    Add(Events.DUNGEON_EndDungeon.On(function()
        SoundService.Musics.Combat.SoundId = SoundService.Musics.Victory.SoundId

        _playOverworldMusic(SoundService.Musics.Victory.SoundId)
    end))
end


CriRPGLib:Init()


char:SetAttribute("Haruka_CriRPGClientInited", true)
