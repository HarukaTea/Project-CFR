local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = ReplicatedStorage.Constants.Enums

local BitsEnum = require(Enums.Bits)

local t = require(ReplicatedStorage.Packages.t)
local Lync = require(ReplicatedStorage.Packages.Lync)

export type SlotCurrency = "gold"
export type SpecialCurrency = "astral"
export type PurchaseType = "devProducts" | "gamePasses"

export type RobuxTransaction = {
    productName: string,
    purchaseDate: number,
    priceAmount: number,
}

local typing = {}

typing.currenciesDataT = t.strictInterface({
    gold = t.number,
})

typing.robuxTransactionT = t.strictInterface({
    productName = t.string,
    purchaseDate = t.number,
    priceAmount = t.number,
})

typing.currenciesDataLync = Lync.map(Lync.string, BitsEnum.f64Lync)

typing.robuxTransactionLync = Lync.struct({
    productName = Lync.string(200),
    purchaseDate = BitsEnum.f64Lync,
    priceAmount = Lync.int(0, 1_000_000),
})

return table.freeze(typing)
