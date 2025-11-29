
--// Inspired by RoQuests
--// @Author: HarukaTea

local RepS = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local QuestBook = require(RepS.HarukaShared.Library.QuestBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)



export type SavedQuestData = {
    [string]: {
        Completed: boolean,
        Objectives: {
            [string]: number
        }
    }
}

export type QuestLibData = {
    Data: QuestBook.QuestJSON,
    Container: Folder
}


export type QuestLibClass = {
    InitPlayer: (plr: Player) -> QuestLibClass,
    StopTrackingPlayer: (plr: Player) -> nil,


    _checkIsReqCompleted: (plr: Player, questData: QuestBook.QuestJSON) -> boolean,


    GiveQuest: (plr: Player, questId: string) -> nil,
    AddProgress: (plr: Player, questId: string, objectiveId: string, amount: number) -> nil,
    RemoveQuest: (plr: Player, questId: string) -> nil,
    CheckQuestCompletion: (plr: Player, questId: string) -> nil,
    CompleteQuest: (plr: Player, questId: string) -> nil,
    ExportDataTable: (plr: Player) -> SavedQuestData,
    LoadSavedTable: (plr: Player, savedData: SavedQuestData) -> nil,

    GetAllQuests: (plr: Player) -> { [string]: QuestLibData },
    GetDoingQuests: (plr: Player) -> { [string]: QuestLibData },
    GetCompletedQuests: (plr: Player) -> { [string]: QuestLibData },
    GetQuestData: (plr: Player, questId: string) -> QuestBook.QuestJSON?,


    ActiveQuests: {
        [Player]: {
            [string]: QuestLibData
        }
    }
}




local QuestLib = {} :: QuestLibClass

QuestLib.ActiveQuests = {}



--// helper functions

local function _checkIsReqCompleted(plr: Player, questData: QuestBook.QuestJSON) : boolean
    for _, reqId in questData.RequiredQuests do
        local quest = plr.Quests:FindFirstChild(reqId)
        if not quest or not quest:GetAttribute("IsCompleted") then
            return false
        end
    end

    return true
end
QuestLib._checkIsReqCompleted = _checkIsReqCompleted



function QuestLib.InitPlayer(plr: Player)
    QuestLib.ActiveQuests[plr] = {}
end


function QuestLib.StopTrackingPlayer(plr: Player)
    QuestLib.ActiveQuests[plr] = nil
end



function QuestLib.GiveQuest(plr: Player, questId: string)
    local questData = QuestBook[questId] :: QuestBook.QuestJSON
    if not questData then return  warn("Quest not found:", questId) end

    if not _checkIsReqCompleted(plr, questData) then return end
    if plr.Quests:FindFirstChild(questId) then return end



    local folder = Instance.new("Folder")
    folder.Name = questId
    folder:SetAttribute("IsCompleted", false)

    folder.Parent = plr.Quests


    for _, obj: QuestBook.QuestObjectiveJSON in questData.Objectives do
        folder:SetAttribute(obj.ObjectiveId, obj.Default)
    end


    QuestLib.ActiveQuests[plr][questId] = {
        Data = questData,
        Container = folder,
    }
end




function QuestLib.AddProgress(plr: Player, questId: string, objectiveId: string, amount: number)
    if not QuestLib.ActiveQuests[plr][questId] then return end

    local container = QuestLib.ActiveQuests[plr][questId].Container
    local objectiveVal = container:GetAttribute(objectiveId)
    if not objectiveVal then return end


    HarukaLib:AddAttr(container, objectiveId, amount)
    QuestLib.CheckQuestCompletion(plr, questId)
end





function QuestLib.CheckQuestCompletion(plr: Player, questId: string)
    if not QuestLib.ActiveQuests[plr][questId] then return end

    local questData = QuestLib.ActiveQuests[plr][questId].Data
    local container = QuestLib.ActiveQuests[plr][questId].Container

    for _, objective: QuestBook.QuestObjectiveJSON in questData.Objectives do
        if container:GetAttribute(objective.ObjectiveId) < objective.Target then
            return
        end
    end


    QuestLib.CompleteQuest(plr, questId)
end



function QuestLib.CompleteQuest(plr: Player, questId: string)
    if not QuestLib.ActiveQuests[plr][questId] then return end

    QuestLib.ActiveQuests[plr][questId].Container:SetAttribute("IsCompleted", true)


    ServerBindables.QuestCompleted:Fire(plr, questId)
end




function QuestLib.ExportDataTable(plr: Player) : SavedQuestData
    local result = {}

    for _, questFolder: Folder in plr.Quests:GetChildren() do
        local questId = questFolder.Name
        local questData = {
            Completed = questFolder:GetAttribute("IsCompleted") or false,
            Objectives = {}
        }
        local questBookData = QuestBook[questId] :: QuestBook.QuestJSON

        for _, objective: QuestBook.QuestObjectiveJSON in questBookData.Objectives do
            questData.Objectives[objective.ObjectiveId] = questFolder:GetAttribute(objective.ObjectiveId) or 0
        end


        result[questId] = questData
    end

    return result
end


function QuestLib.LoadSavedTable(plr: Player, savedData: SavedQuestData)
    for questId, state in savedData do
        if not QuestBook[questId] then continue end

        QuestLib.GiveQuest(plr, questId)
        local container = plr.Quests:FindFirstChild(questId)

        for objId, value in state.Objectives do
            container:SetAttribute(objId, value)
        end
        if state.Completed then
            container:SetAttribute("IsCompleted", true)
        end
    end
end


function QuestLib.GetAllQuests(plr: Player) : { [string]: QuestLibData }
    return QuestLib.ActiveQuests[plr]
end


function QuestLib.GetDoingQuests(plr: Player) : { [string]: QuestLibData }
    local result = {}

    for questId: string, questData: QuestLibData in QuestLib.ActiveQuests[plr] do
        if questData.Container:GetAttribute("IsCompleted") then continue end

        result[questId] = questData
    end

    return result
end


function QuestLib.GetCompletedQuests(plr: Player) : { [string]: QuestLibData }
    local result = {}

    for questId: string, questData: QuestLibData in QuestLib.ActiveQuests[plr] do
        if not questData.Container:GetAttribute("IsCompleted") then continue end

        result[questId] = questData
    end

    return result
end


function QuestLib.GetQuestData(plr: Player, questId: string) : QuestBook.QuestJSON?
    if not QuestLib.ActiveQuests[plr][questId] then return nil end

    return QuestLib.ActiveQuests[plr][questId].Data
end


return QuestLib
