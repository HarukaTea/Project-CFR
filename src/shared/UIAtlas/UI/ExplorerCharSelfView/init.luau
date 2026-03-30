
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)

local PerkPointsView = require(script.Components.PerkPointsView)
local CharStatPanel = require(script.Components.CharStatsView)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "ExplorerCharSelfView")

    local scope = self.scope :: Fusion.Scope

    Pinia(self)

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerCharSelfView",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)

    }, {
        FullProps = {
            BackgroundTransparency = 0.3,
            ZIndex = 0,
        },

        TopProps = {
            Position = UDim2.fromScale(0.5, 0.02),

            [Children] = {
                CloseTab(scope, {
                    ViewShownValue = self.IsUIShown
                }),
                FakeTopBGTex(scope),
            }
        },

        CenterChildren = {
            PerkPointsView(scope, {
                Class = self.Class,
                Level = self.Level,
                EXP = self.EXP,

                PointList = self.Points,
                PerkPoints = self.PerkPoints,
            }),

            CharStatPanel(scope, {
                StatList = self.Stats,
                BaseStatList = self.BaseStats
            })
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end