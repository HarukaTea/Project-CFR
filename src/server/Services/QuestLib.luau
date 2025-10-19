--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestLib = {}
QuestLib.__index = QuestLib


local QuestBook = require(ReplicatedStorage.HarukaShared.Library.QuestBook)


--// Helper functions

local function _isValidQuestForPlayer(questId: string, plr: Player)
    local plr = plr

    if not QuestBook[questId] then return false end
    if not plr:FindFirstChild("Quests") then return false end
    if not plr.Quests:FindFirstChild(questId) then return false end

    return true
end



function QuestLib.CanGiveQuest(questId: string, plr: Player)
    if not QuestBook[questId] then return false end
    if not plr:FindFirstChild("Quests") then return false end


    local plr = plr


    local reqQuests = QuestBook[questId].RequiredQuests
    local check = true
    for _, reqQuest: string in reqQuests do
        if not plr.Quests:FindFirstChild(reqQuest) then
            check = false
            break
        end
        if plr.Quests[reqQuest].Value ~= "Delivered" then
            check = false
            break
        end
    end


    return check
end


function QuestLib.GetQuestState(questId: string, plr: Player) : string
    if not _isValidQuestForPlayer(questId, plr) then return "Invalid" end

    return (plr :: any).Quests[questId].Value
end


function QuestLib.CompleteQuest(questId: string, plr: Player)
    if not _isValidQuestForPlayer(questId, plr) then return end

    local state = QuestBook[questId].DeliverType
    local plr = plr

    plr.Quests[questId].Value = if state == "Normal" then "Delivered" else "Completed"
end


function QuestLib.DeliverQuest(questId: string, plr: Player)
    if not _isValidQuestForPlayer(questId, plr) then return end

    (plr :: any).QuestBook[questId].Value = "Delivered"
end


function QuestLib.GetDeliveredQuests(plr: Player) : { string }
    if not plr:FindFirstChild("Quests") then return {} end

    local deliveredQuests = {}
    for _, quest: StringValue in (plr :: any).Quests:GetChildren() do
        if quest.Value == "Delivered" then
            table.insert(deliveredQuests, quest.Name)
        end
    end

    return deliveredQuests
end


function QuestLib.GetInProgressQuests(plr: Player) : { string }
    if not plr:FindFirstChild("Quests") then return {} end

    local inProgressQuests = {}
    for _, quest: StringValue in (plr :: any).Quests:GetChildren() do
        if quest.Value == "Started" then
            table.insert(inProgressQuests, quest.Name)
        end
    end

    return inProgressQuests
end


function QuestLib.GiveQuest(plr: Player, questId: string, progressVals: { [string]: number }?, progressState: string?)
    local plr = plr

    if not QuestLib.CanGiveQuest(questId, plr) then return end
    if plr.Quests:FindFirstChild(questId) then return end

    local progressVals = progressVals or {}
    progressState = progressState or "Started"

    local val = Instance.new("StringValue")
    val.Name = questId
    val.Value = progressState


    for index: number, objectiveInfo: QuestBook.QuestObjectiveJSON in QuestBook[questId].Objectives do
        val:SetAttribute(objectiveInfo.ObjectiveId, progressVals[index] or objectiveInfo.Default)
    end

    val.Parent = plr.Quests
end


function QuestLib.AddObjective(plr: Player, questId: string, objectiveId: string, amount: number)
    if not _isValidQuestForPlayer(questId, plr) then return end

    local hasObjectiveCheck = false
    for _, objectiveInfo: QuestBook.QuestObjectiveJSON in QuestBook[questId].Objectives do
        if objectiveInfo.ObjectiveId == objectiveId then
            hasObjectiveCheck = true
            break
        end
    end
    if not hasObjectiveCheck then return end


    local val = (plr :: any).Quests[questId] :: StringValue
    local curObjective = val:GetAttribute(objectiveId) :: number

    curObjective = curObjective or 0
    curObjective += amount

    val:SetAttribute(objectiveId, curObjective)


    --// check if quest is completed
    local completed = true
    for _, objectiveInfo: QuestBook.QuestObjectiveJSON in QuestBook[questId].Objectives do
        if val:GetAttribute(objectiveInfo.ObjectiveId) < objectiveInfo.Target then
            completed = false
            break
        end
    end
    if not completed then return end


    QuestLib.CompleteQuest(questId, plr)
end


return QuestLib