--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local DialogueBook = require(RepS.HarukaShared.Library.DialogueBook)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local QuestBindables = require(RepS.HarukaShared.Library.QuestBindables)
local HarukaTypeWriter = require(RepS.HarukaShared.Shared.HarukaTypeWriter)


return function (self: { any })
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope


    self.IsChatShown = Value(false)
    self.Choices = Value({})
    self.IsTypewriting = Value(false)

    self.NPCId = Value("None")

    self.Speaker = Value("None")
    self.Dialogue = Value("None")
    self.Quests = FusionComponents.useFolder(scope, self.plr.Quests)

    self.MaxUTFShown = Value(-1)

    self.ProcessedToNextDialogueSignal = Signal.new()
    table.insert(scope, self.ProcessedToNextDialogueSignal)


    --// track ui
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsChatShown:set(newPanel == "Chat")
        end
    }))



    --// track typewriter
    local typewriterObj = HarukaTypeWriter.new()

    table.insert(scope, typewriterObj)

    typewriterObj.OnUTFUpdated:Connect(function(index: number)
        self.MaxUTFShown:set(index)
        self.IsTypewriting:set(index > -1)

        SoundService.SFXs.ChatBubble:Play()
    end)
    typewriterObj.OnTyperFinished:Connect(function()
        self.MaxUTFShown:set(-1)
        self.IsTypewriting:set(false)
    end)



    local npcChatting: string = nil
    local dialogueIndexChatting: number = 1
    local dialogueChatting: string = ""
    local seriesId: string = "Else"



    --// track dialogue system
    local function __endChatting()
        dialogueChatting = ""
        dialogueIndexChatting = 1

        HarukaLib:FreezePlayerControls("Unfreeze")

        if npcChatting then
            Events.RequestToEndNPCChat.Fire({
                NPCId = npcChatting,
                SeriesId = seriesId
            })

            local bindableId = DialogueBook[npcChatting].Extra[seriesId]
            if QuestBindables[bindableId] then
                QuestBindables[bindableId]:Fire()
            end
        end

        npcChatting = nil
        seriesId = "Else"

        self.plr:SetAttribute("CurrentUIGroup", "None")
    end
    local function __setText(text: string)
        text = string.gsub(text, "<br%s*/>", "\n")
        text = string.gsub(text, "<[^<>]->", "")

        self.Dialogue:set(HarukaLib:RichTextify(text))
        self.MaxUTFShown:set(0)

        typewriterObj:TypeText(HarukaLib:RichTextify(text))
    end
    local function __nextText(method: "Skip" | "Continue")
        if method == "Skip" then
            typewriterObj:Stop()

            self.MaxUTFShown:set(-1)
            return
        end

        dialogueIndexChatting += 1

        --- chat ended
        if dialogueIndexChatting > #dialogueChatting then
            __endChatting()
            return
        end

        __setText(dialogueChatting[dialogueIndexChatting])
    end
    self.ProcessedToNextDialogueSignal:Connect(function()
        __nextText(if typewriterObj:IsTyping() then "Skip" else "Continue")
    end)

    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if Fusion.peek(self.IsChatShown) then
                self.ProcessedToNextDialogueSignal:Fire()
            end
        end
        if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
            if Fusion.peek(self.IsChatShown) then
                self.ProcessedToNextDialogueSignal:Fire()
            end
        end
    end))


    table.insert(scope, function()
        HarukaLib:FreezePlayerControls("Unfreeze")
    end)


    local function _startChatting(npc: string)
        npcChatting = npc

        self.NPCId:set(npc)
        self.Speaker:set(string.gsub(npcChatting, "%d+", ""))
        self.plr:SetAttribute("CurrentUIGroup", "Chat")

        HarukaLib:FreezePlayerControls("Freeze")


        local quests = Fusion.peek(self.Quests)

        --- main quest is at the highest priority
        dialogueIndexChatting = 1

        local function __priorityChoose(series: string)
            local found = false

            for _, questSymbol: StringValue in quests do
                if not questSymbol.Value then continue end
                if questSymbol.Value == "Completed" then continue end

                local questId = questSymbol.Name

                if string.find(questId, series) and DialogueBook[npcChatting][questId] then
                    dialogueChatting = DialogueBook[npcChatting][questId]
                    seriesId = questId

                    __setText(dialogueChatting[dialogueIndexChatting])
                    found = true
                    break
                end
            end

            return found
        end
        if __priorityChoose("Main") then return end
        if __priorityChoose("Side") then return end
        if __priorityChoose("Town") then return end

        --- all of above don't match
        seriesId = "Else"

        dialogueChatting = DialogueBook[npcChatting].Else

        __setText(dialogueChatting[dialogueIndexChatting])
    end
    table.insert(scope, Events.EnterNPCChat.On(function(data)
        _startChatting(data.NPCId)
    end))
end
