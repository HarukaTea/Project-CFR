
-- prevent attaching listeners

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = require(ReplicatedStorage.HarukaShared.Library.Events)


Events.RefreshCullingAsync_S.On(function() end)