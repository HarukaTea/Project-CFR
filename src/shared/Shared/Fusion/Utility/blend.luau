local TweenService = game:GetService("TweenService")

local Package = script.Parent.Parent
local External = require(Package.External)
local Types = require(Package.Types)
local nicknames = require(Package.Utility.nicknames)

local blend = {}

--[[
	Implements the 'similarity test' used to determine whether two values have
	a meaningful difference.

	https://elttob.uk/Fusion/0.3/tutorials/best-practices/optimisation/#similarity
]]

function blend.isSimilar(a: unknown, b: unknown): boolean
	local typeA = typeof(a)
	local isTable = typeA == "table"
	local isUserdata = typeA == "userdata"
	return if not (isTable or isUserdata)
		then a == b or a ~= a and b ~= b
		elseif typeA == typeof(b) and (isUserdata or table.isfrozen(a :: any) or getmetatable(a :: any) ~= nil) then a
			== b
		else false
end

--[[
	Attempts to merge a variadic number of tables together.
]]

function blend.merge(
	overwrite: boolean,
	into: { [unknown]: unknown },
	...: { [unknown]: unknown }
): { [unknown]: unknown }
	local fromTables = { ... }
	if #fromTables < 1 then
		return into
	else
		for _, fromTable in fromTables do
			for key, value in fromTable do
				if overwrite or into[key] == nil then
					into[key] = value
				elseif not overwrite then
					External.logError("mergeConflict", nil, tostring(key))
				end
			end
		end
		return into
	end
end

--[[
	Returns the input *only* if it is a graph object.
]]

function blend.castToGraph(target: any): Types.GraphObject?
	if
		typeof(target) == "table"
		and typeof(target.validity) == "string"
		and typeof(target.timeliness) == "string"
		and typeof(target.dependencySet) == "table"
		and typeof(target.dependentSet) == "table"
	then
		return target
	else
		return nil
	end
end

--[[
	Returns the most specific custom name for the given object.
]]

function blend.nameOf(x: unknown, defaultName: string): string
	local nickname = nicknames[x]
	if typeof(nickname) == "string" then
		return nickname
	end
	if typeof(x) == "table" then
		if typeof(x.name) == "string" then
			return x.name
		elseif typeof(x.kind) == "string" then
			return x.kind
		elseif typeof(x.type) == "string" then
			return x.type
		end
	end
	return defaultName
end

--[[
	Extended typeof, designed for identifying custom objects.
	If given a table with a `type` string, returns that.
	Otherwise, returns `typeof()` the argument.
]]

function blend.xtypeof(x: unknown): string
	local typeString = typeof(x)

	if typeString == "table" then
		if typeof(x.type) == "string" then
			return x.type
		end
	end

	return typeString
end

--[[
	An xpcall() error handler to collect and parse useful information about
	errors, such as clean messages and stack traces.
]]

function blend.parseError(err: string): Types.Error
	return {
		type = "Error",
		raw = err,
		message = err:gsub("^.+:%d+:%s*", ""),
		trace = debug.traceback(nil, 2),
	}
end

--[[
	Returns the input *only* if it is a state object.
]]

function blend.castToState<T>(target: Types.UsedAs<T>): Types.StateObject<T>?
	if typeof(target) == "table" and target.type == "State" then
		return target
	else
		return nil
	end
end

--[[
	Given a `tweenInfo`, returns how many seconds it will take before the tween
	finishes moving. The result may be infinite if the tween repeats forever.
]]

function blend.getTweenDuration(tweenInfo: TweenInfo): number
	if tweenInfo.RepeatCount <= -1 then
		return math.huge
	end
	local tweenDuration = tweenInfo.DelayTime + tweenInfo.Time
	if tweenInfo.Reverses then
		tweenDuration += tweenInfo.Time
	end
	tweenDuration *= tweenInfo.RepeatCount + 1
	return tweenDuration
end

--[[
	Given a `tweenInfo` and `currentTime`, returns a ratio which can be used to
	tween between two values over time.
]]

function blend.getTweenRatio(tweenInfo: TweenInfo, currentTime: number): number
	local delay = tweenInfo.DelayTime
	local duration = tweenInfo.Time
	local reverses = tweenInfo.Reverses
	local numCycles = 1 + tweenInfo.RepeatCount
	local easeStyle = tweenInfo.EasingStyle
	local easeDirection = tweenInfo.EasingDirection
	local cycleDuration = delay + duration
	if reverses then
		cycleDuration += duration
	end
	-- If currentTime is infinity, then presumably the tween should be over.
	-- This avoids NaN when the duration of an infinitely repeating tween is given.
	if currentTime == math.huge then
		return 1
	end
	if currentTime >= cycleDuration * numCycles and tweenInfo.RepeatCount > -1 then
		return 1
	end
	local cycleTime = currentTime % cycleDuration
	if cycleTime <= delay then
		return 0
	end
	local tweenProgress = (cycleTime - delay) / duration
	if tweenProgress > 1 then
		tweenProgress = 2 - tweenProgress
	end
	local ratio = TweenService:GetValue(tweenProgress, easeStyle, easeDirection)
	return ratio
end

return blend
