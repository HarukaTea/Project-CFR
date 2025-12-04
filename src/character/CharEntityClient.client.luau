
repeat task.wait() until workspace:GetAttribute("Haruka_PlayerClientInited")


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")


local Events = require(ReplicatedStorage.HarukaShared.Library.Events)
local Bindables = require(ReplicatedStorage.HarukaShared.Library.Bindables)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer

local Add, Empty = HarukaLib.Bin()

local wait = task.wait

repeat wait() until char:HasTag("PlayerCharEntity")


type CharLibClass = {
    Funcs: { () -> nil },

    Destroy: (self: CharLibClass) -> nil,
    __Destroy: (self: CharLibClass) -> nil,
    Init: (self: CharLibClass) -> nil,
    _InitUI: (self: CharLibClass) -> nil,
    __Init: (self: CharLibClass) -> nil,
}


local CharLib = {} :: CharLibClass
CharLib.Funcs = {}


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		pcall(CharLib.__Destroy, CharLib)

        CharLib:Destroy()
	end
end))
Add(script.Destroying:Connect(function()
    pcall(CharLib.__Destroy, CharLib)

    CharLib:Destroy()
end))



function CharLib:Init()
    for _, func: () -> nil in self.Funcs do
        task.spawn(func)
    end


    Add(char.Humanoid.HealthChanged:Connect(function(health: number)
        if health <= 0 then
            pcall(self.__Destroy, self)
            pcall(self.Destroy, self)
            pcall(self._TriggerRagdoll, self)
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
                pcall(self.__Destroy, self)
                pcall(self.Destroy, self)
                return
            end
        else
            pcall(self.__Destroy, self)
            pcall(self.Destroy, self)
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
    Bindables.UpdateCameraPart:Fire(ReplicatedStorage.Packages.Unloads.ResetCamera)

    SoundService.Musics.Overworld:Play()
    CharLib:__Init_Abyss()

    local camera = workspace.CurrentCamera
    if camera:FindFirstChild("DeathBlur") then
        camera.DeathBlur:Destroy()
    end
end



function CharLib:__Init_Abyss()
    local abyssId = workspace:GetAttribute("AbyssId")
    local dungeonId = workspace:GetAttribute("DungeonId")

    if (abyssId or dungeonId) then
        SoundService.Musics.Overworld:Stop()
    end

    local abyssStarted = workspace:GetAttribute("AbyssStarted")
    local dungeonStarted = workspace:GetAttribute("DungeonStarted")
    if (abyssId or dungeonId) and (abyssStarted or dungeonStarted) then
        SoundService.Musics.Overworld:Play()
    end
end


function CharLib:_InitUI()
    for _, module: ModuleScript in ReplicatedStorage.HarukaShared.UIAtlas.UI:GetChildren() do
		if string.find(module.Name, ".spec") then continue end
        if string.find(module.Name, "_local") then continue end
        if string.find(module.Name, "_preload") then continue end


        Promise.try(function()
            local clear = require(module)(plr)
            if clear == nil then
                warn("Failed to load UI clear module: "..module.Name)
                return
            end

            Add(clear)
        end):catch(function(err)
            warn(tostring(err))
        end)
	end
end

function CharLib:__Destroy()
    Events.ForceResetPlayer_C.Fire()

    Bindables.UpdateCameraPart:Fire(ReplicatedStorage.Packages.Unloads.ResetCamera)
    Bindables.PlaySound:Fire(ReplicatedStorage.Packages.Unloads.ResetSound)
    Bindables.PlaySound:Fire(SoundService.SFXs.Death)


    local deathBlur = Instance.new("BlurEffect")
    deathBlur.Name = "DeathBlur"
    deathBlur.Size = 15.99
    deathBlur.Parent = workspace.CurrentCamera

    if workspace:GetAttribute("AllowFreecam") then
        local Freecam = require(ReplicatedStorage.HarukaShared.Shared.Freecam)

        Freecam.Toggle(false)
    end
end




table.insert(CharLib.Funcs, function()
    local humanoid = char.Humanoid :: Humanoid
    local animator = humanoid:WaitForChild("Animator") :: Animator
    local animationsClass = ReplicatedStorage.Packages.Anims.ClassAnims :: Folder
    local animationsChar = ReplicatedStorage.Packages.Anims.CharAnims :: Folder


    local self = {}

    self.Animator = animator

    self.ClassAttackAnims = {}
    for _, anim: Animation in animationsClass:QueryDescendants("Animation") do
        if string.find(anim.Name, "Attack") then
            self.ClassAttackAnims[anim.Name] = animator:LoadAnimation(anim)
        end
    end
    self.ClassAttackAnims.MagicCasted1 = animator:LoadAnimation(animationsClass:FindFirstChild("MagicCasted1", true))
    self.ClassAttackAnims.MagicCasted2 = animator:LoadAnimation(animationsClass:FindFirstChild("MagicCasted2", true))
    self.ClassAttackAnims.Dash = animator:LoadAnimation(animationsClass:FindFirstChild("Dash", true))
    for _, anim in animationsClass:QueryDescendants("ObjectValue") do
        if string.find(anim.Name, "Attack") then
            self.ClassAttackAnims[anim.Name] = self.ClassAttackAnims[anim.Value.Name]
        end
    end
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
    } :: {[string]: AnimationTrack}
    Add(self.CharAnims)

    for animId, anim in self.CharAnims do
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
        if animContainer:FindFirstChild("Run") then
            if animContainer.Run:IsA("Animation") then
                CLASS_ANIMS[class].Run = animator:LoadAnimation(animContainer.Run)
            elseif animContainer.Run:IsA("ObjectValue") then
                CLASS_ANIMS[class].Run = animator:LoadAnimation(animContainer.Run.Value)
            end
        else
            CLASS_ANIMS[class].Run = animator:LoadAnimation(animationsChar.Run)
        end
    end
    self.CLASS_ANIMS = CLASS_ANIMS
    Add(self.CLASS_ANIMS)

    self.OldAnim = nil :: AnimationTrack?


    local function _playAnim(anim: string)
        if not self.ClassAttackAnims[anim] then warn(`Can't found animation: {anim} !`) return end

        self.ClassAttackAnims[anim]:Play()
    end
    Add(Bindables.PlayClassAnim:Connect(_playAnim))
    Add(Events.PlayClassAnim_S.On(_playAnim))



    local charAnims = self.CharAnims

    local function _playCharAnim(anim: AnimationTrack)
        if self.OldAnim ~= anim then
            if self.OldAnim then self.OldAnim:Stop() end
            if anim then anim:Play() end

            self.OldAnim = anim
	    end
    end
	Add(humanoid.Running:Connect(function()
        local class = plr:GetAttribute("Class") :: string
        local isInCombat = char:GetAttribute("IsInCombat") :: boolean


		if humanoid.MoveDirection.Magnitude > 0 then
            if isInCombat then
                _playCharAnim(CLASS_ANIMS[class].Run)
            else
                _playCharAnim(charAnims.Run)
            end
		else
            _playCharAnim(charAnims.Idle)
		end
	end))
	Add(humanoid.Climbing:Connect(function(vel)
		if vel ~= 0 then
			_playCharAnim(charAnims.Climb)
		else
			charAnims.Climb:AdjustSpeed(0)
		end
	end))
	Add(humanoid.Jumping:Connect(function()
        _playCharAnim(charAnims.Jump)
	end))
	Add(humanoid.FreeFalling:Connect(function()
        _playCharAnim(charAnims.Fall)
	end))
	Add(humanoid.Seated:Connect(function()
		_playCharAnim(charAnims.Sit)
	end))


	_playCharAnim(charAnims.Idle)



    Add(Bindables.PlayerChatted:Connect(function(msg: string, sender: Player)
        if sender ~= plr then return end

        msg = tostring(msg)

        local emote = ""

        -- don't ask me why this messy code is here, because of dawg luau-lsp type-checking
        if msg == "/e dance" then
            emote = "dance"..math.random(1, 3)
        end
        if not msg == "/e dance" then
            if (string.sub(msg, 1, 3) == "/e ") then
                emote = string.sub(msg, 4)

            elseif (string.sub(msg, 1, 7) == "/emote ") then
                emote = string.sub(msg, 8)
            end
        end


        local whiteList = { "dance1", "dance2", "dance3", "cheer", "point", "wave", "laugh" }

        if (charAnims.Idle.IsPlaying and table.find(whiteList, emote)) then
            _playCharAnim(charAnims[emote])
        end
    end))
end)


table.insert(CharLib.Funcs, function()
    local humanoid = char.Humanoid :: Humanoid

    local isWalking = false
    local lastMaterialStanding = nil

    Add(humanoid.Running:Connect(function(speed: number)
        isWalking = speed > humanoid.WalkSpeed / 2
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

            for _, sound: Sound in SoundService.FS_SFXs:GetChildren() do
                if not sound:IsA("Sound") then continue end
                sound.Playing = false
            end
        end
    end))
    Add(function()
        for _, sound: Sound in SoundService.FS_SFXs:GetChildren() do
            if not sound:IsA("Sound") then continue end
            sound.Playing = false
        end
    end)
end)


function CharLib:_TriggerRagdoll()
    char.Torso:ApplyImpulse(char.Torso.CFrame.LookVector * -100)
end



CharLib:Init()



char:SetAttribute("Haruka_CharClientInited", true)