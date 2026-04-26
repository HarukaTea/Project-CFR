local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Typing = ReplicatedStorage.Constants.Typing

local t = require(ReplicatedStorage.Packages.t)
local Properties = require(Typing.Properties)

type AllProperties = Properties.AllProperties

export type TriggerCondition = "inCombat" | "outOfCombat" | "passive"

export type ConditionDetails = {
    name: string,
    description: string,
    conditionType: TriggerCondition
}

--- Must be used in `ReplicatedStorage/Constants/Items`
export type ItemDetails = {
    name: string,
    class: string,
    description: string,
    --- creator's ID,
    modeller: number,
    minProperties: { [AllProperties]: number },
    --- If there is no max property then the value will always be set to min property.
    maxProperties: { [AllProperties]: number },
    conditionDetails: { ConditionDetails },
}

local typing = {}

typing.TriggerConditionT = t.literal("inCombat", "outOfCombat", "passive")

typing.ConditionDetails = t.strictInterface({
    name = t.string,
    description = t.string,
    conditionType = typing.TriggerConditionT,
})



return table.freeze(typing)