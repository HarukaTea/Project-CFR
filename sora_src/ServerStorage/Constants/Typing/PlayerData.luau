local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)

export type StatType = "STR" | "AGI" | "INT" | "VIT" | "DEX"

export type RobuxTransaction = {
    productName: string,
    purchaseDate: number,
    priceAmount: number,
}

export type ClassPerkData = {
    quantity: number,
}

export type ClassData = {
    expPoints: number,
    perks: {
        [string]: ClassPerkData
    }
}

export type SaveSlot = {
    expPoints: number,
    classes: {
        [string]: ClassData,
    },
    stats: {
        [StatType]: number,
    },
    creationDate: number, -- formatted in UNIX time
    playTime: number,
    isArchived: boolean,
    archiveDate: number, -- formatted in UNIX time
}

export type PlayerData = {
    robuxPurchases: {
        developerProducts: {RobuxTransaction},
        gameProducts: {RobuxTransaction},
    },
    saveSlot: {SaveSlot},
    joinDate: number, -- formatted in UNIX time
}

local typing = {}

typing.perksDataT = t.strictInterface({
    quantity = t.number
})

typing.classDataT = t.strictInterface({
    expPoints = t.number,
    perks = t.map(t.string, typing.perksDataT),
})

typing.dataSlotT = t.strictInterface({
    expPoints = t.number,
    classes = t.map(t.string, typing.classDataT),
    stats = t.map(t.string, t.number),
    creationDate = t.number,
    playTime = t.number,
    isArchived = t.boolean,
    archiveDate = t.number,
})

typing.robuxTransactionT = t.array({
    productName = t.string,
    purchaseDate = t.number,
    priceAmount = t.number,
})

typing.schema = t.strictInterface({
    saveSlot = t.array(typing.dataSlotT),
    robuxPurchases = t.strictInterface({
        developerProducts = typing.robuxTransactionT,
        gameProducts = typing.robuxTransactionT,
    }),
    joinDate = t.number,
})

return table.freeze(typing)