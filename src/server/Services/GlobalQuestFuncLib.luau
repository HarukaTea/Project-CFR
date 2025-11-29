
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")


local QuestBindables = require(RepS.HarukaShared.Library.QuestBindables)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local QuestLib = require(SSS.HarukaServer.Services.QuestLib)
local QuestBook = require(RepS.HarukaShared.Library.QuestBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)



export type GlobalQuestFuncLibClass = {
    Funcs: { () -> nil },

    Init: (self: GlobalQuestFuncLibClass) -> nil
}



local GlobalQuestFuncLib = {} :: GlobalQuestFuncLibClass
GlobalQuestFuncLib.Funcs = {}



function GlobalQuestFuncLib:Init()
    for _, func: () -> nil in GlobalQuestFuncLib.Funcs do
        task.spawn(func)
    end
end


--// Private Methods


table.insert(GlobalQuestFuncLib.Funcs, function()
    ServerBindables.QuestCompleted:Connect(function(plr: Player, questId: string)
        local questData = QuestBook[questId] :: QuestBook.QuestJSON
        if not questData then return end

        for attr, val in questData.Rewards do
            HarukaLib:AddAttr(plr, attr, val)
        end


        Events.CreateNotify_S.Fire(plr, "Quest completed! Well done!")
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.QuestCompleted)
    end)
end)



table.insert(GlobalQuestFuncLib.Funcs, function()
    QuestBindables.InterSkyTowerQuest:Connect(function(plr: Player)
        QuestLib.GiveQuest(plr, "InterSkyTower")
    end)
end)


return GlobalQuestFuncLib