local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Packages.t)

export type CosmeticType = "armor" | "weapon" | "title"

export type CosmeticData = {
    name: string,
    id: string,
    type: CosmeticType,
    model: Model,
}

local typing = {}

typing.cosmeticTypeT = t.union(t.literal("armor"), t.literal("weapon"), t.literal("title"))

typing.cosmeticDataT = t.strictInterface({
    name = t.string,
    id = t.string,
    type = typing.cosmeticTypeT,
    model = t.instanceIsA("Model"),
})

return table.freeze(typing)