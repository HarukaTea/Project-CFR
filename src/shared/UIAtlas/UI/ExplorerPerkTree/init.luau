--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)

local BKCategoryBtn = require(RepS.HarukaShared.UIAtlas.UI.ExplorerBackpack.Components.BKCategoryBtn)

local PerkListView = require(script.Components.PerkListView)
local PerkDescView = require(script.Components.PerkDescView)

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local Children = Fusion.Children

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    require(script.Pinia)(self)


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
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.03, 0.52),
                Size = UDim2.fromScale(0.65, 0.66),

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 2.488),

                    Components.Frame(scope, {
                        Name = "PerkList",

                        [Children] = {
                            PerkListView(scope, {
                                CurrentCategory = self.CurrentCategory,
                                CurrentSelectedPerk = self.CurrentSelectedPerk,

                                PerkList = self.Points
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
                Components.Frame(scope, {
                    Name = "Categories",

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.015, 0),
                        }),

                        Fusion.ForPairs(scope, { "STR", "INT", "VIT" }, function(_, scope: Fusion.Scope, index: number, category: string)
                            return index, BKCategoryBtn(scope, {
                                Category = category,
                                Index = index,

                                CurrentSelectedItem = self.CurrentSelectedPerk,
                                CurrentSelectedItemUniqueId = Fusion.Value(scope, ""),
                                CurrentCategory = self.CurrentCategory,
                            })
                        end)
                    }
                }),


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
            ZIndex = 2,

            [Children] = {
                Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                    return PerkDescView(scope, {
                        PerkId = use(self.CurrentSelectedPerk),
                    })
                end),
            }
        }
    })
    self.UI = UI


    local syncUIPackage = plr.PlayerGui:WaitForChild("SyncUIs", 999)
    local perkPackage = syncUIPackage:WaitForChild("PerkListPath2Ds", 999)


    for _, container: Folder in perkPackage:GetChildren() do
        for _, path2d: Path2D in container:GetChildren() do
            local path = path2d:Clone()
            path.Visible = true
            path.Parent = UI.CenterLeft.PerkList[container.Name]
        end
    end

    return function ()
        Fusion.doCleanup(scope)


    end
end