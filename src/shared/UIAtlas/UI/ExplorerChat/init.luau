--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local ChatView = require(script.Components.ChatView)

local Children = Fusion.Children


local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    Pinia(self)


    if plr.PlayerGui:FindFirstChild("ExplorerChat") then
        (plr.PlayerGui :: any).ExplorerChat:Destroy()
    end

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerChat",
        DisplayOrder = UIPriorityBook.Z3,
        ScreenInsets = Enum.ScreenInsets.None,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsChatShown)
        end),

    }, {
        BottomProps = {
            [Children] = {
                ChatView(scope, {
                    IsChatShown = self.IsChatShown,

                    ChoiceList = self.Choices,
                    Speaker = self.Speaker,
                    Dialogue = self.Dialogue,
                    IsTypewriting = self.IsTypewriting,
                    NPCId = self.NPCId,
                    MaxUTFShown = self.MaxUTFShown,

                    ProcessedToNextDialogueSignal = self.ProcessedToNextDialogueSignal,
                    ProcessedToNextDialogueByChoiceSignal = self.ProcessedToNextDialogueByChoiceSignal,
                })
            }
        }
    })
    self.UI = UI


    return function ()
        Fusion.doCleanup(scope)


    end
end