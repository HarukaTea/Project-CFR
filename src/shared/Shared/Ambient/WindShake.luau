
--[=[
	Docs: https://devforum.roblox.com/t/wind-shake-high-performance-wind-effect-for-leaves-and-foliage/1039806/1
--]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VectorMap = require(ReplicatedStorage.HarukaShared.Shared.RbxUtility.VectorMap)


local FALLBACK_SETTINGS = {
	WindDirection = Vector3.new(0.5, 0, 0.5),
	WindPower = 0.5,
	WindSpeed = 20,
}


local clear = table.clear
local random, min, noise, clamp = math.random, math.min, math.noise, math.clamp
local fromAxisAngle, Angles = CFrame.fromAxisAngle, CFrame.Angles
local clock = os.clock


local WindShake = {
	RenderDistance = 150,
	MaxRefreshRate = 1 / 60,

	ObjectMetadata = {} :: {
		[Instance]: {
			ChunkKey: Vector3,
			Seed: number,
			Origin: CFrame,
			LastUpdate: number,
		}
	},

	VectorMap = VectorMap.new(),
	Handled = 0,
	Active = 0,

	_partList = table.create(500) :: { any }, -- ('any' because Studio and Luau LSP disagree on the type)
	_cframeList = table.create(500) :: { CFrame },

	Initialized = nil :: boolean?,
	AddedConnection = nil :: RBXScriptConnection?,
	UpdateConnection = nil :: RBXScriptConnection?,
	RemovedConnection = nil :: RBXScriptConnection?,
	WorkspaceWindConnection = nil :: RBXScriptConnection?,
}

type WindShake = typeof(WindShake)

export type WindShakeSettings = {
	WindDirection: Vector3?,
	WindSpeed: number?,
	WindPower: number?,
}

local function Connect<Args...>(self: WindShake, event: RBXScriptSignal, callback: (self: WindShake, Args...) -> ()): RBXScriptConnection
	return event:Connect(function(...)
		return callback(self, ...)
	end)
end

function WindShake.AddObjectShake(self: WindShake, object: BasePart | Bone)
	if typeof(object) ~= "Instance" then return end
	if not (object:IsA("BasePart") or object:IsA("Bone")) then return end

	local metadata = self.ObjectMetadata
	if metadata[object] then return end

	metadata[object] = {
		ChunkKey = self.VectorMap:AddObject(
			if object:IsA("Bone") then object.WorldPosition else object.Position,
			object
		),
		Seed = math.random(5000) * 0.32,

		Origin = if object:IsA("Bone")
			then object.WorldCFrame
			else object.CFrame,

		PivotOffset = if object:IsA("BasePart")
			then object.PivotOffset
			else nil,

		PivotOffsetInverse = if object:IsA("BasePart")
			then object.PivotOffset:Inverse()
			else nil,

		LastUpdate = os.clock(),
	}
	self.Handled += 1
end


function WindShake.Update(self: WindShake, deltaTime: number)
	local active = 0
	local now = clock()
	local slowerDeltaTime = deltaTime * 3
	local step = min(1, deltaTime * 5)

	-- Reuse tables to avoid garbage collection
	local bulkMoveIndex = 0
	local partList = self._partList
	local cframeList = self._cframeList
	clear(partList)
	clear(cframeList)

	-- Cache hot values
	local objectMetadata = self.ObjectMetadata
	local camera = workspace.CurrentCamera
	local cameraPos = camera.CFrame.Position

	local renderDistance = self.RenderDistance
	local maxRefreshRate = self.MaxRefreshRate
	local sharedSettings = self.SharedSettings

	local sharedWindPower = sharedSettings.WindPower :: number
	local sharedWindSpeed = sharedSettings.WindSpeed :: number
	local sharedWindDirection = sharedSettings.WindDirection :: Vector3

	-- Update objects in view at their respective refresh rates
	self.VectorMap:ForEachObjectInView(camera, renderDistance, function(className: string, object: BasePart | Bone)
		local objMeta = objectMetadata[object]
		local lastUpdate = objMeta.LastUpdate or 0
		local isBone = className == "Bone"

		-- Determine if the object refresh rate
		local objectCFrame = if isBone then (object :: Bone).WorldCFrame else object.CFrame
		local distanceAlpha = ((cameraPos - objectCFrame.Position).Magnitude / renderDistance)
		local distanceAlphaSq = distanceAlpha * distanceAlpha
		local jitter = (1 / random(60, 120))
		local refreshRate = (slowerDeltaTime * distanceAlphaSq) + maxRefreshRate

		if (now - lastUpdate) + jitter <= refreshRate then
			-- It is not yet time to update
			return
		end

		objMeta.LastUpdate = now
		active += 1

		local windDirection = (sharedWindDirection)
		if windDirection.Magnitude < 1e-5 then
			return
		end

		local amp = (sharedWindPower) * 0.2
		if amp < 1e-5 then
			return
		end

		local freq = now * (sharedWindSpeed * 0.08)
		if freq < 1e-5 then
			return
		end

		local seed = objMeta.Seed
		local animValue = (noise(freq, 0, seed) + 0.4) * amp
		local lerpAlpha = clamp(step + distanceAlphaSq, 0.1, 0.5)
		local lowAmp = amp / 3

		local origin = objMeta.Origin * (objMeta.PivotOffset or CFrame.identity)
		local localWindDirection = origin:VectorToObjectSpace(windDirection)

		if isBone then
			local bone: Bone = object :: Bone
			bone.Transform = bone.Transform:Lerp(
				(
					fromAxisAngle(localWindDirection:Cross(Vector3.yAxis), -animValue)
					* Angles(
						noise(seed, 0, freq) * lowAmp,
						noise(seed, freq, 0) * lowAmp,
						noise(freq, seed, 0) * lowAmp
					)
				) + (localWindDirection * animValue * amp),
				lerpAlpha
			)
		else
			bulkMoveIndex += 1
			partList[bulkMoveIndex] = object
			cframeList[bulkMoveIndex] = objectCFrame:Lerp(
				(
					origin
					* fromAxisAngle(localWindDirection:Cross(Vector3.yAxis), -animValue)
					* Angles(
						noise(seed, 0, freq) * lowAmp,
						noise(seed, freq, 0) * lowAmp,
						noise(freq, seed, 0) * lowAmp
					)
					* (objMeta.PivotOffsetInverse or CFrame.identity)
				) + (windDirection * animValue * (amp * 2)),
				lerpAlpha
			)
		end
	end)

	self.Active = active


	workspace:BulkMoveTo(partList, cframeList, Enum.BulkMoveMode.FireCFrameChanged)
end

function WindShake.Pause(self: WindShake)
	if self.UpdateConnection then
		self.UpdateConnection:Disconnect()
		self.UpdateConnection = nil
	end

	self.Active = 0
	self.Running = false
end

function WindShake.Resume(self: WindShake)
	if self.Running then
		return
	end

	-- Connect updater
	self.UpdateConnection = Connect(self, RunService.Heartbeat, self.Update)
	self.Running = true
end

function WindShake.Init(self: WindShake, sharedSettings: {
	WindSpeed: number?,
	WindDirection: Vector3?,
	WindPower: number?,
})
	if self.Initialized then return end


	local power = sharedSettings.WindPower or FALLBACK_SETTINGS.WindPower
	local speed = sharedSettings.WindSpeed or FALLBACK_SETTINGS.WindSpeed
	local direction = sharedSettings.WindDirection or FALLBACK_SETTINGS.WindDirection

	self.SharedSettings = {
		WindPower = power,
		WindSpeed = speed,
		WindDirection = direction,
	}

	-- Clear any old stuff.
	self:Cleanup()
	self.Initialized = true

	self:Resume()
end

function WindShake.Cleanup(self: WindShake)
	if not self.Initialized then
		return
	end

	self:Pause()

	if self.AddedConnection then
		self.AddedConnection:Disconnect()
		self.AddedConnection = nil
	end

	if self.RemovedConnection then
		self.RemovedConnection:Disconnect()
		self.RemovedConnection = nil
	end

	if self.WorkspaceWindConnection then
		self.WorkspaceWindConnection:Disconnect()
		self.WorkspaceWindConnection = nil
	end

	table.clear(self.ObjectMetadata)
	self.VectorMap:ClearAll()

	self.Handled = 0
	self.Active = 0
	self.Initialized = false
end


return WindShake