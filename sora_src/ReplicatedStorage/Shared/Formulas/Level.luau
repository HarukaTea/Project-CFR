--- Level -> Total exp required to reach that level from level 1 (cached).
--- `f(x) = b + round(g(x) * h(x), 0)`, where `g(x) = a(x-1)(1 + m(x-1))`, `h(x) = c^(x-1)`.
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

function constructor.new(config: LevelFormulaConfig): LevelFormula
    local self = setmetatable({}, constructor)
    self._config = config
    self._levelCache = { [1] = 0 }
    return self
end

function constructor:_expForLevel(x: number): number
    local t = x - 1
    local cfg = self._config
    return cfg.baseExp + math.round(cfg.expPerLevel * t * cfg.compoundingFactor ^ t * (1 + cfg.multiPerLevel * t))
end

function constructor:_populateCache(upToLevel: number)
    local level = #self._levelCache
    while level < upToLevel do
        self._levelCache[level + 1] = self:_expForLevel(level + 1)
        level += 1
    end
end

--- Returns the level from exp.
function constructor:expToLevel(exp: number): number
    local level = 1
    self:_populateCache(level + 1)
    while self._levelCache[level + 1] <= exp do
        level += 1
        self:_populateCache(level + 1)
    end
    return level
end

--- Returns the total exp required to reach the level.
function constructor:levelToExp(level: number): number
    self:_populateCache(level)
    return self._levelCache[level]
end

--- Returns the absolute exp difference between two levels.
function constructor:expDifference(x_level: number, y_level: number): number
    return math.abs(self:levelToExp(x_level) - self:levelToExp(y_level))
end

return constructor