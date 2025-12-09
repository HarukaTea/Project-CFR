
local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local QuestBindables = require(RepS.HarukaShared.Library.QuestBindables)
local HarukaTypeWriter = require(RepS.HarukaShared.Shared.HarukaTypeWriter)



export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,


    IsChatShown: Fusion.Value<boolean>,
    Choices: Fusion.Value<{ string }>,
    IsTypewriting: Fusion.Value<boolean>,

    NPCId: Fusion.Value<string>,

    Speaker: Fusion.Value<string>,
    Dialogue: Fusion.Value<string>,
    Quests: Fusion.Value<{ StringValue }>,

    MaxUTFShown: Fusion.Value<number>,

    GoToNextDialogueSignal: Signal.SignalClass,
    GoToNextDialogueByChoiceSignal: Signal.SignalClass,
    GoSkipDialogueSignal: Signal.SignalClass,
}


return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope


    self.IsChatShown = Value(false)
    self.Choices = Value({})
    self.IsTypewriting = Value(false)

    self.NPCId = Value("None")

    self.Speaker = Value("None")
    self.Dialogue = Value("None")


    local quests = FusionComponents.useChildren(scope, self.plr:WaitForChild("Quests", 999))
    self.Quests = quests :: Fusion.Value<{ StringValue }>

    self.MaxUTFShown = Value(-1)

    self.GoToNextDialogueSignal = Signal.new()
    self.GoToNextDialogueByChoiceSignal = Signal.new()
    self.GoSkipDialogueSignal = Signal.new()
    table.insert(scope, self.GoToNextDialogueSignal)
    table.insert(scope, self.GoToNextDialogueByChoiceSignal)
    table.insert(scope, self.GoSkipDialogueSignal)


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
    end)
    typewriterObj.OnTyperFinished:Connect(function()
        self.MaxUTFShown:set(-1)
        self.IsTypewriting:set(false)
    end)



    local npcChatting: Model? = nil
    local npcDialogues: {
        [string]: { string },

        Extra: {
            [string]: string
        }?
    } = {}
    local currentDialoguesChatting: { string } = {}
    local currentDialogueIndexChatting: number = 1
    local dialogueIndexChatting: number = 1
    local dialoguesChatting: { string } = {}
    local seriesId: string = "Else"



    --// track dialogue system
    local function __clearDialogues()
        currentDialoguesChatting = {}
        dialoguesChatting = {}
        dialogueIndexChatting = 1
        currentDialogueIndexChatting = 1
    end
    local function __endChatting()
        __clearDialogues()

        HarukaLib:FreezePlayerControls("Unfreeze")
        GuiService.SelectedObject = nil

        if npcChatting and typeof(npcChatting) == "Instance" and npcChatting:IsA("Model") then
            Events.FinishNPCChat_C.Fire({
                NPCId = npcChatting.Name,
                SeriesId = seriesId
            })

            local extra = npcDialogues.Extra
            local bindableId = extra[seriesId]
            if QuestBindables[bindableId] then
                QuestBindables[bindableId]:Fire()
            end
        end

        npcChatting = nil
        npcDialogues = {}
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
    local function __nextText(method: "Skip" | "Continue", forceDialogue: string?)
        if method == "Skip" then
            typewriterObj:Stop()

            self.MaxUTFShown:set(-1)
            return
        end

        currentDialogueIndexChatting += 1

        --- chat ended and no JUMPBACK
        if currentDialogueIndexChatting > #currentDialoguesChatting then
            __endChatting()
            return
        end


        local dialogue = forceDialogue or currentDialoguesChatting[currentDialogueIndexChatting] :: string

        --- patterns
        if string.find(dialogue, "ENTERCHOICE") and npcChatting.Dialogues:FindFirstChild("Choices") then
            local choiceIndex = string.match(dialogue, "%d+")
            if choiceIndex then
                choiceIndex = tonumber(choiceIndex)
            end
            if npcChatting.Dialogues.Choices:FindFirstChild("Choice"..choiceIndex) then
                local choiceDialogues = require(npcChatting.Dialogues.Choices["Choice"..choiceIndex]) :: { string }

                currentDialoguesChatting = choiceDialogues
                currentDialogueIndexChatting = 0
                dialogue = currentDialoguesChatting[1] :: string

                __nextText("Continue")
                return
            end
        end
        if string.find(dialogue, "JUMPBACKCONTINUE") then
            local originalIndex = dialogueIndexChatting
            local nextIndex = originalIndex + 2

            currentDialoguesChatting = dialoguesChatting
            currentDialogueIndexChatting = nextIndex
            dialogue = currentDialoguesChatting[currentDialogueIndexChatting] :: string

            if currentDialogueIndexChatting > #currentDialoguesChatting then
                __endChatting()
                return
            end
        end
        if string.find(dialogue, "JUMPBACKBRANCH") then
            local originalIndex = dialogueIndexChatting
            local nextIndex = originalIndex + 1

            currentDialoguesChatting = dialoguesChatting
            currentDialogueIndexChatting = nextIndex
            dialogue = currentDialoguesChatting[currentDialogueIndexChatting] :: string

            if currentDialogueIndexChatting > #currentDialoguesChatting then
                __endChatting()
                return
            end
        end
        if string.find(dialogue, "CHOICEBRANCH") then
            currentDialogueIndexChatting -= 1

            local _, branches = string.match(dialogue, "^(.-)%((.-)%)$")
            if branches then
                local branch1, branch2 = string.match(branches, "^(.-)-(.*)$")
                local choices = {}

                if branch1 == branch2 then
                    choices[branch1] = npcDialogues["CHOICE"..branch1]
                else
                    for i = branch1, branch2 do
                        choices[i] = npcDialogues["CHOICE"..i]
                    end
                end
                self.Choices:set(choices)
                return
            else
                __endChatting()
            end
        end

        -- world market patterns?
        if string.find(dialogue, "WORLDMARKET") then
            local _, marketId = string.match(dialogue, "^(.-)%((.-)%)$")

            local market = workspace.MapComponents.Markets:FindFirstChild(marketId, true)
            if market and market:IsA("Model") then
                local adornee = market:FindFirstChild("Prompt")
                if not adornee then Bindables.CreateNotify:Fire("[Error] Invalid Market Adornee") return end

                local prompt = adornee:FindFirstChild("Market") :: ProximityPrompt
                if not prompt then Bindables.CreateNotify:Fire("[Error] Invalid Market Prompt") return end

                Bindables.PromptTriggered:Fire(prompt)
                Events.PromptTriggered_C.Fire(prompt)
            else
                Bindables.CreateNotify:Fire("[Error] Invalid Market Id")
            end

            __endChatting()
            return
        end
        if string.find(dialogue, "WORLDCRAFTING") then
            local _, craftingStationId = string.match(dialogue, "^(.-)%((.-)%)$")

            local station = workspace.MapComponents.CraftingStations:FindFirstChild(craftingStationId, true)
            if station then
                local prompt = station:FindFirstChild("Crafting") :: ProximityPrompt
                if not prompt then Bindables.CreateNotify:Fire("[Error] Invalid Crafting Prompt") return end

                Bindables.PromptTriggered:Fire(prompt)
                Events.PromptTriggered_C.Fire(prompt)
            else
                Bindables.CreateNotify:Fire("[Error] Invalid Crafting Id")
            end

            __endChatting()
            return
        end


        --- is not in choice dialogues state?
        --- this ensures dialogueIndexChatting is always the main dialogues
        if currentDialoguesChatting[1] == dialoguesChatting[1] then
            dialogueIndexChatting = currentDialogueIndexChatting
        end



        __setText(dialogue)
    end
    self.GoToNextDialogueSignal:Connect(function()
        __nextText(if typewriterObj:IsTyping() then "Skip" else "Continue")
    end)
    self.GoToNextDialogueByChoiceSignal:Connect(function(choiceIndex: number)
        self.Choices:set({})

        __nextText("Continue", "ENTERCHOICE "..choiceIndex)
    end)
    self.GoSkipDialogueSignal:Connect(__endChatting)


    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not Fusion.peek(self.IsChatShown) then return end

        local isGamepad = string.find(input.UserInputType.Name, "Gamepad")
        if (isGamepad and input.KeyCode == Enum.KeyCode.ButtonY) then
            self.GoToNextDialogueSignal:Fire()
        end
    end))
    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not Fusion.peek(self.IsChatShown) then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.GoToNextDialogueSignal:Fire()
        end
    end))


    table.insert(scope, function()
        HarukaLib:FreezePlayerControls("Unfreeze")
    end)


    local function _startChatting(npc: Model)
        if npc == nil then return end
        if not npc:FindFirstChild("Dialogues") then return end

        if not npc.Dialogues:FindFirstChild("Main") then return end

        npcChatting = npc
        npcDialogues = require(npc.Dialogues.Main)

        self.NPCId:set(npc)

        local npcName = npcChatting.Name
        local afterNPCName = string.gsub(npcName, "%d+", "")

        self.Speaker:set(afterNPCName)
        self.plr:SetAttribute("CurrentUIGroup", "Chat")

        HarukaLib:FreezePlayerControls("Freeze")
        __clearDialogues()



        local quests = Fusion.peek(self.Quests)

        --- main quest is at the highest priority
        local function __priorityChoose(series: string)
            local found = false

            for _, questSymbol: StringValue in quests do
                if questSymbol:GetAttribute("IsCompleted") then continue end

                local questId = questSymbol.Name

                if string.find(questId, series) and npcDialogues[questId] then
                    dialoguesChatting = npcDialogues[questId]
                    currentDialoguesChatting = npcDialogues[questId]
                    seriesId = questId

                    __setText(currentDialoguesChatting[currentDialogueIndexChatting])
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

        currentDialoguesChatting = npcDialogues.Else
        dialoguesChatting = npcDialogues.Else

        __setText(currentDialoguesChatting[currentDialogueIndexChatting])
    end
    table.insert(scope, Events.EnterNPCChat_S.On(_startChatting))
end