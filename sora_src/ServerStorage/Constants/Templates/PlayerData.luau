local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(ReplicatedStorage.Constants.Typing.PlayerData)
local Version = require(ReplicatedStorage.Constants.Enums.Version)
local Table = require(ReplicatedStorage.Utils.Table)

local template = {}

template.statPoints = {
    str = 0,
    agi = 0,
    int = 0,
    vit = 0,
    dex = 0,
} :: { [PlayerData.StatType]: number }

template.classData = {
    expPoints = 0,
    perks = {},
    quests = {},
} :: PlayerData.ClassData

template.statisticsDamageData = {
    totalPhysical = 0,
    meleePhysical = 0,
    rangePhysical = 0,
    magical = 0,
    poison = 0,
    burn = 0,
} :: PlayerData.StatisticsDamageData

template.statisticsHealData = {
    normal = 0,
    overTime = 0,
    regen = 0,
} :: PlayerData.StatisticsHealData

template.statisticsData = {
    itemsGained = 0,
    kills = {},
    damages = {
        done = Table.deepCopy(template.statisticsDamageData),
        taken = Table.deepCopy(template.statisticsDamageData),
        absorbed = Table.deepCopy(template.statisticsDamageData),
        blocked = Table.deepCopy(template.statisticsDamageData),
        nullified = Table.deepCopy(template.statisticsDamageData),
    },
    heals = {
        done = Table.deepCopy(template.statisticsHealData),
        taken = Table.deepCopy(template.statisticsHealData),
    },
} :: PlayerData.StatisticsData

template.saveSlot = {
    name = "Unnamed Save Slot",
    currencies = {
        gold = 0,
    },
    materials = {},
    expPoints = 0,
    selectedItems = {
        normal = {},
        cosmetic = {},
    },
    inventory = {},
    classes = {},
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
    statistics = template.statisticsData,
} :: PlayerData.SaveSlot

template.playerData = {
    selectedSaveSlot = 0,
    specialCurrencies = {},
    cosmetics = {},
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