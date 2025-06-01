--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")


local QuestBindables = require(RepS.HarukaShared.Library.QuestBindables)
local HarukaQuest = require(SSS.HarukaServer.Shared.HarukaQuest)



local GlobalQuestFuncLib = {}



function GlobalQuestFuncLib:Init()
    for funcId: string, func: (self) -> nil in GlobalQuestFuncLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            func(self)
        end
    end
end


--// Private Methods


function GlobalQuestFuncLib:_ListenQuestBindables()
    QuestBindables.InterSkyTowerQuest:Connect(function(plr: Player)
        if HarukaQuest:CanGiveQuest("SideTowerTheKey", plr) then
            HarukaQuest:GiveQuest(plr, "SideTowerTheKey")
        end
    end)
end


return GlobalQuestFuncLib