--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

return {
    InterSkyTowerQuest = Signal.new(),
}