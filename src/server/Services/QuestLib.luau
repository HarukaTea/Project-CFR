
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
    Symbol: BoolValue
}


export type QuestLibClass = {
    InitPlayer: (self: QuestLibClass, plr: Player) -> QuestLibClass,
    StopTrackingPlayer: (self: QuestLibClass, plr: Player) -> nil,


    _checkIsReqCompleted: (plr: Player, questData: QuestBook.QuestJSON) -> boolean,


    GiveQuest: (self: QuestLibClass, plr: Player, questId: string) -> nil,
    AddProgress: (self: QuestLibClass, plr: Player, questId: string, objectiveId: string, amount: number) -> nil,
    SetProgress: (self: QuestLibClass, plr: Player, questId: string, objectiveId: string, amount: number) -> nil,
    RemoveQuest: (self: QuestLibClass, plr: Player, questId: string) -> nil,
    CheckQuestCompletion: (self: QuestLibClass, plr: Player, questId: string) -> nil,
    CompleteQuest: (self: QuestLibClass, plr: Player, questId: string) -> nil,
    ExportDataTable: (self: QuestLibClass, plr: Player) -> SavedQuestData,
    LoadSavedTable: (self: QuestLibClass, plr: Player, savedData: SavedQuestData) -> nil,

    GetAllQuests: (self: QuestLibClass, plr: Player) -> { [string]: QuestLibData },
    GetDoingQuests: (self: QuestLibClass, plr: Player) -> { [string]: QuestLibData },
    GetCompletedQuests: (self: QuestLibClass, plr: Player) -> { [string]: QuestLibData },
    GetQuestData: (self: QuestLibClass, plr: Player, questId: string) -> QuestBook.QuestJSON?,
    GetQuest: (self: QuestLibClass, plr: Player, questId: string) -> QuestLibData?,


    ActiveQuests: {
        [Player]: {
            [string]: QuestLibData
        }
    }
}




local QuestLib = {} :: QuestLibClass

QuestLib.ActiveQuests = {}



--// helper functions

function QuestLib:InitPlayer(plr: Player)
    QuestLib.ActiveQuests[plr] = {}
end


function QuestLib:StopTrackingPlayer(plr: Player)
    QuestLib.ActiveQuests[plr] = nil
end



function QuestLib:GiveQuest(plr: Player, questId: string)
    local questData = QuestBook[questId] :: QuestBook.QuestJSON
    if not questData then return  warn("Quest not found:", questId) end

    if plr.Quests:FindFirstChild(questId) then return end

    local boolVal = Instance.new("BoolValue")
    boolVal.Name = questId
    boolVal.Value = false
    boolVal.Parent = plr.Quests

    for _, obj: QuestBook.QuestObjectiveJSON in questData.Objectives do
        boolVal:SetAttribute(obj.ObjectiveId, obj.Default)
    end

    QuestLib.ActiveQuests[plr][questId] = {
        Data = questData,
        Symbol = boolVal,
    }
end




function QuestLib:AddProgress(plr: Player, questId: string, objectiveId: string, amount: number)
    if not QuestLib.ActiveQuests[plr][questId] then return end

    local symbol = QuestLib.ActiveQuests[plr][questId].Symbol
    local objectiveVal = symbol:GetAttribute(objectiveId)
    if not objectiveVal then return end


    HarukaLib:AddAttr(symbol, objectiveId, amount)
    QuestLib:CheckQuestCompletion(plr, questId)
end
function QuestLib:SetProgress(plr: Player, questId: string, objectiveId: string, amount: number)
    if not QuestLib.ActiveQuests[plr][questId] then return end

    local symbol = QuestLib.ActiveQuests[plr][questId].Symbol
    local objectiveVal = symbol:GetAttribute(objectiveId)
    if not objectiveVal then return end

    symbol:SetAttribute(objectiveId, amount)
    QuestLib:CheckQuestCompletion(plr, questId)
end




function QuestLib:CheckQuestCompletion(plr: Player, questId: string)
    if not QuestLib.ActiveQuests[plr][questId] then return end

    local questData = QuestLib.ActiveQuests[plr][questId].Data
    local symbol = QuestLib.ActiveQuests[plr][questId].Symbol

    for _, objective: QuestBook.QuestObjectiveJSON in questData.Objectives do
        if symbol:GetAttribute(objective.ObjectiveId) < objective.Target then
            return
        end
    end


    QuestLib:CompleteQuest(plr, questId)
end



function QuestLib:CompleteQuest(plr: Player, questId: string)
    if not QuestLib.ActiveQuests[plr][questId] then return end
    if QuestLib.ActiveQuests[plr][questId].Symbol.Value then return end

    QuestLib.ActiveQuests[plr][questId].Symbol.Value = true

    ServerBindables.QuestCompleted:Fire(plr, questId)
end




function QuestLib:ExportDataTable(plr: Player) : SavedQuestData
    local result = {}

    for _, questSymbol: BoolValue in plr.Quests:GetChildren() do
        local questId = questSymbol.Name
        local questData = {
            Completed = questSymbol.Value or false,
            Objectives = {}
        }
        local questBookData = QuestBook[questId] :: QuestBook.QuestJSON

        for _, objective: QuestBook.QuestObjectiveJSON in questBookData.Objectives do
            questData.Objectives[objective.ObjectiveId] = questSymbol:GetAttribute(objective.ObjectiveId) or 0
        end


        result[questId] = questData
    end

    return result
end


function QuestLib:LoadSavedTable(plr: Player, savedData: SavedQuestData)
    for questId, state in savedData do
        if not QuestBook[questId] then continue end

        QuestLib:GiveQuest(plr, questId)
        local symbol = plr.Quests:FindFirstChild(questId) :: BoolValue

        for objId, value in state.Objectives do
            symbol:SetAttribute(objId, value)
        end
        if state.Completed then
            symbol.Value = true
        end
    end
end


function QuestLib:GetAllQuests(plr: Player) : { [string]: QuestLibData }
    return QuestLib.ActiveQuests[plr]
end

function QuestLib:GetQuest(plr: Player, questId: string) : QuestLibData?
    return QuestLib.ActiveQuests[plr][questId]
end


function QuestLib:GetDoingQuests(plr: Player) : { [string]: QuestLibData }
    local result = {}

    for questId: string, questData: QuestLibData in QuestLib.ActiveQuests[plr] do
        if questData.Symbol.Value then continue end

        result[questId] = questData
    end

    return result
end


function QuestLib:GetCompletedQuests(plr: Player) : { [string]: QuestLibData }
    local result = {}

    for questId: string, questData: QuestLibData in QuestLib.ActiveQuests[plr] do
        if not questData.Symbol.Value then continue end

        result[questId] = questData
    end

    return result
end


function QuestLib:GetQuestData(plr: Player, questId: string) : QuestBook.QuestJSON?
    if not QuestLib.ActiveQuests[plr][questId] then return nil end

    return QuestLib.ActiveQuests[plr][questId].Data
end


return QuestLib
