local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(ReplicatedStorage.Constants.Typing.PlayerData)
local Version = require(ReplicatedStorage.Constants.Enums.Version)

local template = {}

template.maxSaveSlots = 3 :: number
template.statPointsPerLevel = 2 :: number

template.globalCurrencies = {
    astral = 0,
} :: { [PlayerData.GlobalCurrency]: number }

template.statPoints = {
    str = 0,
    agi = 0,
    int = 0,
    vit = 0,
    dex = 0,
} :: { [PlayerData.StatType]: number }

template.inventoryKeys = {
    weapons = {},
    accessories = {},
    armors = {},
} :: { [PlayerData.InventoryType]: {} }

template.classTypes = {
    base = {},
    dev = {},
    unique = {},
    variant = {},
} :: { [string]: {} }

template.classData = {
    expPoints = 0,
    perks = {},
    quests = {},
} :: PlayerData.ClassData

template.saveSlot = {
    name = "Unnamed Save Slot",
    currencies = {
        gold = 0,
    },
    materials = {},
    expPoints = 0,
    selectedItems = template.inventoryKeys,
    inventory = template.inventoryKeys,
    classes = template.classTypes,
    statPoints = template.statPoints,
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
    dataVersion = Version,
} :: PlayerData.SaveSlot

template.playerData = {
    selectedSaveSlot = 0,
    globalCurrencies = template.globalCurrencies,
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
    internal = {
        automatedLogs = {},
        itemsGained = 0,
    },
} :: PlayerData.PlayerData

return table.freeze(template)