local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local PlayerData = require(ServerStorage.Constants.Typing.PlayerData)
local Version = require(ReplicatedStorage.Constants.Attributes.Version)

local template = {}

template.maxSaveSlots = 3 :: number
template.statPointsPerLevel = 2 :: number

template.baseStatPoints = {
    str = 0,
    agi = 0,
    int = 0,
    vit = 0,
    dex = 0,
}

template.baseSaveSlot = {
    name = "Unnamed Save Slot",
    currencies = {
        gold = 0,
    },
    expPoints = 0,
    inventory = {
        weapons = {},
        accessories = {},
        armors = {},
        materials = {},
    },
    classes = {},
    statPoints = template.baseStatPoints,
    questRecurrences = {
        daily = {},
        weekly = {},
        monthly = {},
    },
    events = {},
    creationDate = 0,
    playTime = 0,
    isArchived = false,
    archiveDate = 0,
    dataVersion = Version ,
} :: PlayerData.SaveSlot

template.basePlayerData = {
    selectedSaveSlot = 0,
    cosmetics = {
        armors = {},
        titles = {},
        weapons = {},
    },
    saveSlots = {},
    robuxPurchases = {
        devProducts = {},
        gamePasses = {},
    },
    settings = {},
    joinDate = 0,
    dataVersion = Version,
} :: PlayerData.PlayerData

return table.freeze(template)