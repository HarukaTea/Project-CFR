--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local wait = task.wait

--// Helper functions

local function _planeLookVector(cframe: CFrame) : Vector3
    return Vector3.new(cframe.LookVector.X, 0, cframe.LookVector.Z).Unit
end
local function _createSplash(splashCache: table, seed: Random, rate: number)
	local camCF = workspace.CurrentCamera.CFrame
	local camPos = camCF.Position
		+ (_planeLookVector(camCF) * 50)

	local pos = camPos + Vector3.new(seed:NextInteger(-50, 50), 0, seed:NextInteger(-50, 50))
	local rayResult = ClientLib:FindGroundByRay(pos)

	if rayResult then
		local part = splashCache:Get() :: BasePart

		part.Position = rayResult
		part.Position += Vector3.new(0, 1, 0)

		for _, v: Instance in part:GetDescendants() do
			if not v:IsA("ParticleEmitter") then continue end

			v:Emit((if v.Name == "Wind" then 1 else 3))
		end

		task.delay(2, function()
			splashCache:Return(part)
		end)
	end
end




--// Constructor

local Splash = {}
Splash.__index = Splash


function Splash.new()
	local self = setmetatable({}, Splash)

	self.SplashCache = HarukaLib:CreatePartPool(RepS.Packages.Unloads.RainSplash, 15 * 2)
	self.Rate = 10
	self.Speed = Random.new()

	self.Add, self.Empty = HarukaLib.Bin()

	self.Enabled = false

	return self
end


function Splash:Enable()
	if self.Enabled then return end

	self.Enabled = true

	self.Add(task.spawn(function()
		while wait(0.1) do
			_createSplash(self.SplashCache, self.Speed, self.Rate)
		end
	end))
end


function Splash:Disable()
	self.Enabled = false
	self.Empty()
end


function Splash:SetSplashRate(newRate: number)
	self.Rate = newRate
end


return Splash
