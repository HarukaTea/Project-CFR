--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RunService = game:GetService("RunService")

local Terrain = workspace.Terrain

local OFFSET = Vector3.new(0, 0.1, 0)

local WindLines = {}

WindLines.UpdateConnection = nil
WindLines.UpdateQueue = table.create(10)

function WindLines:_create()
	local lifeTime = WindLines.Lifetime
	local pos = (workspace.CurrentCamera.CFrame
		* CFrame.Angles(
			math.rad(math.random(-30, 70)),
			math.rad(math.random(-80, 80)),
			0))
		* CFrame.new(0, 0, math.random(200, 600) * -0.1).Position

	local direction = WindLines.Direction
	local speed = WindLines.Speed

	local att0 = Instance.new("Attachment")
	local att1 = Instance.new("Attachment")

	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.2, 1),
		NumberSequenceKeypoint.new(0.8, 1),
		NumberSequenceKeypoint.new(1, 0.3),
	})
	trail.Transparency = NumberSequence.new(0.7)
	trail.FaceCamera = true
	trail.Parent = att0

	att0.WorldPosition = pos
	att1.WorldPosition = pos + OFFSET

	local windlineObj = {
		Attachment0 = att0,
		Attachment1 = att1,
		Trail = trail,
		Lifetime = lifeTime + (math.random(-10, 10) * 0.1),
		Position = pos,
		Direction = direction,
		Speed = speed + (math.random(-10, 10) * 0.1),
		StartClock = os.clock(),
		Seed = math.random(1, 1000) * 0.1,
	}
	table.insert(WindLines.UpdateQueue, windlineObj)

	att0.Parent = Terrain
	att1.Parent = Terrain
end

function WindLines:Init(settings: {
	Direction: Vector3?,
	Speed: number?,
	LifeTime: number?,
	SpawnRate: number?,
})
	self:Cleanup()

	-- Set defaults
	WindLines.Lifetime = settings.Lifetime or 3
	WindLines.Direction = settings.Direction or Vector3.xAxis
	WindLines.Speed = settings.Speed or 6
	WindLines.LastSpawned = os.clock()
	WindLines.SpawnRate = 1 / (settings.SpawnRate or 25)


	---// save up little time
	local cfNew, sin = CFrame.new, math.sin


	-- Setup logic loop
	WindLines.UpdateConnection = RunService.Heartbeat:Connect(function()
		local clock = os.clock()

		-- Spawn handler
		if clock - WindLines.LastSpawned > WindLines.SpawnRate then
			WindLines:_create()
			WindLines.LastSpawned = clock
		end

		-- Update queue handler
		for i, windLineObj in WindLines.UpdateQueue do
			local aliveClock = clock - windLineObj.StartClock
			if aliveClock >= windLineObj.Lifetime then
				-- Destroy the objects
				windLineObj.Attachment0:Destroy()
				windLineObj.Attachment1:Destroy()
				windLineObj.Trail:Destroy()

				-- unordered remove at this index
				local len = #WindLines.UpdateQueue
				WindLines.UpdateQueue[i] = WindLines.UpdateQueue[len]
				WindLines.UpdateQueue[len] = nil

				continue
			end

			windLineObj.Trail.MaxLength = 20 - (20 * (aliveClock / windLineObj.Lifetime))

			local SeededClock = (clock + windLineObj.Seed) * (windLineObj.Speed * 0.2)
			local StartPos = windLineObj.Position
			windLineObj.Attachment0.WorldPosition = (
				cfNew(StartPos, StartPos + windLineObj.Direction) * cfNew(0, 0, windLineObj.Speed * -aliveClock
			)).Position + Vector3.new(
				sin(SeededClock) * 0.5,
				sin(SeededClock) * 0.8,
				sin(SeededClock) * 0.5
			)

			windLineObj.Attachment1.WorldPosition = windLineObj.Attachment0.WorldPosition + OFFSET
		end
	end)
end


function WindLines:Cleanup()
	if WindLines.UpdateConnection then
		WindLines.UpdateConnection:Disconnect()
		WindLines.UpdateConnection = nil
	end
	for _, windLineObj in WindLines.UpdateQueue do
		windLineObj.Attachment0:Destroy()
		windLineObj.Attachment1:Destroy()
		windLineObj.Trail:Destroy()
	end

	table.clear(WindLines.UpdateQueue)
end

return WindLines