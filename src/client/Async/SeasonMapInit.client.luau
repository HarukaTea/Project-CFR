
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local ReplicatedStorage = game:GetService("ReplicatedStorage")


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local camera = workspace.CurrentCamera
local snowPart = ReplicatedStorage.Packages.Unloads.SnowParticles :: Part

snowPart = snowPart:Clone()
snowPart.Parent = workspace.Terrain

camera:GetPropertyChangedSignal("CFrame"):Connect(function()
    snowPart.Position = camera.CFrame.Position + Vector3.yAxis * 100
end)


--// time changes
local LocationBook = require(ReplicatedStorage.HarukaShared.Library.LocationBook)
local locationUtil = LocationBook.Utils

for id: string, info: LocationBook.LocationInfo in LocationBook do
    if id == "Utils" then continue end

    local clockTime = LocationBook[id].LightingInfo.ClockTime
    if clockTime >= 6 and clockTime <= 18 then
        LocationBook[id].LightingInfo = locationUtil._reconcileDefault(locationUtil.nightDefaultLighting)
        LocationBook[id].AtmosphereInfo = locationUtil._reconcileAtmosphere(locationUtil.nightDefaultAtmo)
    end
end
