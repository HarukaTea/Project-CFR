--!nocheck

local template = {
    Id = "",
    QuestType = "Main" :: "Main" | "Side" | "Town",

    Name = "",
    Desc = "",
    Target = "",
    NPC = "",
    WorldLocatorId = "",

    Repeatable = false,
    DeliverType = "Normal" :: "Normal" | "Objective",

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
    --// Side
    SideTowerTheKey = {
        Id = "SideTowerTheKey",
        QuestType = "Side",

        Name = "Sky Tower: The Key",
        Desc = "",
        Target = "Find the key",
        NPC = "",
        WorldLocatorId = "",

        Repeatable = false,
        DeliverType = "Normal",

        RequiredQuests = {},

        Rewards = {
            EXP = 15,
            Gold = 150
        },
        Objectives = {}
    }


    --// Town
}


for i = 2, 50 do
    if not quests["Main"..i] then break end

    for j = 1, i - 1 do
        table.insert(quests["Main"..i].RequiredQuests, "Main"..j)
    end
end


return quests