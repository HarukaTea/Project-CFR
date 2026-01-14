--[[
	Processes and returns an existing instance, with options for setting
	properties, event handlers and other attributes on the instance.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local blend = require(Package.Utility.blend)
local applyInstanceProps = require(Package.Instances.applyInstanceProps)

local function Hydrate(scope: Types.Scope<unknown>, target: Instance)
	return function(props: Types.PropertyTable): Instance
		table.insert(scope, target)

		local isButtonType = target.ClassName == "TextButton" or target.ClassName == "ImageButton"
		if isButtonType then
			local data = blend._readSpecialKey(props)
			local hoverFunc, leaveFunc, clickFunc = data.HoverFunc, data.LeaveFunc, data.ClickFunc

			applyInstanceProps(scope, props, target)
			blend._trackButtonEvents(scope, target, hoverFunc, leaveFunc, clickFunc)
			return target
		end

		applyInstanceProps(scope, props, target)
		return target
	end
end

return Hydrate
