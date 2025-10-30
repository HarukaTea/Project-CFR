
--// A simple pathfinding module for NPCs, inspired by SimplePath
--// https://devforum.roblox.com/t/simplepath-pathfinding-module/1196762

local PFS = game:GetService("PathfindingService")
local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)



export type PathCreatorClass = {
    __index: PathCreatorClass,

    new: (npc: Model, pfsArgs: { any }) -> PathCreatorClass,

    Run: (self: PathCreatorClass, targetPos: Vector3, previousAsyncResult: boolean) -> boolean,
    Stop: (self: PathCreatorClass) -> nil,
    Destroy: (self: PathCreatorClass) -> nil,
    IsPathValid: (self: PathCreatorClass, targetPos: Vector3) -> boolean,

    Visualize: boolean?,
    Settings: {
        TimeLimit: number,
        ComparisonCheckTimes: number
    },
    Events: {
        Errored: Signal.SignalClass
    },
    NPC: Model,
    Humanoid: Humanoid,
    PathObj: Path,
    Status: "Idle" | "Active",
    LastTick: number,
    Target: Vector3?,
    CurWaypoint: number,
    Waypoints: { PathWaypoint },
    VisualWaypoints: { BasePart },
    Position: {
        LastPos: Vector3,
        StuckCount: number
    },

    moveConn: RBXScriptConnection?,
}


local PathCreator = {} :: PathCreatorClass
PathCreator.__index = PathCreator


local visualWaypoint = HarukaLib:CreateMockPart()
visualWaypoint.Size = Vector3.new(0.3, 0.3, 0.3)
visualWaypoint.Anchored = true
visualWaypoint.Material = Enum.Material.Neon
visualWaypoint.Shape = Enum.PartType.Ball
visualWaypoint.Transparency = 0


--// Helper functions


local function createVisualWaypoints(waypoints)
	local visualWaypoints = {}
	for _, waypoint in ipairs(waypoints) do
		local visualWaypointClone = visualWaypoint:Clone()
		visualWaypointClone.Position = waypoint.Position
		visualWaypointClone.Parent = workspace.Terrain
		visualWaypointClone.Color =
			(waypoint == waypoints[#waypoints] and Color3.fromRGB(0, 255, 0))
			or (waypoint.Action == Enum.PathWaypointAction.Jump and Color3.fromRGB(255, 0, 0))
			or Color3.fromRGB(255, 139, 0)
		table.insert(visualWaypoints, visualWaypointClone)
	end
	return visualWaypoints
end
local function destroyVisualWaypoints(waypoints)
	if waypoints then
		for _, waypoint in ipairs(waypoints) do
			waypoint:Destroy()
		end
	end
	return
end

local function _setJumpState(humanoid: Humanoid)
    pcall(function()
		if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end
local function _disconnectMoveConns(self: PathCreatorClass)
    if self.moveConn then
        self.moveConn:Disconnect()
        self.moveConn = nil
    end
end
local function _moveNPC(self: PathCreatorClass)
    if self.Waypoints[self.CurWaypoint].Action == Enum.PathWaypointAction.Jump then
		_setJumpState(self.Humanoid)
	end
	self.Humanoid:MoveTo(self.Waypoints[self.CurWaypoint].Position)
end
local function _moveToFinished(self: PathCreatorClass, isReached: boolean)
    if isReached and self.CurWaypoint + 1 <= #self.Waypoints then
        self.CurWaypoint += 1

        _moveNPC(self)

    elseif isReached then
        _disconnectMoveConns(self)

        self.Status = "Idle"
        self.VisualWaypoints = destroyVisualWaypoints(self.VisualWaypoints)
    else
        _disconnectMoveConns(self)
        self.Status = "Idle"

        self.Events.Errored:Fire("TargetUnreachable")

        self.VisualWaypoints = destroyVisualWaypoints(self.VisualWaypoints)
    end
end
local function _comparePosition(self: PathCreatorClass)
	if self.CurWaypoint == #self.Waypoints then return end

	self.Position.StuckCount = ((self.NPC.PrimaryPart.Position - self.Position.LastPos).Magnitude <= 0.07 and (self.Position.StuckCount + 1)) or 0
	self.Position.LastPos = self.NPC.PrimaryPart.Position

	if self.Position.StuckCount >= self.Settings.ComparisonCheckTimes then
		_setJumpState(self.Humanoid)

        self.Events.Errored:Fire("AgentStuck")
	end
end


--// Constructor
function PathCreator.new(npc: Model, pfsArgs: { any })
    local self = setmetatable({
        Settings = {
            TimeLimit = 0.07,
            ComparisonCheckTimes = 1
        },
        Events = {
            Errored = Signal.new(),
        },

        NPC = npc,
        Humanoid = npc.Humanoid,
        PathObj = PFS:CreatePath(pfsArgs),
        Status = "Idle",
        LastTick = 0,
        Position = {
            LastPos = Vector3.zero,
            StuckCount = 0
        }

    }, PathCreator)


    return self
end

--// Start to let npc follow the path
function PathCreator:Run(targetPos: Vector3, previousAsyncResult: boolean)
    if not targetPos then return end

    --// limit the computation
    if os.clock() - self.LastTick <= self.Settings.TimeLimit and self.Humanoid then
		task.wait(os.clock() - self.LastTick)
		return

	elseif self.Humanoid then
		self.LastTick = os.clock()
	end

    if previousAsyncResult == nil then
        previousAsyncResult = self:IsPathValid(targetPos)
    end
    if previousAsyncResult == false then
        task.wait()
        self.Events.Errored:Fire("ComputationError")

        self.VisualWaypoints = destroyVisualWaypoints(self.VisualWaypoints)
        return
    end


    --// pathfinding starts
    self.Status = (self.Humanoid and "Active") or "Idle"
    self.Target = targetPos

    --// set network owner to server to prevent "hops"
    pcall(function()
        self.NPC.PrimaryPart:SetNetworkOwner(nil)
    end)

    --// add waypoints
    self.Waypoints = self.PathObj:GetWaypoints()
    self.CurWaypoint = 2

    --// in case npc stucks
    if self.Humanoid then _comparePosition(self) end


    destroyVisualWaypoints(self.VisualWaypoints)
    self.VisualWaypoints = (self.Visualize and createVisualWaypoints(self.Waypoints))


    self.moveConn = self.Humanoid and (self.moveConn or self.Humanoid.MoveToFinished:Connect(function(...)
        _moveToFinished(self, ...)
    end))


    self.RunClock = 1

    if self.Humanoid then
        if self.RunClock <= 1 then
            --- manually triggers MoveToFinished event at the start
            self.Humanoid:MoveTo(self.NPC.PrimaryPart.Position)
            self.RunClock += 1
        end
        self.Humanoid:MoveTo(self.Waypoints[self.CurWaypoint].Position)

    elseif #self.Waypoints == 2 then
        self.Target = nil
        self.VisualWaypoints = destroyVisualWaypoints(self.VisualWaypoints)
    end

    return true
end


--// stop the npc from following the path
function PathCreator:Stop()
	if self.Status == "Idle" then return end

	_disconnectMoveConns(self)

	self.Status = "Idle"
    self.VisualWaypoints = destroyVisualWaypoints(self.VisualWaypoints)
end


--[[
    Help compute whether the path is ok for npcs
]]
function PathCreator:IsPathValid(targetPos: Vector3)
    local pathComputed, _ = pcall(function()
        self.PathObj:ComputeAsync(self.NPC.PrimaryPart.Position, targetPos)
    end)

    --// make sure path computation is successful
    if not pathComputed
        or self.PathObj.Status == Enum.PathStatus.NoPath
        or #self.PathObj:GetWaypoints() < 2
        or (self.Humanoid and self.Humanoid:GetState() == Enum.HumanoidStateType.Freefall) then

        return false
    end

    return true
end


--// Clears the path object
function PathCreator:Destroy()
    pcall(destroyVisualWaypoints, self.VisualWaypoints)
    pcall(self.Stop, self)
    pcall(function()
        self.Events.Errored:Destroy()
    end)
    self.PathObj:Destroy()
end

return PathCreator