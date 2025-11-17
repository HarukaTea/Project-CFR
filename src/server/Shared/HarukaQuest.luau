
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

export type HarukaQuestData = {
    Data: QuestBook.QuestJSON,
    Container: Folder
}


export type HarukaQuestClass = {
    InitPlayer: (plr: Player) -> HarukaQuestClass,
    StopTrackingPlayer: (plr: Player) -> nil,


    _checkIsReqCompleted: (plr: Player, questData: QuestBook.QuestJSON) -> boolean,


    GiveQuest: (plr: Player, questId: string) -> nil,
    AddProgress: (plr: Player, questId: string, objectiveId: string, amount: number) -> nil,
    RemoveQuest: (plr: Player, questId: string) -> nil,
    CheckQuestCompletion: (plr: Player, questId: string) -> nil,
    CompleteQuest: (plr: Player, questId: string) -> nil,
    ExportDataTable: (plr: Player) -> SavedQuestData,
    LoadSavedTable: (plr: Player, savedData: SavedQuestData) -> nil,

    GetAllQuests: (plr: Player) -> { [string]: HarukaQuestData },
    GetDoingQuests: (plr: Player) -> { [string]: HarukaQuestData },
    GetCompletedQuests: (plr: Player) -> { [string]: HarukaQuestData },
    GetQuestData: (plr: Player, questId: string) -> QuestBook.QuestJSON?,


    ActiveQuests: {
        [Player]: {
            [string]: HarukaQuestData
        }
    }
}




local HarukaQuest = {} :: HarukaQuestClass

HarukaQuest.ActiveQuests = {}



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
HarukaQuest._checkIsReqCompleted = _checkIsReqCompleted



function HarukaQuest.InitPlayer(plr: Player)
    HarukaQuest.ActiveQuests[plr] = {}
end


function HarukaQuest.StopTrackingPlayer(plr: Player)
    HarukaQuest.ActiveQuests[plr] = nil
end



function HarukaQuest.GiveQuest(plr: Player, questId: string)
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


    HarukaQuest.ActiveQuests[plr][questId] = {
        Data = questData,
        Container = folder,
    }
end




function HarukaQuest.AddProgress(plr: Player, questId: string, objectiveId: string, amount: number)
    if not HarukaQuest.ActiveQuests[plr][questId] then return end

    local container = HarukaQuest.ActiveQuests[plr][questId].Container
    local objectiveVal = container:GetAttribute(objectiveId)
    if not objectiveVal then return end


    HarukaLib:AddAttr(container, objectiveId, amount)
    HarukaQuest.CheckQuestCompletion(plr, questId)
end





function HarukaQuest.CheckQuestCompletion(plr: Player, questId: string)
    if not HarukaQuest.ActiveQuests[plr][questId] then return end

    local questData = HarukaQuest.ActiveQuests[plr][questId].Data
    local container = HarukaQuest.ActiveQuests[plr][questId].Container

    for _, objective: QuestBook.QuestObjectiveJSON in questData.Objectives do
        if container:GetAttribute(objective.ObjectiveId) < objective.Target then
            return
        end
    end


    HarukaQuest.CompleteQuest(plr, questId)
end



function HarukaQuest.CompleteQuest(plr: Player, questId: string)
    if not HarukaQuest.ActiveQuests[plr][questId] then return end

    HarukaQuest.ActiveQuests[plr][questId].Container:SetAttribute("IsCompleted", true)


    ServerBindables.QuestCompleted:Fire(plr, questId)
end




function HarukaQuest.ExportDataTable(plr: Player) : SavedQuestData
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


function HarukaQuest.LoadSavedTable(plr: Player, savedData: SavedQuestData)
    for questId, state in savedData do
        if not QuestBook[questId] then continue end

        HarukaQuest.GiveQuest(plr, questId)
        local container = plr.Quests:FindFirstChild(questId)

        for objId, value in state.Objectives do
            container:SetAttribute(objId, value)
        end
        if state.Completed then
            container:SetAttribute("IsCompleted", true)
        end
    end
end


function HarukaQuest.GetAllQuests(plr: Player) : { [string]: HarukaQuestData }
    return HarukaQuest.ActiveQuests[plr]
end


function HarukaQuest.GetDoingQuests(plr: Player) : { [string]: HarukaQuestData }
    local result = {}

    for questId: string, questData: HarukaQuestData in HarukaQuest.ActiveQuests[plr] do
        if questData.Container:GetAttribute("IsCompleted") then continue end

        result[questId] = questData
    end

    return result
end


function HarukaQuest.GetCompletedQuests(plr: Player) : { [string]: HarukaQuestData }
    local result = {}

    for questId: string, questData: HarukaQuestData in HarukaQuest.ActiveQuests[plr] do
        if not questData.Container:GetAttribute("IsCompleted") then continue end

        result[questId] = questData
    end

    return result
end


function HarukaQuest.GetQuestData(plr: Player, questId: string) : QuestBook.QuestJSON?
    if not HarukaQuest.ActiveQuests[plr][questId] then return nil end

    return HarukaQuest.ActiveQuests[plr][questId].Data
end


return HarukaQuest
