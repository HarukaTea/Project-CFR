local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.HarukaShared.Shared.Signal)

local ServerBindables = {
    RToSpawnChar = Signal.new(),
    RToApplyCharCriRPGAttrs = Signal.new(),
    RToSpawnOrb = Signal.new(),
    RToCreateProjectileSymbol = Signal.new(),

    PlayerDied = Signal.new(),
    PlayerGotHit = Signal.new(),
    PlayerCombatEnded = Signal.new(),
    EnemyGotHit = Signal.new(),
    EnemyDied = Signal.new(),


    PlayerTargetingListChanged = Signal.new(),
}

return ServerBindables
