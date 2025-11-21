
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

    Repeatable: boolean,
    DeliverType: "Normal" | "Objective",

    RequiredQuests: { string },
    Rewards: {
        Gold: number?,
        EXP: number?,
        Astra: number?,
    },

    Objectives: {
        [number]: QuestObjectiveJSON,
    }
}


local quests = {
    --// Main

    --// Side


    --// Town
}


for i = 2, 50 do
    if not quests["Main"..i] then break end

    for j = 1, i - 1 do
        table.insert(quests["Main"..i].RequiredQuests, "Main"..j)
    end
end


return quests