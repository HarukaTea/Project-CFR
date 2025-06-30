
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local Octree = require(ReplicatedStorage.HarukaShared.Shared.RbxUtility.Octree)


local WavesModel = workspace.Maps:FindFirstChild("Oceans")
if not WavesModel then
	WavesModel = Instance.new("Folder")
end


local RENDER_DISTANCE = 1000
local WAVE_HEIGHT_POSITION: number = 111;

local IS_SERVER = RunService:IsServer()

local ENABLED = true

-- // Wave Settings

local BASE_WAVE_GRAVITY = 0.1

local WAVE1_SETTINGS = {
	Length = 80,
	Steepness = 0.15,
	Direction = Vector3.new(1, 0, 0),
	Gravity = BASE_WAVE_GRAVITY,
}

local WAVE2_SETTINGS = {
	Length = 90,
	Steepness = 0.17,
	Direction = Vector3.new(0, 0, 0.3),
	Gravity = BASE_WAVE_GRAVITY,
}

local WAVE3_SETTINGS = {
	Length = 100,
	Steepness = 0.15,
	Direction = Vector3.new(1, 0, 1),
	Gravity = BASE_WAVE_GRAVITY,
}

-- // Types

type LOOKUP_FN = (Position: Vector3, CameraOrigin: Vector3?) -> number

type PLANE_STRUCTURE = {
	Position: Vector3,
	Size: Vector3,
	Bones: {[Bone]: Vector3}
}

type WAVE_SETTINGS_STRUCTURE = {
	Length: number,
	Steepness: number,
	Direction: Vector3,
	Gravity: number,
}

---- Constants ----

local Module = {}
local Camera = workspace.CurrentCamera
local GridOctree = Octree.new()

-- // Cached globals

local PI = math.pi
local SIN = math.sin
local COS = math.cos
local SQRT = math.sqrt
local SIGN = math.sign
local ABS = math.abs

local OS_CLOCK = os.clock

local CFRAME_NEW = CFrame.new
local ZERO_CFRAME = CFrame.identity
local VECTOR3_NEW = Vector3.new

local FLAT_VECTOR3 = Vector3.new(1, 0, 1)

---- Variables ----

local BonePlanes: {[number]: PLANE_STRUCTURE} = {}
local HeightSamplePart: MeshPart;

-- // Waves

local Wave1k: number, Wave1a: number, Wave1d: Vector3, Wave1c: number;
local Wave2k: number, Wave2a: number, Wave2d: Vector3, Wave2c: number;
local Wave3k: number, Wave3a: number, Wave3d: Vector3, Wave3c: number;

---- Private Functions ----

-- // Geometry Functions

local function isLeft(Top: Vector3, Bottom: Vector3, Position: Vector3): boolean
	return SIGN((Bottom.X - Top.X) * (Position.Z - Top.Z) - (Bottom.Z - Top.Z) * (Position.X - Top.X)) >= 0
end

local function getPointHeight(A: Vector3, B: Vector3, C: Vector3, Positon: Vector3): number
	local N = (B - A):Cross(C - A)
	Positon = (Positon - A) * VECTOR3_NEW(N.X, 1, N.Z)
	return A.Y - ((Positon.X + Positon.Z) / N.Y)
end

local function IsCircleInBox(Position: Vector3, CircleRadius: number, Box: PLANE_STRUCTURE): boolean
	Position *= FLAT_VECTOR3

	local BoxSize = Box.Size
	local BoxPosition = Box.Position
	local BoxWidth, BoxHeight = BoxSize.X, BoxSize.Z

	local DistanceX = ABS(Position.X - BoxPosition.X)
	local DistanceZ = ABS(Position.Z - BoxPosition.Z)

	if DistanceX > (BoxWidth + CircleRadius)
		or (DistanceZ > (BoxHeight + CircleRadius)) then
		return false
	end

	if (DistanceX <= BoxWidth)
		or (DistanceZ <= BoxHeight) then
		return true
	end

	local cornerDistance_sq = (DistanceX - BoxWidth) ^ 2 + (DistanceZ - BoxHeight) ^ 2
	return cornerDistance_sq <= (CircleRadius ^ 2)
end


-- // Wave Functions

local function CreateWave(Settings: WAVE_SETTINGS_STRUCTURE): (number, number, Vector3, number)
	local k = (2 * PI) / Settings.Length
	return k, (Settings.Steepness / k), Settings.Direction.Unit, SQRT(Settings.Gravity / k)
end

function GerstnerWave(Position: Vector3, k: number, a: number, d: Vector3, c: number, Time: number): Vector3
	local f = k * d:Dot(Position) - c * Time
	local cosF = COS(f)

	local dX = (d.X * (a * cosF))
	local dY = a * SIN(f)
	local dZ = (d.Z * (a * cosF))

	return VECTOR3_NEW(dX, dY, dZ)
end

function GetHeightAtPos(Position: Vector3, CameraOrigin: Vector3?): number
	local OctreeResult = GridOctree:KNearestNeighborsSearch(Position, 1, 128)
	local NearestGrid: LOOKUP_FN? = OctreeResult[1]

	if NearestGrid then
		return NearestGrid(Position, CameraOrigin) :: number
	end

	return WAVE_HEIGHT_POSITION
end

function SimulateBone(Bone: Bone, Time: number, CameraOrigin: Vector3?)
	local Distance = 0
	local Position = Bone.WorldPosition
	if CameraOrigin then
		Distance = (CameraOrigin - Position).Magnitude
	end

	local Wave1 = GerstnerWave(Position, Wave1k, Wave1a, Wave1d, Wave1c, Time)
	local Wave2 = GerstnerWave(Position, Wave2k, Wave2a, Wave2d, Wave2c, Time)
	local Wave3 = GerstnerWave(Position, Wave3k, Wave3a, Wave2d, Wave3c, Time)
	Bone.Transform = CFRAME_NEW((Wave1 + Wave2 + Wave3) * (1 - (Distance / RENDER_DISTANCE)))
end

-- // Class Functions

function CreateTriangle(A: Bone, B: Bone, C: Bone): LOOKUP_FN
	return function(Position: Vector3)
		return getPointHeight(A.TransformedWorldCFrame.Position, B.TransformedWorldCFrame.Position, C.TransformedWorldCFrame.Position, Position)
	end
end

function CreateGridNode(A: Bone, B: Bone, C: Bone, D: Bone)
	local Left = CreateTriangle(A, B, C)
	local Right = CreateTriangle(D, C, B)
	local NodePosition = (A.WorldPosition + B.WorldPosition + C.WorldPosition +  D.WorldPosition) / 4

	GridOctree:CreateNode(NodePosition,
		function(Position: Vector3, Origin: Vector3?)
			if IS_SERVER then
				-- Simulate the TransformedWorldCFrame if we are on the server
				local Time = workspace:GetServerTimeNow()
				SimulateBone(A, Time, Origin)
				SimulateBone(B, Time, Origin)
				SimulateBone(C, Time, Origin)
				SimulateBone(D, Time, Origin)
			end

			local Top = C.TransformedWorldCFrame.Position
			local Bottom = B.TransformedWorldCFrame.Position

			if isLeft(Top, Bottom, Position) then
				return Left(Position)
			else
				return Right(Position)
			end
		end
	)
end

---- Public Functions ----

-- // Module functions

function Module:SetEnabled(state: boolean)
	ENABLED = state or false
end

function Module.GetHeightAtXZ(Position: Vector2 | Vector3, CameraOrigin: Vector3?): number
	if typeof(Position) == "Vector2" then
		Position = VECTOR3_NEW(Position.X, 0, Position.Y)
	end

	return GetHeightAtPos(Position :: Vector3, CameraOrigin)
end

-- // Connection functions

local function OnRenderStepped()
	if not ENABLED then
		return
	end

	local Origin = Camera.CFrame.Position
	local TimeNow = workspace:GetServerTimeNow()

	for Index: number, Plane: PLANE_STRUCTURE in ipairs(BonePlanes) do
		if not IsCircleInBox(Origin, RENDER_DISTANCE, Plane) then
			continue
		end

		for Bone: Bone, Position: Vector3 in pairs(Plane.Bones) do
			local Distance = (Origin - Position).Magnitude

			if Distance >= RENDER_DISTANCE then
				Bone.Transform = ZERO_CFRAME
			else
				local Wave1 = GerstnerWave(Position, Wave1k, Wave1a, Wave1d, Wave1c, TimeNow)
				local Wave2 = GerstnerWave(Position, Wave2k, Wave2a, Wave2d, Wave2c, TimeNow)
				local Wave3 = GerstnerWave(Position, Wave3k, Wave3a, Wave2d, Wave3c, TimeNow)
				Bone.Transform = CFRAME_NEW((Wave1 + Wave2 + Wave3) * (1 - (Distance / RENDER_DISTANCE)))
			end
		end
	end
end

---- Initialization ----

-- // Create the waves

Wave1k, Wave1a, Wave1d, Wave1c = CreateWave(WAVE1_SETTINGS)
Wave2k, Wave2a, Wave2d, Wave2c = CreateWave(WAVE2_SETTINGS)
Wave3k, Wave3a, Wave3d, Wave3c = CreateWave(WAVE3_SETTINGS)

-- // Populate the plane & grid tables

local Bones: {[number]: {Bone}} = {}
local SortedBones: {{Bone}} = {}
local PositionsCache: {[string]: boolean} = {}

for Index, Plane: BasePart in ipairs(WavesModel:GetChildren()) do
	if Plane:IsA("BasePart") then
		local PlaneBones = {}
		local PlaneData: PLANE_STRUCTURE = {
			Position = Plane.Position * FLAT_VECTOR3,
			Size = Plane.Size / 2,
			Bones = PlaneBones,
		}

		for Index, Bone in ipairs(Plane:GetChildren()) do
			if Bone:IsA("Bone") and Bone.Name ~= "Ocean" then
				local WorldPosition = Bone.WorldPosition
				PlaneBones[Bone] = WorldPosition

				local BoneX = math.floor(WorldPosition.X)
				local BoneZ = math.floor(WorldPosition.Z)

				if BoneX == -1
					or BoneX == 1
					or BoneX == -0 then
					BoneX = 0
				end

				if BoneZ == -1
					or BoneZ == 1
					or BoneZ == -0 then
					BoneZ = 0
				end


				local CachedPositon = tostring(BoneX) .. tostring(BoneZ)
				if not PositionsCache[CachedPositon] then
					local ColumnList = Bones[BoneX]
					if not ColumnList then
						ColumnList = {}
						Bones[BoneX] = ColumnList
					end

					table.insert(ColumnList, Bone)
					PositionsCache[CachedPositon] = true
				end
			end
		end

		table.insert(BonePlanes, PlaneData)
	end
end

table.clear(PositionsCache)

for Index, List in pairs(Bones) do
	table.sort(List, function(a: Bone, b: Bone)
		return a.WorldPosition.Z > b.WorldPosition.Z
	end)

	table.insert(SortedBones, List)
end

table.sort(SortedBones, function(a: {Bone}, b: {Bone})
	return a[1].WorldPosition.X > b[1].WorldPosition.X
end)

local Created = 0
for Column, List in ipairs(SortedBones) do
	if Column == #SortedBones then
		break
	end

	for Index, Bone in ipairs(List) do
		if Index == #List then
			break
		end

		local TopColumn = SortedBones[Column + 1]
		local TopBone = TopColumn[Index]
		local TopSideBone = TopColumn[Index + 1]
		local SideBone = List[Index + 1]

		if not TopBone
			or not SideBone
			or not TopSideBone then
			continue
		end

		Created += 1
		CreateGridNode(Bone, SideBone, TopBone, TopSideBone)
	end
end

if not IS_SERVER then
	RunService.RenderStepped:Connect(OnRenderStepped)
end

return Module