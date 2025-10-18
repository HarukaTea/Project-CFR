--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")

local Promise = require(RepS.HarukaShared.Shared.Promise)
local Signal = require(RepS.HarukaShared.Shared.Signal)


local GlobalTimer = {}

local promises = {}

local addTaskSignal = Signal.new()


addTaskSignal:Connect(function(durationLater: number, callback: () -> nil, uniqueId: string)
    promises[uniqueId] = {
        Promise = Promise.delay(durationLater):andThenCall(callback):catch(function() end),
        Callback = callback,
    }
end)


GlobalTimer.AddTask = function(_, durationLater: number, callback: () -> nil) : string
    local uniqueId = HttpService:GenerateGUID(false)

    addTaskSignal:Fire(durationLater, callback, uniqueId)

    return uniqueId
end



GlobalTimer.DoTaskImmediately = function(_, uniqueId: string)
    if promises[uniqueId] then
        promises[uniqueId].Promise:cancel()
        pcall(promises[uniqueId].Callback)

        promises[uniqueId] = nil
    end
end


GlobalTimer.CancelTaskImmediately = function(_, uniqueId: string)
    if promises[uniqueId] then
        promises[uniqueId].Promise:cancel()
        promises[uniqueId] = nil
    end
end


return GlobalTimer