local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums
local Formulas = ReplicatedStorage.Shared.Formulas
local Typing = ReplicatedStorage.Constants.Typing

local LevelEnums = require(Enums.PlayerLevel)
local StatPointsEnums = require(Enums.StatPoints)

local LevelFormula = require(Formulas.Level)

local StatPointsTyping = require(Typing.PlayerData.StatPoints)

local levelCalculator = LevelFormula.new({
    baseExp = LevelEnums.baseExp,
    expPerLevel = LevelEnums.expPerLevel,
    multiPerLevel = LevelEnums.multiPerLevel,
    compoundingFactor = LevelEnums.compoundingFactor,
})

type StatsData = StatPointsTyping.StatsData
type LevelStatus = {
    currentLevel: number,
    currentExp: number,
    levelExpTotal: number,
    expRemaining: number,
    percentage: number,
}

local function countStatPointsSpent(newStats: StatsData): number
    local spent = 0

    for _, value in newStats do
        spent += value
    end

    return spent
end

local statNames = {}
local api = {}

--- Returns the level status relative to a target level.
function api.getLevelStatus(currentExp: number, nextLevel: number): LevelStatus
    local currentLevel = levelCalculator:expToLevel(currentExp)
    local currentLevelExp = levelCalculator:levelToExp(currentLevel)
    local nextLevelExp = levelCalculator:levelToExp(nextLevel)

    local currentCulledExp = currentExp - currentLevelExp
    local nextCulledExp = nextLevelExp - currentLevelExp

    return table.freeze({
        currentLevel = currentLevel,
        currentExp = currentCulledExp,
        levelExpTotal = nextCulledExp,
        expRemaining = nextLevelExp - currentExp,
        percentage = math.clamp(currentCulledExp / nextCulledExp, 0, 1),
    })
end

--- Returns the level status toward the next level automatically derived from the current exp.
function api.getNextLevelStatus(currentExp: number): LevelStatus
    local nextLevel = levelCalculator:expToLevel(currentExp) + 1
    return api.getLevelStatus(currentExp, nextLevel)
end

function api.expDifference(x_level: number, y_level: number): number
    return levelCalculator:expDifference(x_level, y_level)
end

function api.expToLevel(expPoints: number): number
    return levelCalculator:expToLevel(expPoints)
end

function api.levelToExp(level: number): number
    return levelCalculator:levelToExp(level)
end

function api.getTotalStatPoints(expPoints: number): number
    return levelCalculator:expToLevel(expPoints) * StatPointsEnums.statPointsPerLevel
end

function api.getRemainingStatPoints(expPoints: number, newStats: StatsData): number
    local total = api.getTotalStatPoints(expPoints)
    return total - countStatPointsSpent(newStats)
end

function api.canAllocateStatPoints(expPoints: number, newStats: StatsData): boolean
    if not StatPointsTyping.statPointsT(newStats) then
        return false    
    end

    local totalStatPoints = api.getTotalStatPoints(expPoints)
    local statPointsUsed = countStatPointsSpent(newStats)

    return totalStatPoints >= statPointsUsed and statPointsUsed >= 0
end

-- INIT --

type statDetails = {
    abbv: string,
    full: string,
}

for _, details: statDetails in StatPointsEnums.basicStats do
    table.insert(statNames, details.abbv)
end

return table.freeze(api)