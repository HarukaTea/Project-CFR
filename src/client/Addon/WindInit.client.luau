--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

repeat task.wait() until workspace:GetAttribute("Haruka_CompletedPreload")


local CollectionService = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")

local WindLines = require(RepS.HarukaShared.Shared.Ambient.WindLines)
local WindShake = require(RepS.HarukaShared.Shared.Ambient.WindShake)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local v3New = Vector3.new


local WIND_VECTOR = v3New(-0.3, 0, 0.8)


local allTreeCFrames = {}


--// Enable winds
workspace.GlobalWind = WIND_VECTOR


local function _initWind()
    WindLines:Init({
        Direction = WIND_VECTOR,
        Speed = 10,
        LifeTime = 1.5,
        SpawnRate = 8,
    })
    WindShake:Init({
        WindSpeed = 10,
        WindDirection = WIND_VECTOR,
        WindPower = 1
    })
end
local function _updateTree(child: Model)
    if not child:IsA("Model") then return end

    for _, treePart: BasePart in child:GetDescendants() do
        if not treePart:IsA("BasePart") then continue end

        if treePart.Material == Enum.Material.Grass then
            allTreeCFrames[treePart] = treePart.CFrame

            WindShake:AddObjectShake(treePart)
        end
    end
end


--// listen for state changes
HarukaLib:Hydrate(workspace, {
    ["Attr-WindEffectEnabled"] = function(state: boolean)
        state = state or false

        if state then
            _initWind()

            for _, tree: Model in CollectionService:GetTagged("TreeEntity") do
                _updateTree(tree)
            end
        else
            WindLines:Cleanup()
            WindShake:Cleanup()

            for treePart: BasePart, cf: CFrame in allTreeCFrames do
                if treePart and treePart.Parent then
                    treePart.CFrame = cf
                end
            end

            table.clear(allTreeCFrames)
        end
    end
})

workspace:SetAttribute("WindEffectEnabled", true)