
local RunService = game:GetService("RunService")
local RepS = game:GetService("ReplicatedStorage")

local BezierMath = require(RepS.HarukaShared.Shared.HarmonyLib.BezierMath)

export type TrailMathLibClass = {
	__index: TrailMathLibClass,

	new: () -> TrailMathLibClass,
	Init: (self: TrailMathLibClass, part: BasePart, props: {
		Origin: Vector3?,
		Duration: number?,
		radius: number?,
		Interval: number?,
		Index: number?,
		CurveOffset: number?,
		Projectile: BasePart?,
		Size: number?,
		Color: Color3?,
		Transparency: number?,
		Lifetime: number?
	}) -> nil,
	Disconnect: (self: TrailMathLibClass) -> nil,
	Destroy: (self: TrailMathLibClass) -> nil,

	Active: boolean
}

local TrailMath = {} :: TrailMathLibClass
TrailMath.__index = TrailMath

--// Constructor
function TrailMath.new()
    local self = setmetatable({}, TrailMath)

    self.Active = false

    return self
end

function TrailMath:Init(part: BasePart, props: {
    Origin: Vector3?,
    Duration: number?,
    radius: number?,
    Interval: number?,
    Index: number?,
    CurveOffset: number?,
    Projectile: BasePart?,
    Size: number?,
    Color: Color3?,
    Transparency: number?,
    Lifetime: number?
})
	self.Active = true

	local origin = props.Origin or nil
	local duration = props.Duration or 0.44
	local radius = props.radius or 14
	local interval = props.Interval or 0.1
	local index = props.Index or math.huge
	local curve = props.CurveOffset or 14
	local projectile = props.Projectile or error('No projectile passed!')

	for _ = 1, index do
		if not self.Active then break end

		local startTime = os.clock()
        local random = Random.new()

		local defaultCurveOffset = Vector3.new(
            random:NextNumber(-curve, curve),
            random:NextNumber(0, curve),
            random:NextNumber(-curve, curve)
        ) or Vector3.new(
            random:NextNumber(-15, 15),
            random:NextNumber(-5, 10),
            random:NextNumber(-15, 15)
        )
		local offset = CFrame.new(
            random:NextNumber(-radius, radius),
            random:NextNumber(-radius, radius),
            random:NextNumber(-radius, radius)
        )

		random = nil

		local startPos = origin or part.CFrame * offset;
		local endPos = part.CFrame

		local midPoint = startPos.Position:Lerp(endPos.Position, 0.4) + defaultCurveOffset
		local midPoint2 = startPos.Position:Lerp(endPos.Position, 0.65) + defaultCurveOffset

		projectile = projectile:Clone()
		projectile.Transparency = 1
		projectile.Position = startPos.Position
		projectile.A0.Trail.Enabled = true
		projectile.Parent = workspace.Terrain

		local trail = projectile.A0.Trail :: Trail

		local conn; conn = RunService.RenderStepped:Connect(function()
			local alpha = (os.clock() - startTime) / duration

			local cubicCurve = BezierMath.CubicBezier(alpha, startPos.Position, midPoint, midPoint2, endPos.Position)

			if (alpha >= 1) then
				projectile.Position = endPos.Position

				task.delay(trail.Lifetime, function()
					trail.Enabled = false
					projectile:Destroy()
				end)

				conn:Disconnect()
				return
			else
				projectile.Position = cubicCurve
			end
		end)
		task.wait(interval)
	end

	self.Active = false
end

function TrailMath:Disconnect()
	self.Active = false
end

function TrailMath:Destroy()
    self:Disconnect()
    self = nil
end

return TrailMath