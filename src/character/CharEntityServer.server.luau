
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)

local Add, Empty = HarukaLib.Bin()

local isDead = false



type CharLibClass = {
    Funcs: { () -> nil },

    Destroy: (self: CharLibClass) -> nil,
    Init: (self: CharLibClass) -> nil,

	_RagdollInit: (self: CharLibClass) -> nil,
	_TriggerRagdoll: (self: CharLibClass) -> nil,
}


local CharLib = {} :: CharLibClass
CharLib.Funcs = {}



Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		CharLib:Destroy()
	end
end))
Add(script.Destroying:Connect(function()
    CharLib:Destroy()
end))


function CharLib:Init()
	self:_RagdollInit()

	for _, func: () -> nil in self.Funcs do
        task.spawn(func)
    end

	char:SetAttribute("Haruka_CharServerInited", true)
end



function CharLib:Destroy()
    if isDead then return end

    isDead = true
    Empty()

	ServerBindables.PlayerDied:Fire(plr.Name)
    ServerBindables.RToSpawnChar:Fire(plr)

	char.PlayerDied:Fire()
end


--// Private functions


table.insert(CharLib.Funcs, function()
	Add(char.Humanoid.HealthChanged:Connect(function(health: number)
		if health <= 0 then
			pcall(CharLib._TriggerRagdoll, CharLib)

			CharLib:Destroy()
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
                CharLib:Destroy()
                return
            end
        else
            CharLib:Destroy()
        end
	end))
end)



function CharLib:_RagdollInit()
	local humanoid = char.Humanoid :: Humanoid

	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
end


function CharLib:_TriggerRagdoll()
	local humanoid = char.Humanoid :: Humanoid

	local attachmentCFrames = {
		["Neck"] = {CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1)},
		["Left Shoulder"] = {CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1), CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)},
		["Right Shoulder"] = {CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
		["Left Hip"] = {CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
		["Right Hip"] = {CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
	}

	local function _createColliderPart(part: BasePart)
		if not part then return end

		local rp = Instance.new("Part")
		rp.Name = "ColliderPart"
		rp.Size = part.Size / 1.7
		rp.Massless = true
		rp.CFrame = part.CFrame
		rp.Transparency = 1

		local wc = Instance.new("WeldConstraint")
		wc.Part0 = rp
		wc.Part1 = part

		wc.Parent = rp
		rp.Parent = part
	end
	for _, motor: Motor6D in char:QueryDescendants("Motor6D") do
		if not attachmentCFrames[motor.Name] then return end

		motor.Enabled = false

		local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
		a0.CFrame = attachmentCFrames[motor.Name][1]
		a1.CFrame = attachmentCFrames[motor.Name][2]

		a0.Name = "RagdollAttachment"
		a1.Name = "RagdollAttachment"

		_createColliderPart(motor.Part1)

		local b = Instance.new("BallSocketConstraint")
		b.Attachment0 = a0
		b.Attachment1 = a1
		b.Name = "RagdollConstraint"

		b.Radius = 0.15
		b.LimitsEnabled = true
		b.TwistLimitsEnabled = false
		b.MaxFrictionTorque = 0
		b.Restitution = 0
		b.UpperAngle = 90
		b.TwistLowerAngle = -45
		b.TwistUpperAngle = 45

		if motor.Name == "Neck" then
			b.TwistLimitsEnabled = true
			b.UpperAngle = 45
			b.TwistLowerAngle = -70
			b.TwistUpperAngle = 70
		end

		a0.Parent = motor.Part0
		a1.Parent = motor.Part1
		b.Parent = motor.Parent
	end

	humanoid.AutoRotate = false
end


table.insert(CharLib.Funcs, function()
    Add(HarukaLib.Clock(0.5, function()
		if not ServerLib:IsModelValid(char) then return end
		if not plr then return end


		if char:GetAttribute("IsInCombat") then return end


        local regionIn = HarukaLib:IsInRegion(char.PrimaryPart.Position, CollectionService:GetTagged("ZoneEntity"))
        if regionIn then
            if char:GetAttribute("AreaIn") == regionIn.Name then return end

            plr:SetAttribute("LastSeen", regionIn.Name)
            char:SetAttribute("AreaIn", regionIn.Name)
        end
    end))
end)



table.insert(CharLib.Funcs, function()
	local event = Instance.new("BindableEvent")
	event.Name = "EnemyGotHit"
	event.Parent = script

	local function _checkAndAward(badgeId: number)
		if not plr:GetAttribute("BADGE_"..badgeId) then
			plr:SetAttribute("BADGE_"..badgeId, true)

			ServerLib:GiveBadge(badgeId, plr)
		end
	end

	Add(HarukaLib:Hydrate(plr, {
		["Attr-Gold"] = function(val: number)
			val = val or 0

			if val >= 1000 then
				_checkAndAward(AssetBook.BadgeIds.GoldGatherer)
			end
			if val >= 1000 * 100 then
				_checkAndAward(AssetBook.BadgeIds.GoldCollector)
			end
		end,
		["Attr-CombatWonTimes"] = function(val: number)
			val = val or 0

			if val >= 100 then
				_checkAndAward(AssetBook.BadgeIds.Fighter)
			end
		end
	}))
	Add(event.Event:Connect(function(_, attacker: Model, dmgProps: {
		DMG: number,
		DMGType: "DMG" | "Magic",
		Attacker: string
	})
		if script == nil then return end
		if script.Parent == nil then return end
		if attacker ~= char then return end
		if not dmgProps then return end
		if not dmgProps.DMG then return end
		if not dmgProps.DMGType then return end
		if not dmgProps.Attacker then return end
		if dmgProps.Attacker ~= "ClassAttacks" then return end


		if dmgProps.DMG >= 1000 then
			_checkAndAward(AssetBook.BadgeIds.StoneBreaker)
		end
	end))
end)


CharLib:Init()