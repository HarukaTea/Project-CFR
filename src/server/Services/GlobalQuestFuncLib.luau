--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")


local QuestBindables = require(RepS.HarukaShared.Library.QuestBindables)
local QuestLib = require(SSS.HarukaServer.Services.QuestLib)



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
    QuestBindables.InterSkyTowerQuest:Connect(function(plr: Player)
        if QuestLib.CanGiveQuest("SideTowerTheKey", plr) then
            QuestLib.GiveQuest(plr, "SideTowerTheKey")
        end
    end)
end)


return GlobalQuestFuncLib