
--// A pathfinding module for Non-NPCs by using AlignPosition
--// Inspired by https://devforum.roblox.com/t/noobpath-easy-pathfinding/3254514

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local PATH_COSTS = {
    Grass = 0,
    Plastic = 0,
    SmoothPlastic = 0,

    Slate = 10,
    Wood = 10,
    WoodPlanks = 10,
    DangerZone = math.huge
}
local PATH_PARAMS = {
    Costs = PATH_COSTS,
    AgentCanJump = false,
    AgentCanClimb = false,
    PathSettings = {
        SupportPartialPath = false
    }
}
local visualWaypoint = HarukaLib:CreateMockPart()
visualWaypoint.Size = Vector3.new(0.3, 0.3, 0.3)
visualWaypoint.Anchored = true
visualWaypoint.Material = Enum.Material.Neon
visualWaypoint.Shape = Enum.PartType.Ball
visualWaypoint.Transparency = 0



local HarukaPathCreator = {}
HarukaPathCreator.__index = HarukaPathCreator



function HarukaPathCreator.new(locator: BasePart, info: {
    Speed: number
})
    pcall(function()
        locator:SetNetworkOwner(nil)
    end)

    local self = setmetatable({}, HarukaPathCreator)

    self.Locator = locator
    self.Path = PathfindingService:CreatePath(PATH_PARAMS)

    self.Speed = info.Speed
    self.Visual = {}


    return self
end



function HarukaPathCreator:GeneratePath(pointA: Vector3, pointB: Vector3) : (boolean, { PathWaypoint })
    local success, _ = pcall(function()
        self.Path:ComputeAsync(pointA, pointB)
    end)
    if not success then
        return false, nil
    end
    if self.Destroying then return false, nil end


    local route = self.Path:GetWaypoints()

    return true, route
end


function HarukaPathCreator:ComputePath(pointA: Vector3, pointB: Vector3) : boolean
    if self.Destroying then return false end

    local status, route = self:GeneratePath(pointA, pointB)
    if not status then return false end

    if not self:IsPathValid(route) then return false end

    self.Route = route

    if RunService:IsStudio() then
        self:ShowPath()
    end

    return true
end


function HarukaPathCreator:ShowPath()
    for _, point in self.Visual do
        point:Destroy()
    end

    local route = self.Route
    local Visual = self.Visual

    for i = 1, #route - 1 do
        local Waypoint = route[i]
        local Position = Waypoint.Position

        local Point = visualWaypoint:Clone()
        Point.Position = Position

        if Waypoint.Action == Enum.PathWaypointAction.Jump then
            Point.BrickColor = BrickColor.new("Bright yellow")
        end

        Point.Parent = workspace.Terrain
        Visual[i] = Point

        local Direction = route[i + 1].Position - Position

        local Line = Instance.new("LineHandleAdornment")
        Line.Parent = Point
        Line.Adornee = Point
        Line.CFrame = CFrame.new(Vector3.new(0, 0, 0), Direction)
        Line.Length = Direction.Magnitude
        Line.Color3 = BrickColor.new("Bright blue").Color

        Line.Thickness = 3
    end


    local LastWaypoint = route[#route]
	local Point = visualWaypoint:Clone()
	Point.Position = LastWaypoint.Position
	Point.BrickColor = BrickColor.new("Bright red")

	Point.Parent = workspace.Terrain
	Visual[#route] = Point
end



function HarukaPathCreator:IsPathValid(route: { PathWaypoint })
    if not route then
        return false
    end
    if #route == 0 then
        return false
    end
    if #route < 2 then
        self:Arrived()
        return false
    end

    return true
end


function HarukaPathCreator:TravelToWaypoint()
    local waypoint = self.Route[self.Index]

    if self.Idle or not waypoint then return end

    self.Locator:SetAttribute("_LOCATION", waypoint.Position)
end


function HarukaPathCreator:Run(location: Vector3)
    if self.Destroying then return end

    local status = self:ComputePath(self.Locator.Position + Vector3.yAxis * self.Locator.Size.Y / 2, location)
    if not status then return end

    self.Index = 1
    self.Idle = false


    --// FIXME: function recursion
    self.Index += 1
    self:TravelToWaypoint()
end


function HarukaPathCreator:Arrived()
    self.Idle = true
end


function HarukaPathCreator:Stop()
    if self.Destroying then return end

    self.Idle = true
    self:Move(self.Locator.Position)
end





return HarukaPathCreator
