
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")


local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local QuestLib = require(SSS.HarukaServer.Services.QuestLib)
local QuestBook = require(RepS.HarukaShared.Library.QuestBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)



export type GlobalQuestFuncLibClass = {
    Funcs: { () -> nil },
    IdCallbacks: { [string]: (player: Player) -> nil },

    Init: (self: GlobalQuestFuncLibClass) -> nil
}



local GlobalQuestFuncLib = {} :: GlobalQuestFuncLibClass
GlobalQuestFuncLib.Funcs = {}


GlobalQuestFuncLib.IdCallbacks = {}


function GlobalQuestFuncLib:Init()
    for _, func: () -> nil in GlobalQuestFuncLib.Funcs do
        func()
    end
end


--// Private Methods


table.insert(GlobalQuestFuncLib.Funcs, function()
    ServerBindables.QuestCompleted:Connect(function(plr: Player, questId: string)
        local questData = QuestBook[questId] :: QuestBook.QuestJSON
        if not questData then return end

        for attr, val in questData.Rewards do
            HarukaLib:AddAttr(plr, attr, val)

            local msg = `+{val} {attr}`
            ServerLib:ShowText(plr.Character, msg, Color3.fromRGB(255, 255, 0))
        end
        for itemId, count in questData.ItemRewards do
            ServerLib:GiveItemDrop(plr, itemId, count)
        end


        Events.CreateNotify_S.Fire(plr, "Quest completed, well done!")
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.QuestCompleted)
    end)


    ServerBindables.NPCChatFinished:Connect(function(id: string, plr: Player)
        if GlobalQuestFuncLib.IdCallbacks[id] then
            GlobalQuestFuncLib.IdCallbacks[id](plr)
        end
    end)
end)



GlobalQuestFuncLib.IdCallbacks.ChristmasTheSickMan = function(plr: Player)
    local quest = QuestLib:GetQuest(plr, "Christmas2")
    if quest.Symbol.Value then return end

    local goldenApple = plr.Items:FindFirstChild("GoldenApple") :: IntConstrainedValue
    if not goldenApple then
        Events.CreateNotify_S.Fire(plr, "You don't have enough Golden Apples!")
        return
    end
    if goldenApple.Value < 100 then
        Events.CreateNotify_S.Fire(plr, "You don't have enough Golden Apples!")
        return
    end

    goldenApple.Value -= 100
    if goldenApple.Value <= 0 then
        goldenApple:Destroy()
    end

    Events.CreateNotify_S.Fire(plr, "The sick man said Thanks!")
    QuestLib:CompleteQuest(plr, "Christmas2")
    QuestLib:GiveQuest(plr, "Christmas3")
end


GlobalQuestFuncLib.IdCallbacks.ChristmasInterShovel = function(plr: Player)
    local quest = QuestLib:GetQuest(plr, "Christmas3")
    if quest.Symbol.Value then return end

    local char = plr.Character
    if not char then return end
    if not char:GetAttribute("Christmas_FoundShovel") then
        Events.CreateNotify_S.Fire(plr, "You need to find the shovel first!")
        return
    end

    Events.CreateNotify_S.Fire(plr, "Inter said Thanks!")
    QuestLib:CompleteQuest(plr, "Christmas3")
    QuestLib:GiveQuest(plr, "Christmas4")
end


GlobalQuestFuncLib.IdCallbacks.ChristmasCompletedSnuwaz = function(plr: Player)
    ServerLib:GiveBadge(2684692957005255, plr)
end


GlobalQuestFuncLib.IdCallbacks.Tutorial1Completed = function(plr: Player)
    ServerLib:GiveItemDrop(plr, "TitleAdventurer", 1)
end


return GlobalQuestFuncLib