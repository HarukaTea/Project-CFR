
--- A more reliable `Debris` service

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)


local HarukaDebris = {}

local addTaskSignal = Signal.new()


addTaskSignal:Connect(function(instance: Instance, lifeTime: number)
    Promise.delay(lifeTime):andThen(function()
        if instance then instance:Destroy() end
    end):catch(function() end)
end)


--// Schedules a given `Instance` for destruction within the specified lifetime, by reliable `Promise`
function HarukaDebris:AddItem(instance: Instance, lifeTime: number)
	addTaskSignal:Fire(instance, lifeTime)
end


return HarukaDebris