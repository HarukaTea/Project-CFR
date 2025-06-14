--// https://devforum.roblox.com/t/noobpath-easy-pathfinding/3254514

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Path = require(script.Path)
local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)

local RS = game:GetService("RunService")

local module = {}

local NoobPath = {}
NoobPath.__index = NoobPath

export type Location = Vector3 | BasePart | Model

local function GetPrimaryPivot(Model : Model)
	return Model.PrimaryPart:GetPivot()
end

local function ToVector3(Location : Location)
	if typeof(Location) == "Vector3" then
		return Location
	elseif Location:IsA("Model") then
		return GetPrimaryPivot(Location).Position
	elseif Location:IsA("BasePart") then
		return Location:GetPivot().Position
	end
end

local function RemoveNetworkOwner(Character : Model)
	local Descendants = Character:GetDescendants()
	for i = 1, #Descendants do
		local Item = Descendants[i]
		if Item:IsA("BasePart") and Item:CanSetNetworkOwnership() then
			Item:SetNetworkOwner(nil)
		end
	end
end

local Server = RS:IsServer()

-- Constructor
function module.new(Character: Model, AgentParams: Path.AgentParams, Move: (Vector3) -> nil, Jump: () -> nil, JumpFinished: RBXScriptSignal, MoveFinished: RBXScriptSignal)
	if Server then
		RemoveNetworkOwner(Character)
	end

	local self = setmetatable({
		Character = Character,
		Path = Path.new(AgentParams),
		Route = {},
		Index = 1,
		Idle = true,
		InAir = false,
		Estimate = {},
		Destroying = false,
		Goal = nil,
		Partial = false,

		Move = Move,
		Jump = Jump,
		MoveFinished = MoveFinished,
		JumpFinished = JumpFinished,

		Timeout = false, -- trigger trapped if didn't arrive in time, time is auto estimated using speed
		Speed = 16, -- default speed
		Visualize = false, -- if there are many npcs with visualize on, it can create lag & disrupt pathfind

		MoveFinishedC = nil,
		JumpFinishedC = nil,
	}, NoobPath)

	self:Activate()

	return self
end

-- Constructor With Default Humanoid Signals
function module.Humanoid(Character : Model, AgentParams : Path.AgentParams)
	local Humanoid : Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local Move = function(WaypointPosition) Humanoid:MoveTo(WaypointPosition) end

	local JumpFinished = Signal.new()
	local MoveFinished = Humanoid.MoveToFinished

	local self = module.new(Character, AgentParams, Move, nil, JumpFinished, MoveFinished)

	local Jump = function()
		if Humanoid.FloorMaterial ~= Enum.Material.Air then
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			return
		end

		local A : RBXScriptConnection

		A = Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
			if Humanoid.FloorMaterial ~= Enum.Material.Air then
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				A:Disconnect()
			end
		end)
	end

	self.Jump = Jump

	return self
end

function module.View(AgentParams : Path.AgentParams)
	return setmetatable({
		View = true,
		Path = Path.new(AgentParams),
		Route = {},
		Index = 1,
		Idle = true,
		InAir = false,
		Estimate = {},
		Destroying = false,
		Goal = nil,
		Partial = false,

		Timeout = false, -- trigger trapped if didn't arrive in time, time is auto estimated using speed
		Speed = 16, -- default speed
		Visualize = false, -- if there are many npcs with visualize on, it can create lag & disrupt pathfind
	}, NoobPath)
end

function NoobPath:Compute(PointA, PointB)
	local Route, Partial = self.Path:Generate(PointA, PointB)

	if self.Destroying ~= false then
		return
	end

	if not self:ValidateRoute(Route, Partial) then
		return
	end

	self.Route = Route
	self.Partial = Partial

	if self.Timeout then
		if not self.Speed then
			error("No Speed Provided")
		end
		self:Predict()
	end

	if self.Visualize then
		self:Show()
	end

	return true
end

function NoobPath:Show()
	self.Path:Show(self.Route)
end

function NoobPath:Hide()
	self.Path:Hide()
end

function NoobPath:Predict()
	self.Estimate = self.Path:Estimate(self.Route, self.Speed)
end

function NoobPath:GetEstimateTotal()
	local Estimate = self.Estimate

	local Sum = 0
	for i = 1, #Estimate do
		Sum += Estimate[i]
	end

	return Sum
end

function NoobPath:Activate()
	if Server then
		self.DescendantAddedC = self.Character.DescendantAdded:Connect(function(Item)
			if Item:IsA("BasePart") and Item:CanSetNetworkOwnership() then
				Item:SetNetworkOwner(nil)
			end
		end)
	end


	self.MoveFinishedC = self.MoveFinished:Connect(function(Success) -- if you are using custom MoveFinished, Fire(true) if successfully reached
		if self.Idle then
			return
		end
		if Success then
			local NextWaypoint = self:GetNextWaypoint()
			if NextWaypoint then
				self:TravelNextWaypoint()
			else
				self:Arrive()
			end
		else
			self:Stop()
		end
	end)
	self.JumpFinishedC = self.JumpFinished:Connect(function()
		self.InAir = false
	end)
end

function NoobPath:PauseUntilLanded()
	local A : RBXScriptConnection

	A = self.JumpFinished:Connect(function()
		A:Disconnect()
		self:Run()
	end)
end

function NoobPath:ValidateRoute(Route, Partial)
	if not Route then
		return
	end
	if #Route == 0 then
		return
	end
	if #Route < 2 then -- Route too short, likely already arrived
		self:Arrive(Route, Partial)
		return
	end
	return true
end

-- Caculate Route To Location & Move The Character There
function NoobPath:Run(Location : Location)
	if self.Destroying ~= false then
		return
	end

	if Location then
		self.Goal = Location
	else
		Location = self.Goal or error("No Destination Provided")
	end

	if self.InAir then
		self:PauseUntilLanded()
		return
	end

	if not self:Compute(GetPrimaryPivot(self.Character).Position, ToVector3(Location)) then
		return
	end

	self.Index = 1
	self.Idle = false

	self:TravelNextWaypoint()
end

-- Stop The Character From Moving
function NoobPath:Stop()
	if self.Destroying ~= false then
		return
	end
	self.Idle = true

	self.Move(GetPrimaryPivot(self.Character).Position)
end

function NoobPath:GetWaypoint()
	return self.Route[self.Index]
end

function NoobPath:GetNextWaypoint()
	return self.Route[self.Index + 1]
end

function NoobPath:GetEstimateTime()
	return self.Estimate[self.Index]
end

function NoobPath:CheckForTimeout()
	local Time = self:GetEstimateTime()
	if not Time then
		return
	end
end

function NoobPath:TravelNextWaypoint()
	self.Index += 1
	self:TravelWaypoint()
end

function NoobPath:TravelWaypoint()
	local Waypoint = self:GetWaypoint()
	if self.Idle or not Waypoint then
		return
	end
	self.Move(Waypoint.Position)
	if self.Timeout then
		self:CheckForTimeout()
	end
	if Waypoint.Action == Enum.PathWaypointAction.Jump then
		self.InAir = true
		self.Jump(Waypoint.Position)
	end
end

function NoobPath:Arrive(Route, Partial)
	Route = Route or self.Route

	self.Idle = true
end

function NoobPath:Dump()
	self.Destroying = true

	task.defer(function() -- defer for things to settle down
		task.defer(function()
			self.Path:Destroy()

			table.clear(self)
			setmetatable(self, nil)
			self = nil
		end)

	end)
end

-- Destroy The NoobPath Object
function NoobPath:Destroy()
	self:Stop()
	self.Destroying = true

	self.MoveFinishedC:Disconnect()
	self.JumpFinishedC:Disconnect()

	if Server then
		self.DescendantAddedC:Disconnect()
	end

	self:Dump()
end

return module
