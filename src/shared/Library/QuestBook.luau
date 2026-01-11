
export type QuestObjectiveJSON = {
    ObjectiveId: string,
    Default: number,
    Target: number,
}

export type QuestJSON = {
    Id: string,
    QuestType: "Main" | "Side" | "Town",

    Name: string,
    Target: string,
    NPC: string,
    WorldLocatorId: string,

    Repeatable: boolean?,

    Rewards: {
        [string]: number?,
    },
    ItemRewards: {
        [string]: number?,
    },

    Objectives: {
        [number]: QuestObjectiveJSON,
    }
}

local quests = {}

return quests