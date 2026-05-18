local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing
local Enums = ReplicatedStorage.Constants.Enums

local PropertiesTyping = require(Typing.Properties)
local PropertiesEnum = require(Enums.Properties)
local BitsEnum = require(Enums.Bits)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

type AllProperties = PropertiesTyping.AllProperties

export type InventoryType = "weapons" | "accessories" | "armors"

--- The property number is usually between 0 and 1.
--- 0 is being the minimum value while
--- 1 is the maximum value.
--- It can go below 0 or above 1 for testing purposes.
export type ItemData = {
    type: "test" | "release",
    --- Based on Internal.itemsGained
    id: number,
    properties: { [AllProperties]: number },
    obtainedAt: number, -- UNIX time
}

export type InventoryData = {
    --- Separated by item name
    [string]: { ItemData }
}

local typing = {}

typing.selectedItemsT = t.strictInterface({
    normal = t.array(t.number),
    cosmetic = t.array(t.string),
})

typing.itemDataT = t.strictInterface({
    type = t.union(t.literal("test"), t.literal("release")),
    id = t.number,
    properties = t.map(t.string, t.number),
    obtainedAt = t.number,
})

typing.inventoryT = t.map(t.string, t.array(typing.itemDataT))

typing.selectedItemsLync = Lync.struct({
    normal = Lync.array(BitsEnum.u32Lync),
    cosmetic = Lync.array(Lync.string),
})

typing.itemDataLync = Lync.struct({
    type = Lync.enum("test", "release"),
    id = BitsEnum.u32Lync,
    properties = Lync.map(Lync.string, Lync.float(
        PropertiesEnum.maxRangePercentages.min,
        PropertiesEnum.maxRangePercentages.max,
        0.001
    )),
    obtainedAt = BitsEnum.f64Lync,
})

typing.inventoryLync = Lync.map(Lync.string, Lync.array(typing.itemDataLync))

return table.freeze(typing)
