
local Bezier = {}

--// Helper functions

local function Lerp(a, b, c)
	return a + (b - a) * c
end

Bezier.QuadBezier = function(t, p0, p1, p2)
	local l1 = Lerp(p0, p1, t)
	local l2 = Lerp(p1, p2, t)

	return Lerp(l1, l2, t)
end

Bezier.CubicBezier = function(t: number, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3)
	return (1 - t) ^ 3 * p0 + 3 * (1 - t) ^ 2 * t * p1 + 3 * (1 - t) * t ^ 2 * p2 + t ^ 3 * p3
end

return Bezier