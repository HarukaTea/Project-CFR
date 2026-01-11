
--[[
	Stores nicknames for values that don't support metatables, so that `blend.nameOf`
	can return values for them.
]]

return setmetatable({}, {__mode = "k"})