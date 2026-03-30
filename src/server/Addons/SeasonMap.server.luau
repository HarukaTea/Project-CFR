
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local worldConfig = ReplicatedStorage:FindFirstChild("WorldConfig") :: Configuration
if not worldConfig then return end

local mapConfig = worldConfig:GetAttribute("WinterMap") :: boolean
if not mapConfig then return end

--// christmas

task.wait(5)
local function _recolorTerrainPart(part: BasePart)
    part.Color = Color3.fromRGB(248, 248, 248)
end
local function _recolorTreePart(part: BasePart)
    if part.Material ~= Enum.Material.Grass then return end

    if part.Color == Color3.fromRGB(31, 128, 29) then
        part.Color = Color3.fromRGB(248, 248, 248):Lerp(Color3.new(), 0.15)

    elseif part.Color == Color3.fromRGB(26, 108, 24) then
        part.Color = Color3.fromRGB(248, 248, 248):Lerp(Color3.new(), 0.35)
    end
end

for _, part: BasePart in CollectionService:GetTagged("TerrainPartEntity") do
    local isHalloween = part:IsDescendantOf(workspace.Maps.EventIslands.HalloweenArea)

    if part.Material == Enum.Material.Grass and not isHalloween then
        _recolorTerrainPart(part)
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
        end
    end
end
for _, model: Model in CollectionService:GetTagged("SpecialTreeEntity") do
    for _, part: BasePart in model:QueryDescendants(HarukaLib.BasePartSelector) do
        _recolorTreePart(part)
    end
end
for _, part: BasePart in workspace.Maps:QueryDescendants(HarukaLib.BasePartSelector) do
    if part.Material == Enum.Material.Grass and (part.Color == Color3.fromRGB(26, 108, 24) or part.Color == Color3.fromRGB(31, 128, 29)) then
        _recolorTerrainPart(part)
    end
end