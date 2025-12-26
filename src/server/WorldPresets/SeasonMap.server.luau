
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


--// christmas

task.wait(5)
for _, part: BasePart in CollectionService:GetTagged("TerrainPartEntity") do
    if part.Material == Enum.Material.Grass then
        part.Color = Color3.fromRGB(248, 248, 248)
        part.Material = Enum.Material.Sand
    end
end


local function _recolorTreePart(part: BasePart)
    if part.Color == Color3.fromRGB(31, 128, 29) and part.Material == Enum.Material.Grass then
        part.Color = Color3.fromRGB(248, 248, 248):Lerp(Color3.new(), 0.15)
    end
    if part.Color == Color3.fromRGB(26, 108, 24) and part.Material == Enum.Material.Grass then
        part.Color = Color3.fromRGB(248, 248, 248):Lerp(Color3.new(), 0.35)
    end
end
for _, model: Model in CollectionService:GetTagged("TreeEntity") do
    for _, part: BasePart in model:QueryDescendants(HarukaLib.BasePartSelector) do
        _recolorTreePart(part)
    end
end
for _, model: Model in CollectionService:GetTagged("FlowerEntity") do
    for _, part: BasePart in model:QueryDescendants(HarukaLib.BasePartSelector) do
        if part.Material == Enum.Material.Grass then
            part.Color = Color3.fromRGB(248, 248, 248)
            part.Material = Enum.Material.Sand
        end
    end
end


local initusBay = workspace.Maps:FindFirstChild("InitusBay", true) :: Folder
if initusBay then
    for _, model: Model in initusBay:QueryDescendants("#AppleT") do
        for _, part: BasePart in model:QueryDescendants(HarukaLib.BasePartSelector) do
            _recolorTreePart(part)
        end
    end
end


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
