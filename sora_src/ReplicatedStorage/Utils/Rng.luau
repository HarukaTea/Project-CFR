local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)

type _PoolCache = { -- Shorten the lookup
    totalRarityWeight: number, -- Sum of all group rarities, used for weighted group pick in roll()
    entryRarities: {
        [string]: number, -- Keys: group name, values: their rarity
    },
    entryNames: { string },
}

type _EntryCache = {
    totalWeight: number,
    keys: { string },
}

export type RngValues = {
    [string]: number,
}

export type RngEntries = {
    __index: RngEntries,
    _class: RngPool<RngEntries>?,
    _cache: _EntryCache,
    _dirty: boolean,
    name: string,
    rarity: number,
    --- Immutable values, change via `:setValue()` or `:appendValue()`.
    values: RngValues,

    --- Refreshes the internal cache. Called automatically before roll() if dirty.
    _refreshCache: (self: RngEntries) -> nil,
    --- Validates the cache and refreshes it if dirty.
    _validateCache: (self: RngEntries) -> nil,
    --- Returns true if the key exists in this group's values.
    hasKey: (self: RngEntries, key: string) -> boolean,
    --- Returns the raw weight of a key. Returns 0 if the key doesn't exist.
    getKeyValue: (self: RngEntries, key: string) -> number?,
    --- Sets the weight of an existing key. Returns false if the key doesn't exist or value is invalid.
    setValue: (self: RngEntries, key: string, value: number) -> boolean,
    --- Adds delta to the weight of an existing key. Useful for luck boosts on individual items.
    appendValue: (self: RngEntries, key: string, delta: number) -> boolean,
    --- Returns all keys in this group's values.
    getKeys: (self: RngEntries) -> { string },
    --- Returns the sum of all weights in this group (unaffected by rarity).
    getTotalWeight: (self: RngEntries) -> number,
    --- Returns the chosen key.
    roll: (self: RngEntries) -> string,
}

export type RngPool<T> = {
    __index: RngPool<T>,
    _cache: _PoolCache,
    _dirty: boolean,
    groups: { [string]: T },

    --- Rebuilds the internal cache. Called automatically before roll() if dirty.
    _refreshCache: (self: RngPool<T>) -> nil,
    --- Validates the cache and refreshes it if dirty.
    _validateCache: (self: RngPool<T>) -> nil,
    --- Adds a group. Marks the cache dirty. Returns false if a group with that name already exists.
    addGroup: (self: RngPool<T>, rngGroup: T) -> boolean,
    --- Removes and returns a group by name. Returns nil if not found.
    deleteGroup: (self: RngPool<T>, entryName: string) -> T?,
    --- Checks if the group name exists.
    hasGroup: (self: RngPool<T>, entryName: string) -> boolean,
    --- Returns the group table directly. Mutate it freely; call roll() and cache auto-refreshes.
    getGroup: (self: RngPool<T>, entryName: string) -> T?,
    --- Returns all group names currently registered.
    getGroupNames: (self: RngPool<T>) -> { string },
    --- Returns the sum of all group rarities.
    getTotalRarityWeight: (self: RngPool<T>) -> number,
    --- Rolls a group by rarity, then a value within that group by weight.
    --- Returns the rolled group name and value key.
    roll: (self: RngPool<T>) -> (string, string),
}

local ERR_INVALID_KEY: string = "Cannot find %s as it doesn't exist in the rarity %s."

local group = {
    _cache = {},
    _dirty = false,
} :: RngEntries
group.__index = {}

function group:_refreshCache()
    local cache = self._cache
    local totalWeight: number = 0
    local keys: { string } = {}

    for key, value in self.values do
        totalWeight += value
        table.insert(keys, key)
    end

    cache.totalWeight = totalWeight
    cache.keys = keys
end

function group:_validateCache()
    if self._dirty then
        self:_refreshCache()
        self._dirty = false
    end
end

function group:getKeyValue(key: string)
    return self.values[key]
end

function group:hasKey(key: string)
    return self:getKeyValue(key) ~= nil
end

function group:setValue(key: string, value: number)
    if not self:hasKey(key) then
        warn(ERR_INVALID_KEY.format(key, self.name))
        return false
    end

    self.values[key] = value
    self._dirty = true
    return true
end

function group:appendValue(key: string, delta: number)
    if not self:hasKey(key) then
        return false
    end

    self.values[key] += delta
    self._dirty = true
    return true
end

function group:getKeys()
    self:_validateCache()
    return self._cache.keys
end

function group:getTotalWeight()
    self:_validateCache()
    return self._cache.totalWeight
end

function group:roll()
    self:_validateCache()

    local roll: number = math.random() * self._cache.totalWeight

    for key, value in self.values do
        roll -= value
        if roll <= 0 then
            return key
        end
    end
end

local class = {
    _cache = {},
    _dirty = false,
    groups = {},
} :: RngPool<RngEntries>
class.__index = class

function class:_refreshCache()
    local cache = self._cache
    cache.totalRarityWeight = 0
    cache.entryRarities = {}
    cache.entryNames = {}

    --- O(n) process
    for _, group in self.groups do
        local entryName: string = group.name
        local groupRarity: number = group.rarity

        cache.entryRarities[entryName] = groupRarity
        cache.totalRarityWeight += groupRarity
        table.insert(cache.entryNames, entryName)
    end
end

function class:_validateCache()
    if self._dirty then
        self:_refreshCache()
        self._dirty = false
    end
end

function class:addGroup(rngGroup: RngEntries)
    if self:hasGroup(rngGroup.name) then
        warn(`Cannot add the group called '{rngGroup.name}' as it already exists.`)
        return false
    end

    self.groups[rngGroup.name] = rngGroup
    self._dirty = true
    return true
end

function class:deleteEntry(entryName: string)
    if not self:hasGroup(entryName) then
        warn(`Cannot delete a group called '{entryName}' as it doesn't exist.`)
        return
    end

    local group: RngEntries = self:getGroup(entryName)
    self.groups[entryName] = nil
    self._dirty = true
    return group
end

function class:getTotalRarityWeight()
    self:_validateCache()
    return self._cache.totalRarityWeight
end

function class:getGroupNames()
    self:_validateCache()
    return self._cache.entryNames
end

function class:hasGroup(entryName: string)
    return self:getGroup(entryName) ~= nil
end

function class:getGroup(entryName: string)
    return self.groups[entryName]
end

function class:roll()
    self:_validateCache()

    local cache = self._cache
    local roll: number = math.random() * cache.totalRarityWeight

    for entryName, rarity in cache.entryRarities do
        roll -= rarity
        if roll <= 0 then
            return entryName, self.groups[entryName]:roll()
        end
    end
end

local api = {}

--- Requires `RngEntries` to work.
function api.createPool(groups: { RngEntries }): RngPool<RngEntries>
    local newClass = setmetatable({}, class)

    if t.table(groups) then
        for _, group in groups do
            newClass:addGroup(group)
        end
    end

    return newClass
end

--- Required for separation
function api.createEntries(name: string, rarity: number, values: RngValues): RngEntries
    local newGroup = setmetatable({
        name = name,
        rarity = rarity,
        values = values
    }, group) :: RngEntries

    return newGroup
end

return table.freeze(api)