--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")


local QuestBindables = require(RepS.HarukaShared.Library.QuestBindables)
local QuestLib = require(SSS.HarukaServer.Services.QuestLib)


local GlobalQuestFuncLib = {}



function GlobalQuestFuncLib:Init()
    for funcId: string, func: (self) -> nil in GlobalQuestFuncLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            task.spawn(func, self)
        end
    end
end


--// Private Methods


function GlobalQuestFuncLib:_ListenQuestBindables()
    QuestBindables.InterSkyTowerQuest:Connect(function(plr: Player)
        if QuestLib.CanGiveQuest("SideTowerTheKey", plr) then
            QuestLib.GiveQuest(plr, "SideTowerTheKey")
        end
    end)
end


return GlobalQuestFuncLib