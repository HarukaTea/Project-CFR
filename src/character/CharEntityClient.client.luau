repeat task.wait() until workspace:GetAttribute("Haruka_PlayerClientInited")


local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")


local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local Events = require(ReplicatedStorage.HarukaShared.Library.Events)
local Bindables = require(ReplicatedStorage.HarukaShared.Library.Bindables)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer

local Add, Empty = HarukaLib.Bin()

local wait = task.wait

repeat wait() until char:HasTag("PlayerCharEntity")


local CharLib = {}

function CharLib:Init()
    for funcId: string, func: (self) -> nil in CharLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            func(self)
        end
    end


    Add(char.Humanoid.HealthChanged:Connect(function(health: number)
        if health <= 0 then
            self:__Destroy()
            self:Destroy()
            self:_TriggerRagdoll()

            char.Humanoid.Health = -1
        end
    end))
    Add(char.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
        local newParent = char
        if newParent then
            if newParent.PrimaryPart == nil and newParent:FindFirstChild("Humanoid") then
                newParent.Humanoid.Health = -1
                return
            end
            if newParent.PrimaryPart == nil and not newParent:FindFirstChild("Humanoid") then
                self:__Destroy()
                self:Destroy()
                return
            end
        else
            self:__Destroy()
            self:Destroy()
        end
    end))


    self:__Init()
    self:_InitUI()
end


function CharLib:Destroy()
    Empty()
end


--// Private functions


function CharLib:__Init()
    SoundService.Musics.Overworld:Play()

    Lighting.ColorShift_Bottom = Color3.fromRGB(220, 255, 255)
    Lighting.ColorShift_Top = Color3.fromRGB(220, 255, 255)

    local camera = workspace.CurrentCamera
    if camera:FindFirstChild("DeathBlur") then
        camera.DeathBlur:Destroy()
    end
end


function CharLib:_InitUI()
    self.UIAdd, self.UIEmpty = HarukaLib.Bin()

    for _, module: ModuleScript in ReplicatedStorage.HarukaShared.UIAtlas.UI:GetChildren() do
		if string.find(module.Name, ".spec") then warn(module.Name) continue end
        if string.find(module.Name, "_local") then continue end
        if string.find(module.Name, "_preload") then continue end


        Promise.try(function()
            local clear = require(module)(plr)
            if clear == nil then
                warn("Failed to load UI clear module: "..module.Name)
                return
            end

            self.UIAdd(clear)
        end):catch(function(err)
            warn(tostring(err))
        end)
	end
end

function CharLib:__Destroy()
    self.UIEmpty()

    Events.RequestToForceReset.Fire()

    Bindables.PlayCameraCutscene:Fire(ReplicatedStorage.Packages.Unloads.ResetCamera)
    Bindables.PlaySound:Fire(ReplicatedStorage.Packages.Unloads.ResetSound)
    Bindables.PlaySound:Fire(SoundService.SFXs.Death)


    local deathBlur = Instance.new("BlurEffect")
    deathBlur.Name = "DeathBlur"
    deathBlur.Size = 15.99
    deathBlur.Parent = workspace.CurrentCamera

    Lighting.ColorShift_Bottom = Color3.new(1, 0, 0)
    Lighting.ColorShift_Top = Color3.new(1, 0, 0)


    if workspace:GetAttribute("AllowFreecam") then
        local Freecam = require(ReplicatedStorage.HarukaShared.Library.Freecam)

        Freecam.Toggle(false)
    end
end




function CharLib:_ListenAnimateTracker()
    local humanoid = char.Humanoid :: Humanoid
    local animator = humanoid:WaitForChild("Animator") :: Animator
    local animationsClass = ReplicatedStorage.Packages.Anims.ClassAnims :: Folder
    local animationsChar = ReplicatedStorage.Packages.Anims.CharAnims :: Folder

    self.Animator = animator

    self.ClassAttackAnims = {}
    for _, anim: Animation in animationsClass:GetDescendants() do
        if string.find(anim.Name, "Attack") and anim:IsA("Animation") then
            self.ClassAttackAnims[anim.Name] = animator:LoadAnimation(anim)
        end
    end
    self.ClassAttackAnims.MagicCasted1 = animator:LoadAnimation(animationsClass:FindFirstChild("MagicCasted1", true))
    self.ClassAttackAnims.MagicCasted2 = animator:LoadAnimation(animationsClass:FindFirstChild("MagicCasted2", true))
    for _, anim: AnimationTrack in self.ClassAttackAnims do
        anim.Looped = false
        anim.Priority = Enum.AnimationPriority.Action2
    end
    Add(self.ClassAttackAnims)


    self.CharAnims = {
        Idle = animator:LoadAnimation(animationsChar.Idle1),
        Fall = animator:LoadAnimation(animationsChar.Fall),
        Jump = animator:LoadAnimation(animationsChar.Jump),
        Run = animator:LoadAnimation(animationsChar.Run),
        Sit = animator:LoadAnimation(animationsChar.Sit),
        Climb = animator:LoadAnimation(animationsChar.Climb),

        dance1 = animator:LoadAnimation(animationsChar.dance1),
        dance2 = animator:LoadAnimation(animationsChar.dance2),
        dance3 = animator:LoadAnimation(animationsChar.dance3),
        cheer = animator:LoadAnimation(animationsChar.cheer),
        point = animator:LoadAnimation(animationsChar.point),
        wave = animator:LoadAnimation(animationsChar.wave),
        laugh = animator:LoadAnimation(animationsChar.laugh),
    }
    Add(self.CharAnims)
    for animId: string, anim: AnimationTrack in self.CharAnims do
        if string.find(animId, "dance") then
            anim.Looped = true
        end
    end
    self.CharAnims.cheer.Looped = false
    self.CharAnims.point.Looped = false
    self.CharAnims.wave.Looped = false
    self.CharAnims.laugh.Looped = false


    local CLASS_ANIMS = {}
    for _, animContainer: Folder in animationsClass:GetChildren() do
        local class = animContainer.Name :: string


        CLASS_ANIMS[class] = {}

        CLASS_ANIMS[class].Idle = animator:LoadAnimation(animContainer:FindFirstChild("Idle1") or animationsChar.Idle1)
        CLASS_ANIMS[class].Run = animator:LoadAnimation(animContainer:FindFirstChild("Run") or animationsChar.Run)
        CLASS_ANIMS[class].Jump = animator:LoadAnimation(animContainer:FindFirstChild("Jump") or animationsChar.Jump)
    end
    self.CLASS_ANIMS = CLASS_ANIMS
    Add(self.CLASS_ANIMS)


    self.OldAnim = nil :: AnimationTrack?


    local function _playAnim(anim: AnimationTrack, transitionTime: number)
        if self.OldAnim ~= anim then
            if self.OldAnim then self.OldAnim:Stop(transitionTime) end
            if anim then anim:Play(transitionTime) end

            self.OldAnim = anim
	    end
    end
    local function playAnim(anim: string)
        if not self.ClassAttackAnims[anim] then warn(`Can't found animation: {anim} !`) return end

        self.ClassAttackAnims[anim]:Play()
    end
    Add(Bindables.PlayAnimation:Connect(playAnim))
    Add(Events.PlayAnimation.On(function(data)
        playAnim(data.AnimId)
    end))




    local charAnims = self.CharAnims
	Add(humanoid.Running:Connect(function()
        local class = plr:GetAttribute("Class") :: string
        local isInCombat = char:GetAttribute("IsInCombat") :: boolean


		if humanoid.MoveDirection.Magnitude > 0 then
            if isInCombat then
                _playAnim(CLASS_ANIMS[class].Run, 0.1)
            else
                _playAnim(charAnims.Run, 0.1)
            end
		else
            _playAnim(charAnims.Idle, 0.1)
		end
	end))
	Add(humanoid.Climbing:Connect(function(vel)
		if vel ~= 0 then
			_playAnim(charAnims.Climb, 0.1)
		else
			charAnims.Climb:AdjustSpeed(0)
		end
	end))
	Add(humanoid.Jumping:Connect(function()
        _playAnim(charAnims.Jump, 0.1)
	end))
	Add(humanoid.FreeFalling:Connect(function()
        _playAnim(charAnims.Fall, 0.1)
	end))
	Add(humanoid.Seated:Connect(function()
		_playAnim(charAnims.Sit, 0.1)
	end))


	_playAnim(charAnims.Idle, 0.1)



    Add(Bindables.PlayerChatted:Connect(function(msg: string, sender: Player)
        if sender ~= plr then return end

        local emote = ""
        if msg == "/e dance" then
            emote = "dance"..math.random(1, 3)

        elseif (string.sub(msg, 1, 3) == "/e ") then
            emote = string.sub(msg, 4)

        elseif (string.sub(msg, 1, 7) == "/emote ") then
            emote = string.sub(msg, 8)
        end

        local whiteList = { "dance1", "dance2", "dance3", "cheer", "point", "wave", "laugh" }

        if (charAnims.Idle.IsPlaying and table.find(whiteList, emote)) then
            _playAnim(charAnims[emote], 0.1)
        end
    end))
end


function CharLib:_ListenFootstepTracker()
    local humanoid = char.Humanoid :: Humanoid

    local isWalking = false
    local lastMaterialStanding = nil


    Add(humanoid.Running:Connect(function(speed: number)
        if speed > humanoid.WalkSpeed / 2 then
            isWalking = true
        else
            isWalking = false
        end
    end))

    local lastMaterialSFX = nil
    Add(RunService.Heartbeat:Connect(function()
        if isWalking then
            local materialStanding = humanoid.FloorMaterial.Name

            if materialStanding ~= lastMaterialStanding and lastMaterialStanding ~= nil then
                SoundService.FS_SFXs[lastMaterialStanding].Playing = false
            end

            local materialSFX = SoundService.FS_SFXs[materialStanding] :: Sound
            materialSFX.PlaybackSpeed = 16 / 12
            materialSFX.Playing = true

            lastMaterialSFX = materialSFX
            lastMaterialStanding = materialStanding
        else
            if lastMaterialSFX then
                lastMaterialSFX.Playing = false
                lastMaterialSFX = nil
            end
        end
    end))
    Add(function()
        for _, sound: Sound in SoundService.FS_SFXs:GetChildren() do
            sound.Playing = false
        end
    end)
end


function CharLib:_TriggerRagdoll()
    char.Torso:ApplyImpulse(char.Torso.CFrame.LookVector * -100)
end



CharLib:Init()



char:SetAttribute("Haruka_CharClientInited", true)