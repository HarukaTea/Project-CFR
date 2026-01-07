
--[[
	Processes and returns an existing instance, with options for setting
	properties, event handlers and other attributes on the instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)

local function Hydrate(
	scope: Types.Scope<unknown>,
	target: Instance
)
	return function(
		props: Types.PropertyTable,
		keepAllChildren: boolean?
	): Instance
		target = target:Clone()
		if not keepAllChildren then
			target:ClearAllChildren()
		end

		table.insert(scope, target)
		applyInstanceProps(scope, props, target)
		return target
	end
end

return Hydrate