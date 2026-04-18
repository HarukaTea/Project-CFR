local ServerStorage = game:GetService("ServerStorage")
local PlayerData = require(ServerStorage.Constants.Typing.PlayerData)

local template = {}

template.baseSaveSlot = {
    expPoints = 0,
    classes = {},
    stats = {
        STR = 0,
        AGI = 0,
        INT = 0,
        VIT = 0,
        DEX = 0,
    },
    isArchived = false,
    archiveDate = 0,
} :: PlayerData.SaveSlot

template.basePlayerData = {
    saveSlot = {},
    robuxPurchases = {},
    joinDate = 0,
} :: PlayerData.PlayerData

return table.freeze(template)