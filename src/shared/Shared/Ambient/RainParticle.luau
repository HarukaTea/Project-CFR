--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local wait = task.wait

--// Variables

local rainCastContainer = Instance.new("Folder")
rainCastContainer.Name = "RainCast_Projectile"
rainCastContainer.Parent = workspace.Terrain


local rainCastPart = RepS.Packages.Unloads.RainCast :: BasePart
rainCastPart.Size = Vector3.new(45, 1, 45)


local rainParts = {
	[1] = rainCastPart:Clone(),
	[2] = rainCastPart:Clone(),
	[3] = rainCastPart:Clone(),
	[4] = rainCastPart:Clone(),
}
for _, part: BasePart in rainParts do
	part.CFrame = CFrame.new(Vector3.one * 1599 * 40)
	part.Parent = rainCastContainer
end

--// Helper functions

local function _replicatePos(cameraCFrame: CFrame)
	local CF = cameraCFrame + Vector3.yAxis * 50


	rainParts[1].CFrame = CF
	rainParts[2].CFrame = CF + (CF.RightVector * 45)
	rainParts[3].CFrame = CF - (CF.RightVector * 45)
	rainParts[4].CFrame = CF + (CF.LookVector * 45)
end
local function _rayCast(pos: Position)
	local rayResult = workspace:Raycast(pos, Vector3.yAxis * -50)
	local check = true

	if rayResult then
		if rayResult.Position.Y - (pos - Vector3.yAxis * 50).Y < 5 then
			check = true
		end
		check = false
	end

	return check
end



--// Constructor

local Particles = {}
Particles.__index = Particles


function Particles.new()
	local self = setmetatable({}, Particles)

	self.RainCastParts = rainParts
	self.RainCastContainer = rainCastContainer

	self.Add, self.Empty = HarukaLib.Bin()

	self.Enabled = false

	return self
end


function Particles:Enable()
	if self.Enabled then return end

	self.Enabled = true

	self.Add(RS.Heartbeat:Connect(function()
		local camCF = workspace.CurrentCamera.CFrame
		local _, ry, _ = camCF:ToOrientation()
		local CF = CFrame.new(camCF.Position) * CFrame.Angles(0, ry, 0).Rotation

		_replicatePos(CF)
	end))

	self.Add(task.spawn(function()
		while wait(0.2) do
			for _, part: BasePart in self.RainCastParts do
				part.Parent = if _rayCast(part.Position) then rainCastContainer else script
			end
		end
	end))
end


function Particles:Disable()
	self.Enabled = false
	self.Empty()
end


function Particles:SetRainCastParticleRate(rate: number)
	for _, part: BasePart in self.RainCastParts do
		for _, particle: ParticleEmitter in part:GetDescendants() do
			if particle:IsA("ParticleEmitter") then
				particle.Rate = rate
			end
		end
	end
end


return Particles
