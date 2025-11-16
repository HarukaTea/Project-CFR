
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



local template = {
    Id = "",
    QuestType = "Main",

    Name = "",
    Target = "",
    NPC = "",
    WorldLocatorId = "",

    Repeatable = false,
    RequiredQuests = {
        "Main1"
    },

    Rewards = {
        Gold = 15
    },
    Objectives = {
        [1] = {
            ObjectiveId = "Slime",
            Default = 0,
            Target = 5,
        }
    }
}



local quests = {
    --// Main
    Main1 = {
        Id = "Main1",
        QuestType = "Main",

        Name = "Adventurer Guild",
        Target = "Head to the Guild",
        NPC = "",
        WorldLocatorId = "InitusGuildLocator",

        Repeatable = false,
        RequiredQuests = {},

        Rewards = {
            Gold = 150
        },
        Objectives = {}
    }


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