--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local FakeTopBG = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local PerkListView = require(script.Components.PerkListView)

local Children = Fusion.Children

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    require(script.Pinia)(self)


    if plr.PlayerGui:FindFirstChild("ExplorerPerkTree") then
        plr.PlayerGui.ExplorerPerkTree:Destroy()
    end


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerPerkTree",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),


        [Children] = {
            Components.Frame(scope, {
                Name = "CenterLeft",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.52),
                Size = UDim2.fromScale(0.65, 0.66),

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 2.488),

                    Components.Frame(scope, {
                        Name = "PerkList",

                        [Children] = {
                            PerkListView(scope, {
                                CurrentSelectedPerk = self.CurrentSelectedPerk,
                                TalentPoints = self.TalentPoints,
                                Talents = self.Talents,
                            })
                        }
                    })
                }
            }),
        }

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
                FakeTopBG(scope),
            }
        },
    })
    self.UI = UI


    local syncUIPackage = plr.PlayerGui:WaitForChild("SyncUIs", 999)
    local perkPackage = syncUIPackage:WaitForChild("PerkListPath2Ds", 999)


    for _, path2d: Path2D in perkPackage:GetChildren() do
        local path = path2d:Clone()
        path.Visible = true
        path.Parent = UI.CenterLeft.PerkList
    end

    return function ()
        Fusion.doCleanup(scope)
    end
end