
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local ChatView = require(script.Components.ChatView)

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "ExplorerChat")

    Pinia(self)

    local scope = self.scope :: Fusion.Scope

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerChat",
        DisplayOrder = UIPriorityBook.Z3,
        ScreenInsets = Enum.ScreenInsets.None,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsChatShown)
        end),

    }, {
        BottomChildren = {
            ChatView(scope, {
                IsChatShown = self.IsChatShown,

                ChoiceList = self.Choices,
                Speaker = self.Speaker,
                Dialogue = self.Dialogue,
                IsTypewriting = self.IsTypewriting,
                NPCId = self.NPCId,
                MaxUTFShown = self.MaxUTFShown,

                GoToNextDialogueSignal = self.GoToNextDialogueSignal,
                GoToNextDialogueByChoiceSignal = self.GoToNextDialogueByChoiceSignal,
                GoSkipDialogueSignal = self.GoSkipDialogueSignal,
            })
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end