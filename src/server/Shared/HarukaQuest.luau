
--// Inspired by RoQuests
--// @Author: HarukaTea


local Players = game:GetService("Players")
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


export type HarukaQuestClass = {
    __index: HarukaQuestClass,

    new: (plr: Player) -> HarukaQuestClass,
    _checkIsReqCompleted: (plr: Player, questData: QuestBook.QuestJSON) -> boolean,

    GetObjByPlayer: (plr: Player) -> HarukaQuestClass,


    GiveQuest: (self: HarukaQuestClass, questId: string) -> nil,
    AddProgress: (self: HarukaQuestClass, questId: string, objectiveId: string, amount: number) -> nil,
    RemoveQuest: (self: HarukaQuestClass, questId: string) -> nil,
    CheckQuestCompletion: (self: HarukaQuestClass, questId: string) -> nil,
    CompleteQuest: (self: HarukaQuestClass, questId: string) -> nil,
    ExportDataTable: (self: HarukaQuestClass) -> SavedQuestData,
    LoadSavedTable: (self: HarukaQuestClass, savedData: SavedQuestData) -> nil,

    Destroy: (self: HarukaQuestClass) -> nil,


    Player: Player,
    ActiveQuests: {
        [string]: {
            Data: QuestBook.QuestJSON,
            Container: Folder
        }
    }
}




local HarukaQuest = {} :: HarukaQuestClass
HarukaQuest.__index = HarukaQuest



local allQuestsObjPool = {}



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



function HarukaQuest.GetObjByPlayer(plr: Player) : HarukaQuestClass
    return allQuestsObjPool[plr]
end




function HarukaQuest.new(plr: Player)
    local self = setmetatable({}, HarukaQuest)


    self.Player = plr
    self.ActiveQuests = {}


    allQuestsObjPool[plr] = self

    return self
end


function HarukaQuest:Destroy()
    allQuestsObjPool[self.Player] = nil
end



function HarukaQuest:GiveQuest(questId: string)
    local questData = QuestBook[questId] :: QuestBook.QuestJSON
    if not questData then return  warn("Quest not found:", questId) end

    local plr = self.Player


    if not _checkIsReqCompleted(plr, questData) then return end
    if plr.Quests:FindFirstChild(questId) then return end



    local folder = Instance.new("Folder")
    folder.Name = questId
    folder:SetAttribute("IsCompleted", false)

    folder.Parent = plr.Quests


    for _, obj: QuestBook.QuestObjectiveJSON in questData.Objectives do
        folder:SetAttribute(obj.ObjectiveId, obj.Default)
    end


    self.ActiveQuests[questId] = {
        Data = questData,
        Container = folder,
    }
end




function HarukaQuest:AddProgress(questId: string, objectiveId: string, amount: number)
    local plr = self.Player
    if not self.ActiveQuests[questId] then return end

    local container = self.ActiveQuests[questId].Container
    local objectiveVal = container:GetAttribute(objectiveId)
    if not objectiveVal then return end


    HarukaLib:AddAttr(container, objectiveId, amount)


    self:CheckQuestCompletion(questId)
end





function HarukaQuest:CheckQuestCompletion(questId: string)
    if not self.ActiveQuests[questId] then return end

    local questData = self.ActiveQuests[questId].Data
    local container = self.ActiveQuests[questId].Container

    for _, objective: QuestBook.QuestObjectiveJSON in questData.Objectives do
        if container:GetAttribute(objective.ObjectiveId) < objective.Target then
            return
        end
    end


    self:CompleteQuest(questId)
end



function HarukaQuest:CompleteQuest(questId: string)
    if not self.ActiveQuests[questId] then return end

    self.ActiveQuests[questId].Container:SetAttribute("IsCompleted", true)


    ServerBindables.QuestCompleted:Fire(self.Player, questId)
end




function HarukaQuest:ExportDataTable()
    local result = {}

    for _, questFolder: Folder in self.Player.Quests:GetChildren() do
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


function HarukaQuest:LoadSavedTable(savedData: SavedQuestData)
    local plr = self.Player


    for questId, state in savedData do
        if not QuestBook[questId] then continue end

        self:GiveQuest(questId)
        local container = plr.Quests:FindFirstChild(questId)

        for objId, value in state.Objectives do
            container:SetAttribute(objId, value)
        end
        if state.Completed then
            container:SetAttribute("IsCompleted", true)
        end
    end
end



return HarukaQuest
