
--- A more reliable `Debris` service

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)

local HarukaDebris = {}


--// Schedules a given `Instance` for destruction within the specified lifetime, by reliable `Promise`
function HarukaDebris:AddItem(instance: Instance, lifeTime: number)
	Promise.delay(lifeTime):andThen(function()
        if instance then instance:Destroy() end
    end):catch(function() end)
end


return HarukaDebris
