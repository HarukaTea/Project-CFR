
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local worldConfig = ReplicatedStorage:FindFirstChild("WorldConfig", true) :: Configuration
if not worldConfig then return end

local mapConfig = worldConfig:GetAttribute("WinterMap") :: boolean
if not mapConfig then return end

local camera = workspace.CurrentCamera
local snowPart = ReplicatedStorage.Packages.Unloads.SnowParticles :: Part

snowPart = snowPart:Clone()
snowPart.Parent = workspace.Terrain

camera:GetPropertyChangedSignal("CFrame"):Connect(function()
    snowPart.Position = camera.CFrame.Position + Vector3.yAxis * 100
end)
Lighting:GetAttributeChangedSignal("RainLevel"):Connect(function()
    local rainLevel = Lighting:GetAttribute("RainLevel") or 0

    snowPart.Parent = if rainLevel < 0.5 then workspace.Terrain else script
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

        LocationBook[id].RainLevel = 0

        local combatMusic = LocationBook[id].CombatMusic
        if combatMusic == "UltraSuperBossBattleRMX" or combatMusic == "SophisticatedFight_Sky1st" then
            LocationBook[id].CombatMusic = "TemporalDreams"
        end
        if LocationBook[id].Music == "Conquest" then
            LocationBook[id].Music = "RoadTaken"
        end
    end
end
