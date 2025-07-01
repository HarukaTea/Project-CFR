local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaQuest = {}
HarukaQuest.__index = HarukaQuest


local QuestBook = require(ReplicatedStorage.HarukaShared.Library.QuestBook)


--// Helper functions

local function _isValidQuestForPlayer(questId: string, plr: Player)
    if not QuestBook[questId] then return false end
    if not plr:FindFirstChild("Quests") then return false end
    if not plr.Quests:FindFirstChild(questId) then return false end

    return true
end



function HarukaQuest:CanGiveQuest(questId: string, plr: Player)
    if not QuestBook[questId] then return false end
    if not plr:FindFirstChild("Quests") then return false end


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


function HarukaQuest:GetQuestState(questId: string, plr: Player) : string
    if not _isValidQuestForPlayer(questId, plr) then return "Invalid" end

    return plr.Quests[questId].Value
end


function HarukaQuest:CompleteQuest(questId: string, plr: Player)
    if not _isValidQuestForPlayer(questId, plr) then return end

    local state = QuestBook[questId].DeliverType


    plr.Quests[questId].Value = if state == "Normal" then "Delivered" else "Completed"
end


function HarukaQuest:DeliverQuest(questId: string, plr: Player)
    if not _isValidQuestForPlayer(questId, plr) then return end

    plr.QuestBook[questId].Value = "Delivered"
end


function HarukaQuest:GetDeliveredQuests(plr: Player) : { string }
    if not plr:FindFirstChild("Quests") then return {} end

    local deliveredQuests = {}
    for _, quest: StringValue in plr.Quests:GetChildren() do
        if quest.Value == "Delivered" then
            table.insert(deliveredQuests, quest.Name)
        end
    end

    return deliveredQuests
end


function HarukaQuest:GetInProgressQuests(plr: Player) : { string }
    if not plr:FindFirstChild("Quests") then return {} end

    local inProgressQuests = {}
    for _, quest: StringValue in plr.Quests:GetChildren() do
        if quest.Value == "Started" then
            table.insert(inProgressQuests, quest.Name)
        end
    end

    return inProgressQuests
end


function HarukaQuest:GiveQuest(plr: Player, questId: string, progressVals: { number }?, progressState: string?)
    if not HarukaQuest:CanGiveQuest(questId, plr) then return end
    if plr.Quests:FindFirstChild(questId) then return end

    progressVals = progressVals or {}
    progressState = progressState or "Started"

    local val = Instance.new("StringValue")
    val.Name = questId
    val.Value = progressState


    for index: number, objectiveInfo: { any } in QuestBook[questId].Objectives do
        val:SetAttribute(objectiveInfo.ObjectiveId, progressVals[index] or objectiveInfo.Default)
    end

    val.Parent = plr.Quests
end


function HarukaQuest:AddObjective(plr: Player, questId: string, objectiveId: string, amount: number)
    if not _isValidQuestForPlayer(questId, plr) then return end

    local hasObjectiveCheck = false
    for _, objectiveInfo: { any } in QuestBook[questId].Objectives do
        if objectiveInfo.ObjectiveId == objectiveId then
            hasObjectiveCheck = true
            break
        end
    end
    if not hasObjectiveCheck then return end


    local val = plr.Quests[questId] :: StringValue
    local curObjective = val:GetAttribute(objectiveId) :: number

    curObjective = curObjective or 0
    curObjective += amount

    val:SetAttribute(objectiveId, curObjective)


    --// check if quest is completed
    local completed = true
    for _, objectiveInfo: { any } in QuestBook[questId].Objectives do
        if val:GetAttribute(objectiveInfo.ObjectiveId) < objectiveInfo.Target then
            completed = false
            break
        end
    end
    if not completed then return end


    HarukaQuest:CompleteQuest(questId, plr)
end


return HarukaQuest
