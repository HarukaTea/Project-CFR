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

return {}