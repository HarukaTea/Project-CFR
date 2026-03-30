
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local HarukaListLayout = require(RepS.HarukaShared.Shared.HarukaListLayout)

local Children = Fusion.Children

local AfterPinia = require(script.AfterPinia)

return function (plr: Player)
    local self = {} :: AfterPinia.Self

    ClientLib:InitUIFramework(self, plr, "ExplorerHints", true)

    local scope = self.scope :: Fusion.Scope
    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerHints",
        DisplayOrder = UIPriorityBook.Highest + 1,
        ScreenInsets = Enum.ScreenInsets.None,
        Parent = plr.PlayerGui,

    }, {
        TopProps = {
            Position = UDim2.new(0.5, 0, 0, 56),

            [Children] = {
                Fusion.Hydrate(scope, Components:RefUI("Hints_1", false, true))({})
            }
        }
    })
    self.UI = UI

    AfterPinia(self)

    local harukaListObj = HarukaListLayout.new(UI.Top.Hints.UIListLayout)
    harukaListObj:Enable()

    table.insert(scope, harukaListObj)
end