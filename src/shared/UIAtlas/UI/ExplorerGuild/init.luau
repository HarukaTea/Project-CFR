--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)


local Children = Fusion.Children

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    require(script.Pinia)(self)


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerGuild",
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
                --// TODO: guild UI
                Components.TextLabel(scope, {
                    Name = "WIPTitle",
                    Text = "COMING SOON IN PT3!",
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                    Size = UDim2.fromScale(1, 0.6),
                    TextTransparency = 0.7
                })
            }
        }
    })
    self.UI = UI


    return function ()
        Fusion.doCleanup(scope)


    end
end