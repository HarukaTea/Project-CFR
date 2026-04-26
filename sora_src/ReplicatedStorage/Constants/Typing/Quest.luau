local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)

export type ObjectiveType = "kill" | "collect" | "interact" | "explore"

export type QuestObjective = {
    type: ObjectiveType,
    target: string,
    required: number,
    description: string,
    hintMessage: string,
}

export type QuestData = {
    title: string,
    description: string,
    objectives: { [string]: QuestObjective },
}

local typing = {}

typing.ObjectiveTypeT = t.literal("kill", "collect", "interact", "explore")

typing.ObjectivesT = t.strictInterface({
    type = typing.ObjectiveTypeT,
    target = t.string,
    required = t.number,
    description = t.string,
    hintMessage = t.string,
})

typing.QuestDataT = t.strictInterface({
    title = t.string,
    description = t.string,
    objectives = t.map(t.string, typing.ObjectivesT),
})

return table.freeze(typing)