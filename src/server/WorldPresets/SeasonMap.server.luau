
repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local map = workspace.Maps:FindFirstChild("InitusBay", true) :: Folder
if not map then return end



--// christmas

for _, part: BasePart in map.Terrain:QueryDescendants(HarukaLib.BasePartSelector) do
    if part.Color == Color3.fromRGB(31, 128, 29) and part.Material == Enum.Material.Grass then
        part.Color = Color3.fromRGB(248, 248, 248)
        part.Material = Enum.Material.Sand
    end
end

for _, part: BasePart in map.Models:QueryDescendants(HarukaLib.BasePartSelector) do
    if part.Color == Color3.fromRGB(31, 128, 29) and part.Material == Enum.Material.Grass then
        part.Color = Color3.fromRGB(248, 248, 248):Lerp(Color3.new(), 0.15)
    end

    if part.Color == Color3.fromRGB(26, 108, 24) and part.Material == Enum.Material.Grass then
        part.Color = Color3.fromRGB(248, 248, 248):Lerp(Color3.new(), 0.35)
    end
end
