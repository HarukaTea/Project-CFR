
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local Types = require(script.Types)


export type VFXSceneLib = Types.VFXSceneLib


local VFXSceneLib = {} :: VFXSceneLib


local function _tweenValue(start: number, duration: number, endTime: number)
	local numVal = Instance.new('NumberValue')
	numVal.Value = start

    HarukaLib:CreateTween(numVal, TweenInfo.new(duration), {Value = endTime}):Play()
	Debris:AddItem(numVal, duration)

	return numVal
end
local function _createMarkContainer() : Folder
    local tempMarkedContainer = Instance.new("Folder")
    tempMarkedContainer.Name = "TempMarkedContainer_"..HarukaLib:GenerateUUID()
    tempMarkedContainer.Parent = game:GetService("ServerStorage")
    Debris:AddItem(tempMarkedContainer, 15)

    return tempMarkedContainer
end


VFXSceneLib._tweenValue = _tweenValue
VFXSceneLib._createMarkContainer = _createMarkContainer



for _, module: ModuleScript in script.Library:GetChildren() do
    VFXSceneLib[module.Name] = function(caster: Model, uniqueId: string)
		require(module)(VFXSceneLib, caster, uniqueId)
	end
end
for _, module: ModuleScript in script.LibrarySP:GetChildren() do
    require(module)(VFXSceneLib)
end


return VFXSceneLib