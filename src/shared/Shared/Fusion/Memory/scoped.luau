--[[
	Creates cleanup tables with access to constructors as methods.
]]

local Package = script.Parent.Parent
local Types = require(Package.Types)
local ExternalDebug = require(Package.ExternalDebug)
local blend = require(Package.Utility.blend)

local function scoped(...: { [unknown]: unknown }): any
	local metatable = { __index = blend.merge(false, {}, ...) }
	local scope = setmetatable({}, metatable) :: any
	ExternalDebug.trackScope(scope)
	return scope
end

return (scoped :: any) :: Types.ScopedConstructor
