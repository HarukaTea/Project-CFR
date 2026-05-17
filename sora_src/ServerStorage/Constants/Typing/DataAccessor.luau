--[[
    Used by the components of ServerScriptService/API/PlayerData to get data from it.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Utils.Promise)
local Typing = require(ReplicatedStorage.Constants.Typing.PlayerData)
local Signal = require(ReplicatedStorage.Utils.Signal)

type TransformSaveslotFunc = (data: Typing.SaveSlot) -> boolean
type PlayerData = Typing.PlayerData
type SaveSlot = Typing.SaveSlot

--- This is always used in resolved function.
export type PromiseData = Promise.TypedPromise<boolean, string?>

export type API = {
    --- Returns the full player data.
    get: (player: Player) -> PlayerData,
    --- Checks if the player has an active slot index.
    --- Sugar for `api.getSaveSlot(player, index) ~= nil`.
    --- If the index is not provided, then the selected index will be used as a substitute.
    hasActiveSlot: (player: Player, index: number?) -> boolean,
    --- Transforms the full player data. Returns a promise resolving to whether the update succeeded.
    update: (player: Player, transformFunc: (data: PlayerData) -> boolean) -> Promise.TypedPromise<boolean?>,
    --- Returns the save slot at `index`, or the currently selected save slot if `index` is nil.
    getSaveSlot: (player: Player, index: number?) -> SaveSlot?,
    --- Transforms the save slot at `index`, or the currently selected save slot if `index` is nil.
    updateSaveSlot: (player: Player, transformFunc: TransformSaveslotFunc, index: number?) -> Promise.TypedPromise<boolean?>,
    --- Returns the currently selected save slot index.
    getSelectedSaveSlotIndex: (player: Player) -> number,
    --- Contains all of the signals that is triggered by the player interaction.
    playerSignals: {
        --- Triggered when the player's data get reset.
        dataReset: Signal.Signal<Player>,
        --- Triggered when the player chooses a save slot.
        --- Params... `player: Player, saveSlotNumber: number`
        saveSlotSelected: Signal.Signal<Player, number>,
    },
}

return {}