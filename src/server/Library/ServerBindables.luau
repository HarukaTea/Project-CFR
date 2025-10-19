--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)

return {
    RToSpawnChar = Signal.new(),
    RToSpawnOrb = Signal.new(),
    RToCreateProjectileSymbol = Signal.new(),

    RToUpdateLeaderboardRank = Signal.new(),
    RToCheckLeaderboardRank = Signal.new(),

    RToChallengeAbyss = Signal.new(),

    PlayerDied = Signal.new(),

    PartyInvite = Signal.new(),
}