--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RunService = game:GetService("RunService")
local RepS = game:GetService("ReplicatedStorage")


local BezierAlgoBook = require(RepS.HarukaShared.Library.BezierAlgoBook)



export type TrailAlgoLibClass = {
	__index: TrailAlgoLibClass,

	new: () -> TrailAlgoLibClass,
	Init: (self: TrailAlgoLibClass, part: BasePart, props: {
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
	Disconnect: (self: TrailAlgoLibClass) -> nil,
	Destroy: (self: TrailAlgoLibClass) -> nil,


	Active: boolean
}



local TrailAlgoBook = {} :: TrailAlgoLibClass
TrailAlgoBook.__index = TrailAlgoBook



--// Constructor
function TrailAlgoBook.new()
    local self = setmetatable({}, TrailAlgoBook)

    self.Active = false

    return self
end



function TrailAlgoBook:Init(part: BasePart, props: {
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
		projectile.Position = startPos.Position
		projectile.A0.Trail.Enabled = true
		projectile.Parent = workspace

		local trail = projectile.A0.Trail :: Trail

		local conn; conn = RunService.RenderStepped:Connect(function()
			local alpha = (os.clock() - startTime) / duration

			local cubicCurve = BezierAlgoBook.CubicBezier(alpha, startPos.Position, midPoint, midPoint2, endPos.Position)

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

function TrailAlgoBook:Disconnect()
	self.Active = false
end


function TrailAlgoBook:Destroy()
    self:Disconnect()
    self = nil
end


return TrailAlgoBook