--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
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
    self.Quests = FusionComponents.useFolder(scope, self.plr:WaitForChild("Quests", 999))

    self.MaxUTFShown = Value(-1)

    self.ProcessedToNextDialogueSignal = Signal.new()
    self.ProcessedToNextDialogueByChoiceSignal = Signal.new()
    table.insert(scope, self.ProcessedToNextDialogueSignal)
    table.insert(scope, self.ProcessedToNextDialogueByChoiceSignal)


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



    local npcChatting: Model = nil
    local npcDialogues: { [string]: { string } } = {}
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

        if npcChatting then
            Events.RequestToEndNPCChat.Fire({
                NPCId = npcChatting.Name,
                SeriesId = seriesId
            })

            local bindableId = npcDialogues.Extra[seriesId]
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
            local choiceIndex = string.match(dialogue, "%d+") :: number
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

                prompt:InputHoldBegin()
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

                prompt:InputHoldBegin()
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
    self.ProcessedToNextDialogueSignal:Connect(function()
        __nextText(if typewriterObj:IsTyping() then "Skip" else "Continue")
    end)
    self.ProcessedToNextDialogueByChoiceSignal:Connect(function(choiceIndex: number)
        self.Choices:set({})

        __nextText("Continue", "ENTERCHOICE "..choiceIndex)
    end)

    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not Fusion.peek(self.IsChatShown) then return end

        local isGamepad = string.find(input.UserInputType.Name, "Gamepad")
        if (isGamepad and input.KeyCode == Enum.KeyCode.ButtonY) then
            self.ProcessedToNextDialogueSignal:Fire()
        end
    end))
    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not Fusion.peek(self.IsChatShown) then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.ProcessedToNextDialogueSignal:Fire()
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
        self.Speaker:set(string.gsub(npcChatting.Name, "%d+", ""))
        self.plr:SetAttribute("CurrentUIGroup", "Chat")

        HarukaLib:FreezePlayerControls("Freeze")
        __clearDialogues()



        local quests = Fusion.peek(self.Quests)

        --- main quest is at the highest priority
        local function __priorityChoose(series: string)
            local found = false

            for _, questSymbol: StringValue in quests do
                if not questSymbol.Value then continue end
                if questSymbol.Value == "Completed" then continue end

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
    table.insert(scope, Events.EnterNPCChat.On(function(data)
        _startChatting(data.NPCModel)
    end))
end