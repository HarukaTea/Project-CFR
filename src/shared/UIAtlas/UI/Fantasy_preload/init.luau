--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)


local Titlescreen = require(script.Components.Titlescreen)
local InnerTitlescreen = require(script.Components.InnerTitlescreen)

local Children = Fusion.Children

local wait = task.wait

return function (plr: Player)
    if workspace:GetAttribute("NoRequiresTitlescreen") then return nil end



    repeat wait() until workspace:WaitForChild("MapComponents", 999)
    repeat wait() until workspace.MapComponents:WaitForChild("Titlescreen", 999)
    repeat wait() until workspace.MapComponents.Titlescreen:WaitForChild("TitleRoom", 999)
    repeat wait() until workspace.MapComponents.Titlescreen:WaitForChild("CharPreviewLocator", 999)


    repeat wait() until workspace:GetAttribute("Haruka_CompletedPreload")

    local self = {}

    self.plr = plr
    self.scope = Fusion.scoped()


    require(script.Pinia)(self)


    local scope = self.scope :: Fusion.Scope
    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "Titlescreen",
        Parent = plr.PlayerGui,

        [Children] = {
            Titlescreen(scope, {
                SlotUISignal = self.SlotUISignal,
                CutsceneUISignal = self.CutsceneUISignal,
            }),
            InnerTitlescreen(scope, {
                CharVals = self.CharVals,

                SlotUISignal = self.SlotUISignal,
                CutsceneUISignal = self.CutsceneUISignal,
            })
        }
    })
    self.UI = UI


    repeat wait() until workspace:GetAttribute("Haruka_GameEntered")


    Fusion.doCleanup(scope)
end