--[[
	Cleans up the tasks passed in as the arguments.
	A task can be any of the following:

	- an Instance - will be destroyed
	- an RBXScriptConnection - will be disconnected
	- a function - will be run
	- a table with a `Destroy` or `destroy` function - will be called
	- an array - `cleanup` will be called on each item
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Package = script.Parent.Parent
local Types = require(Package.Types)
local ExternalDebug = require(Package.ExternalDebug)

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local FusionAdd, FusionEmpty = HarukaLib.Bin()

local alreadyDestroying: { [Types.Task]: true } = {}

local function doCleanup(thing: Types.Task): ()
	if alreadyDestroying[thing] then return end
	alreadyDestroying[thing] = true

	if typeof(thing) == "table" and thing[1] ~= nil then
		-- It is important to iterate backwards through the table, since
		-- objects are added in order of construction.
		for index = #thing, 1, -1 do
			doCleanup(thing[index])
			thing[index] = nil
		end
		ExternalDebug.untrackScope(thing)
	end

	FusionAdd(thing)
	FusionEmpty()

	alreadyDestroying[thing] = nil
end

return doCleanup
