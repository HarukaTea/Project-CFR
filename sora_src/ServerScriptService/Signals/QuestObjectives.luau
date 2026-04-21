local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Utils.Signal)
local Quest = require(ReplicatedStorage.Constants.Typing.Quest)

type ObjectiveType = Quest.ObjectiveType
type ObjectiveBase = { type: ObjectiveType }
type WithMultiplePlayers = { signal: Signal.Signal<string, { Player }> }
type WithSinglePlayer = { signal: Signal.Signal<string, Player> }

local signals = {}

--- Triggered when the enemy is killed.
--- The players will be the ones who were in the match.
signals.enemyKilled = {
    type = "kill",
    signal = Signal(),
} :: ObjectiveBase & WithMultiplePlayers

--- Triggered when the player enters the zone.
--- This can be repeated many times.
signals.mapExplored = {
    type = "explore",
    signal = Signal(),
} :: ObjectiveBase & WithSinglePlayer

--- Triggered when a player collects an item in the map.
signals.itemCollected = {
    type = "collect",
    signal = Signal(),
} :: ObjectiveBase & WithSinglePlayer

--- Triggered when a player interacts with an entity (talking).
signals.entityInteracted = {
    type = "collect",
    signal = Signal(),
} :: ObjectiveType & WithSinglePlayer

return signals