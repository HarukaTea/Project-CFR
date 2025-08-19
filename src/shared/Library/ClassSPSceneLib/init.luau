--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local Types = require(script.Types)


export type ClassSPSceneLib = Types.ClassSPSceneLib


local ClassSPSceneLib = {} :: ClassSPSceneLib

local wait = task.wait


local function _tweenValue(start: number, duration: number, endTime: number, obj: Instance)
	local numVal = Instance.new('NumberValue')
	numVal.Value = start


    HarukaLib:CreateTween(numVal, TweenInfo.new(duration), {Value = endTime}):Play()
	Debris:AddItem(numVal, duration)

	if obj then
		numVal.Changed:Connect(function(New)
			obj.Size = NumberSequence.new(New)
		end)
	end

	return numVal
end
local function _createMarkContainer() : Folder
    local tempMarkedContainer = Instance.new("Folder")
    tempMarkedContainer.Name = "TempMarkedContainer_"..HarukaLib:GenerateUUID()
    tempMarkedContainer.Parent = game:GetService("ServerStorage")
    Debris:AddItem(tempMarkedContainer, 15)

    return tempMarkedContainer
end


ClassSPSceneLib._tweenValue = _tweenValue
ClassSPSceneLib._createMarkContainer = _createMarkContainer



for _, module: ModuleScript in script.Library:GetChildren() do
    ClassSPSceneLib[module.Name] = require(module)
end


return ClassSPSceneLib :: ClassSPSceneLib
