local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ReplicatedTyping = ReplicatedStorage.Constants.Typing
local ServerTyping = ServerStorage.Constants.Typing
local Network = ReplicatedStorage.Network

local PlayerDataTyping = require(ReplicatedTyping.PlayerData)
local DataAccessorTyping = require(ServerTyping.DataAccessor)

local PlayerDataTemplates = require(ServerStorage.Constants.Templates.PlayerData)

local ClassNetwork = require(Network.Classes)

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local ERR_CLASS_NOT_FOUND: string = "Player '%s' does not have a class called '%s'."
local ERR_CLASS_ALREADY_EXISTS: string = "Player '%s' already has a class called '%s'."

type PromiseData = DataAccessorTyping.PromiseData
type ClassData = PlayerDataTyping.ClassData

local dataAccessor = {} :: DataAccessorTyping.API
local inited: boolean = false
local api = {}

local function syncClassData(player: Player)
    local saveSlotData = dataAccessor.getSaveSlot(player)
    ClassNetwork.classesUpdated:send(saveSlotData.classes, player)
end

--- Separated since it might have further use in the future.
local function onSaveSlotSelected(player: Player, _index: number)
    syncClassData(player)
end

-- INIT -- 

function api.init(accessor: DataAccessorTyping.API)
    if inited then
        return
    end

    dataAccessor = accessor
    inited = true

    dataAccessor.playerSignals.saveSlotSelected:Connect(onSaveSlotSelected)
end

-- API --

--- Returns whether a player has a class unlocked. If the player does not have an active save slot, returns false.
function api.hasClass(player: Player, className: string, index: number?): boolean
    return api.getClass(player, className, index) ~= nil
end

--- Returns the class data for a player's class. If the player does not have the class, returns nil.
function api.getClass(player: Player, className: string, index: number?): ClassData?
    if not dataAccessor.hasActiveSlot(player, index) then
        return nil
    end

    return dataAccessor.getSaveSlot(player, index).classes[className]
end

--- Unlocks a class for a player. Returns whether the class was successfully unlocked (false if the player already had the class or if there was an error).
function api.unlockClass(player: Player, className: string, index: number?): PromiseData
    return dataAccessor.updateSaveSlot(player, function(data)
        if data.classes[className] ~= nil then
            return false
        end

        data.classes[className] = TableUtil.Copy(PlayerDataTemplates.classData, true)
        return true
    end, index)

    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, ERR_CLASS_ALREADY_EXISTS:format(player.Name, className)
        end

        ClassNetwork.classUnlocked:send(className, player)
        syncClassData(player)
        return true
    end)
end

--- Return the experience points for a player's class. If the player does not have the class or an active save slot, returns 0.
function api.getExp(player: Player, className: string, index: number?): number
    if not dataAccessor.hasActiveSlot(player, index) then
        return 0
    end

    local saveSlotData = dataAccessor.getSaveSlot(player, index)
    local classData = saveSlotData.classes[className]
    return classData and classData.expPoints or 0
end

--- Adds experience points to a player's class. Returns whether the operation was successful (false if the player does not have the class or if there was an error).
function api.addExp(player: Player, className: string, amount: number, index: number): PromiseData
    local nextExp: number = api.getExp(player, className, index) + amount
    return api.setExp(player, className, nextExp, index)
end

--- Sets the experience points for a player's class. Returns whether the operation was successful (false if the player does not have the class or if there was an error).
function api.setExp(player: Player, className: string, amount: number, index: number?): PromiseData
    return dataAccessor.updateSaveSlot(player, function(data): boolean
        if data.classes[className] == nil then
            return false
        end

        data.classes[className].expPoints = amount
        return true
    end, index)


    :andThen(function(isSuccess: boolean)
        if not isSuccess then
            return false, ERR_CLASS_NOT_FOUND:format(player.Name, className)
        end

        syncClassData(player)
        return true
    end)
end


return table.freeze(api)