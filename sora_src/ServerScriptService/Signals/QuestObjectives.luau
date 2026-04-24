local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Utils.Signal)
local Quest = require(ReplicatedStorage.Constants.Typing.Quest)
local t = require(ReplicatedStorage.Packages.t)

type ObjectiveType = Quest.ObjectiveType
type SignalType = Signal.Signal<string, { Player }>
type SignalInfo = {
    type: ObjectiveType,
    signal: SignalType,
}

local signals = {}

--- Triggered when the enemy is killed.
--- The players will be the ones who were in the match.
signals.enemyKilled = {
    type = "kill",
    signal = Signal(),
} :: SignalInfo

--- Triggered when the player enters the zone.
--- This can be repeated many times.
--- Only one player will be provided.
signals.mapExplored = {
    type = "explore",
    signal = Signal(),
} :: SignalInfo

--- Triggered when a player collects an item in the map.
--- Only one player will be provided.
signals.itemCollected = {
    type = "collect",
    signal = Signal(),
} :: SignalInfo

--- Triggered when a player interacts with an entity (talking).
--- Only one player will be provided.
signals.entityInteracted = {
    type = "interact",
    signal = Signal(),
} :: SignalInfo

--- Retrieves the signal
function signals.getSignal(type: ObjectiveType)
    for key, content in signals do
        if t.callback(content) then
            continue
        end

        if content.type == type then
            return content.signal
        end
    end
end

return signals