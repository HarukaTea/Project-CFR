--- Level -> Total exp required to reach that level from level 1 (cached).
--- `f(x) = b + round(g(x) * h(x), 0)`, where `g(x) = a(x-2)(1 + m(x-2))`, `h(x) = c^(x-2)`, for x >= 2; f(x) = 0 for x <= 1.
--- In case you're confused about the formula, we have Desmos calculator for it.

local constructor = {}
constructor.__index = constructor

export type LevelFormulaConfig = {
    baseExp: number,
    expPerLevel: number,
    multiPerLevel: number,
    compoundingFactor: number,
}

export type LevelFormula = typeof(setmetatable(
    {} :: { _config: LevelFormulaConfig, _levelCache: { [number]: number } },
    constructor
))

--- Creates a new formula with configuration included.
function constructor.new(config: LevelFormulaConfig): LevelFormula
    local self = setmetatable({}, constructor)
    self._config = config
    self._levelCache = {}
    return self
end

function constructor:_expForLevel(level: number): number
    local config = self._config

    if level <= 1 then
        return 0
    end

    local trueNumber: number = level - 2
    local additiveExp: number = (config.expPerLevel * trueNumber) * (1 + config.multiPerLevel * trueNumber)
    local compoundingFactor: number = config.compoundingFactor ^ trueNumber

    return config.baseExp + math.round(additiveExp * compoundingFactor)
end

function constructor:_populateCache(upToLevel: number)
    if upToLevel <= 1 then
        return
    end

    local level: number = #self._levelCache

    while level < upToLevel do
        self._levelCache[level + 1] = self:_expForLevel(level + 1)
        level += 1
    end
end

--- Returns the level from exp.
function constructor:expToLevel(exp: number): number
    if exp <= 0 then
        return 1
    end

    local high: number = 2
    local low: number = high // 2

    self:_populateCache(high)

    while self._levelCache[high] <= exp do
        high *= 2
        self:_populateCache(high)
    end
    
    while low < high - 1 do
        local mid: number = low + (high - low) // 2

        self:_populateCache(mid)
        
        if self._levelCache[mid] <= exp then
            low = mid
        else
            high = mid
        end
    end

    return low
end

--- Returns the total exp required to reach the level.
function constructor:levelToExp(level: number): number
    self:_populateCache(level)
    return self._levelCache[level] or 0
end

--- Returns the absolute exp difference between two levels.
function constructor:expDifference(x_level: number, y_level: number): number
    return math.abs(self:levelToExp(x_level) - self:levelToExp(y_level))
end

return constructor