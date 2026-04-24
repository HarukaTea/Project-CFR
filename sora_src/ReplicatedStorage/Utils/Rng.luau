local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)

type _Cache = { -- Shorten the lookup
    totalRarityWeight: number, -- Sum of all group rarities, used for weighted group pick in roll()
    groupRarities: {
        [string]: number, -- Keys: group name, values: their rarity
    },
    valueRarities: { -- Keys: group name
        [string]: RngValues
    },
    totalValueWeight: {
        [string]: number -- Keys: group name, values: the total weight of values in it
    }
}

export type RngValues = {
    [string]: number,
}

export type RngEntries = {
    __index: RngEntries,
    _class: RngPool<RngEntries>?,
    name: string,
    rarity: number,
    values: RngValues,

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
    _cache: _Cache,
    _dirty: boolean,
    groups: { [string]: T },

    --- Rebuilds the internal cache. Called automatically before roll() if dirty.
    _refreshCache: (self: RngPool<T>) -> nil,
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
    --- Rolls a group by rarity, then a value within that group by weight.
    --- Returns the rolled group name and value key.
    roll: (self: RngPool<T>) -> (string, string),
}

local ERR_INVALID_KEY: string = "Cannot find %s as it doesn't exist in the rarity %s."

local group = {} :: RngEntries
group.__index = {}

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
    return true
end

function group:appendValue(key: string, delta: number)
    if not self:hasKey(key) then
        return false
    end

    self.values[key] += delta
    return true
end

function group:getKeys()
    local keys: { string } = {}

    for key, _ in self.values do
        table.insert(keys, key)
    end

    return keys
end

function group:getTotalWeight()
    local totalWeight: number = 0

    for _, value in self.values do
        totalWeight += value
    end

    return totalWeight
end

function group:roll()
    local roll: number = math.random() * self:getTotalWeight()

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
    cache.groupRarities = {}
    cache.valueRarities = {}
    cache.totalValueWeight = {}

    --- O(n) process
    for _, group in self.groups do
        local entryName: string = group.name
        local groupRarity: number = group.rarity

        cache.groupRarities[entryName] = groupRarity
        cache.totalRarityWeight += groupRarity
        cache.valueRarities[entryName] = group.values
        cache.totalValueWeight[entryName] = group:getTotalWeight()
    end
end

function class:addGroup(rngGroup: RngEntries)
    if self:hasGroup(rngGroup.name) then
        warn(`Cannot add the group called '{rngGroup.name}' as it already exists.`)
        return false
    end

    table.insert(self.groups, rngGroup)
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

function class:hasGroup(entryName: string)
    return self:getGroup(entryName) ~= nil
end

function class:getGroup(entryName: string)
    return self.groups[entryName]
end

function class:roll()
    if self._dirty then
        self:_refreshCache()
        self._dirty = false
    end

    local cache = self._cache
    local roll: number = math.random() * cache.totalRarityWeight

    for entryName, rarity in cache.groupRarities do
        roll -= rarity
        if roll <= 0 then
            return table.pack(entryName, self.groups[entryName]:roll())
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