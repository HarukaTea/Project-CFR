--[[
    Used by the components of ServerScriptService/API/Player to get data from it.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Promise = require(ReplicatedStorage.Utils.Promise)
local Typing = require(ServerStorage.Constants.Typing.PlayerData)

type TransformSaveslotFunc = (data: Typing.SaveSlot) -> boolean
type PlayerData = Typing.PlayerData
type SaveSlot = Typing.SaveSlot

export type API = {
    get: (player: Player) -> PlayerData,
    update: (player: Player, transformFunc: (data: PlayerData) -> boolean) -> Promise.TypedPromise<boolean>,
    getSaveSlot: (player: Player, index: number?) -> SaveSlot?,
    updateSaveSlot: (player: Player, transformFunc: TransformSaveslotFunc, index: number?) -> Promise.TypedPromise<boolean>,
}

return {}