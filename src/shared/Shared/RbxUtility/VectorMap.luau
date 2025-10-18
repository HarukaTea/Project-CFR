--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local VectorMap = {}
VectorMap.__index = VectorMap


local floor, clamp = math.floor, math.clamp
local v3New, cfNew = Vector3.new, CFrame.new


export type Class = typeof(setmetatable({} :: {
	_voxelSize: number,

	_voxels: {
		[Vector3]: {
			[string]: { any }
		}
	},
}, VectorMap))


function VectorMap.new(voxelSize: number?) : Class
	return setmetatable({
		_voxelSize = voxelSize or 50,
		_voxels = {},
	}, VectorMap)
end


function VectorMap.AddObject(self: Class, position: Vector3, object: any)
	local className = object.ClassName
	local voxelSize = self._voxelSize

	local voxelKey = v3New(
		floor(position.X / voxelSize),
		floor(position.Y / voxelSize),
		floor(position.Z / voxelSize)
	)

	local voxel = self._voxels[voxelKey]

	if voxel == nil then
		self._voxels[voxelKey] = {
			[className] = { object },
		}
	elseif voxel[className] == nil then
		voxel[className] = { object }
	else
		table.insert(voxel[className], object)
	end

	return voxelKey
end


function VectorMap.ForEachObjectInView(self: Class, camera: Camera, distance: number, callback: (string, any) -> ())
	local voxelSize = self._voxelSize
	local cameraCFrame = camera.CFrame
	local cameraPos = cameraCFrame.Position
	local rightVec, upVec = cameraCFrame.RightVector, cameraCFrame.UpVector

	local distance2 = distance / 2
	local farPlaneHeight2 = math.tan(math.rad((camera.FieldOfView + 5) / 2)) * distance
	local farPlaneWidth2 = farPlaneHeight2 * (camera.ViewportSize.X / camera.ViewportSize.Y)
	local farPlaneCFrame = cameraCFrame * cfNew(0, 0, -distance)
	local farPlaneTopLeft = farPlaneCFrame * v3New(-farPlaneWidth2, farPlaneHeight2, 0)
	local farPlaneTopRight = farPlaneCFrame * v3New(farPlaneWidth2, farPlaneHeight2, 0)
	local farPlaneBottomLeft = farPlaneCFrame * v3New(-farPlaneWidth2, -farPlaneHeight2, 0)
	local farPlaneBottomRight = farPlaneCFrame * v3New(farPlaneWidth2, -farPlaneHeight2, 0)

	local frustumCFrameInverse = (cameraCFrame * cfNew(0, 0, -distance2)):Inverse()

	local rightNormal = upVec:Cross(farPlaneBottomRight - cameraPos).Unit
	local leftNormal = upVec:Cross(farPlaneBottomLeft - cameraPos).Unit
	local topNormal = rightVec:Cross(cameraPos - farPlaneTopRight).Unit
	local bottomNormal = rightVec:Cross(cameraPos - farPlaneBottomRight).Unit

	local minBound =
		cameraPos:Min(farPlaneTopLeft):Min(farPlaneTopRight):Min(farPlaneBottomLeft):Min(farPlaneBottomRight)
	local maxBound =
		cameraPos:Max(farPlaneTopLeft):Max(farPlaneTopRight):Max(farPlaneBottomLeft):Max(farPlaneBottomRight)

	minBound = v3New(
		floor(minBound.X / voxelSize),
		floor(minBound.Y / voxelSize),
		floor(minBound.Z / voxelSize)
	)
	maxBound = v3New(
		floor(maxBound.X / voxelSize),
		floor(maxBound.Y / voxelSize),
		floor(maxBound.Z / voxelSize)
	)

	local function isPointInView(point: Vector3): boolean
		-- Check if point lies outside frustum OBB
		local relativeToOBB = frustumCFrameInverse * point
		if
			relativeToOBB.X > farPlaneWidth2
			or relativeToOBB.X < -farPlaneWidth2
			or relativeToOBB.Y > farPlaneHeight2
			or relativeToOBB.Y < -farPlaneHeight2
			or relativeToOBB.Z > distance2
			or relativeToOBB.Z < -distance2
		then
			return false
		end

		-- Check if point lies outside a frustum plane
		local lookToCell = point - cameraPos
		if
			rightNormal:Dot(lookToCell) < 0
			or leftNormal:Dot(lookToCell) > 0
			or topNormal:Dot(lookToCell) < 0
			or bottomNormal:Dot(lookToCell) > 0
		then
			return false
		end

		return true
	end

	for x = minBound.X, maxBound.X do
		local xMin = x * voxelSize
		local xMax = xMin + voxelSize
		local xPos = clamp(farPlaneCFrame.X, xMin, xMax)

		for y = minBound.Y, maxBound.Y do
			local yMin = y * voxelSize
			local yMax = yMin + voxelSize
			local yPos = clamp(farPlaneCFrame.Y, yMin, yMax)

			for z = minBound.Z, maxBound.Z do
				local zMin = z * voxelSize
				local zMax = zMin + voxelSize

				local voxelNearestPoint = v3New(xPos, yPos, clamp(farPlaneCFrame.Z, zMin, zMax))
				if isPointInView(voxelNearestPoint) then
					-- Found the first in frustum, now binary search for the last
					local entry, exit = z, minBound.Z - 1
					local left = z
					local right = maxBound.Z

					while left <= right do
						local mid = floor((left + right) / 2)
						local midPos = v3New(
							xPos,
							yPos,
							clamp(farPlaneCFrame.Z, mid * voxelSize, mid * voxelSize + voxelSize)
						)

						if isPointInView(midPos) then
							exit = mid
							left = mid + 1
						else
							right = mid - 1
						end
					end

					for fillZ = entry, exit do
						local voxel = self._voxels[v3New(x, y, fillZ)]
						if voxel then
							for className, objects in voxel do
								for _, object in objects do
									callback(className, object)
								end
							end
						end
					end

					break
				end
			end
		end
	end
end


function VectorMap.ClearAll(self: Class)
	table.clear(self._voxels)
end


return VectorMap