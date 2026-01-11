--[[
	Creates an empty scope with the same metatables as the original scope. Used
	for preserving access to constructors when creating inner scopes.

	This is the public version of the function, which implements external
	debugging hooks.
]]
local Package = script.Parent.Parent
local Types = require(Package.Types)
local ExternalDebug = require(Package.ExternalDebug)
local blend = require(Package.Utility.blend)

-- This return type is technically a lie, but it's required for useful type
-- checking behaviour.
local function deriveScopeImpl<T>(
	existing: Types.Scope<T>,
	methods: { [unknown]: unknown }?,
	...: { [unknown]: unknown }
): any
	local metatable = getmetatable(existing)
	if methods ~= nil then
		metatable = table.clone(metatable)
		metatable.__index = blend.merge(true, {}, metatable.__index, blend.merge(false, {}, methods, ...))
	end
	return setmetatable({}, metatable)
end

local function deriveScope(...)
	local scope = deriveScopeImpl(...)
	ExternalDebug.trackScope(scope)
	return scope
end

return deriveScope :: Types.DeriveScopeConstructor
