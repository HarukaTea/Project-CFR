--!nocheck

repeat task.wait() until workspace:GetAttribute("Haruka_CompletedPreload")


local CollectionService = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")

local WindLines = require(RepS.HarukaShared.Shared.Ambient.WindLines)
local WindShake = require(RepS.HarukaShared.Shared.Ambient.WindShake)

local v3New = Vector3.new


local WIND_VECTOR = v3New(-0.3, 0, 0.8)

--// Enable winds
do
    workspace.GlobalWind = WIND_VECTOR

    WindLines:Init({
        Direction = WIND_VECTOR,
        Speed = 10,
        LifeTime = 1.5,
        SpawnRate = 8,
    })

    WindShake:SetDefaultSettings({
        WindSpeed = 10,
        WindDirection = WIND_VECTOR,
        WindPower = 1
    })
    WindShake:Init()


    local function _updateTree(child: Model)
        if not child:IsA("Model") then return end

        for _, treePart: BasePart in child:GetDescendants() do
            if not treePart:IsA("BasePart") then continue end

            if treePart.Material == Enum.Material.Grass then
                WindShake:AddObjectShake(treePart)
            end
        end
    end
    for _, tree: Model in CollectionService:GetTagged("TreeEntity") do
        _updateTree(tree)
    end
    CollectionService:GetInstanceAddedSignal("TreeEntity"):Connect(_updateTree)
end
