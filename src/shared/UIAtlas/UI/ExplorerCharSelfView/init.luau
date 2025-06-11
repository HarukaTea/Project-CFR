--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)

local PerkPointsView = require(script.Components.PerkPointsView)
local CharStatPanel = require(script.Components.CharStatsView)


local Children = Fusion.Children

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    require(script.Pinia)(self)


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

                Components.Frame(scope, {
                    Name = "FakeTopBG",
                    BackgroundTransparency = 0.1,
                    Size = UDim2.fromScale(2, 1.8),
                    ZIndex = 0,
                })
            }
        },

        CenterProps = {
            [Children] = {
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
        }
    })
    self.UI = UI


    require(script.Anims)(UI, self)


    return function ()
        Fusion.doCleanup(scope)


    end
end