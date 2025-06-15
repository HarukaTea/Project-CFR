--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)

local BKCategoryBtn = require(RepS.HarukaShared.UIAtlas.UI.ExplorerBackpack.Components.BKCategoryBtn)

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
                Name = "FullBottom",
                AnchorPoint = Vector2.zero,
                Position = UDim2.fromScale(0.008, 0.192),
                Size = UDim2.fromScale(0.97, 0.76),

                [Children] = {
                    Components.ScrollingFrame(scope, {
                        Name = "PerkList",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        ScrollBarThickness = 5,

                        [Children] = {
                            Fusion.ForPairs(scope, self.Perks, function(_, scope: Fusion.Scope, index: number, perkInfo: table)

                                local absTextSize = Fusion.Value(scope, Vector2.zero)

                                return index, Components.Frame(scope, {
                                    Name = perkInfo.Id,
                                    BackgroundColor3 = Color3.fromRGB(),
                                    BackgroundTransparency = if index % 2 == 0 then 0.2 else 0.8,
                                    Size = UDim2.fromScale(0.95, 0.2),

                                    [Children] = {
                                        Components.UIAspectRatioConstraint(scope, 15.261),
                                        Components.IconImageLabel(scope, {
                                            AnchorPoint = Vector2.new(0, 0.5),
                                            Position = UDim2.fromScale(0.015, 0.5),
                                            Size = UDim2.fromScale(0.8, 0.8),
                                            Image = perkInfo.Icon,
                                        }),

                                        Components.TextLabel(scope, {
                                            Name = "PerkStat",
                                            AnchorPoint = Vector2.new(0, 0.5),
                                            Position = UDim2.fromScale(0.081, 0.5),
                                            Size = UDim2.fromScale(0.761, 0.9),
                                            Text = HarukaLib:RichTextify(
                                                `<yellow>{perkInfo.Name}</font>:   {perkInfo.Desc}`
                                            ),
                                            TextScaled = false,
                                            TextWrapped = true,
                                            TextXAlignment = Enum.TextXAlignment.Left,
                                            TextYAlignment = Enum.TextYAlignment.Top,
                                            RichText = true,

                                            TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                return use(absTextSize).Y / (63 / 20)
                                            end),

                                            [Fusion.Out("AbsoluteSize")] = absTextSize,
                                        }),

                                        Components.TextLabel(scope, {
                                            Name = "UnlockState",
                                            AnchorPoint = Vector2.new(0, 0.5),
                                            Position = UDim2.fromScale(0.855, 0.5),
                                            Size = UDim2.fromScale(0.136, 0.34),

                                            TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                if use(self.Points[perkInfo.Type]) >= perkInfo.Req then
                                                    return Color3.fromRGB(85, 255, 127)
                                                else
                                                    return Color3.fromRGB(255, 0, 0)
                                                end
                                            end),
                                            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                if use(self.Points[perkInfo.Type]) >= perkInfo.Req then
                                                    return "UNLOCKED"
                                                else
                                                    return "Req ".. perkInfo.Req .."+ "..perkInfo.Type
                                                end
                                            end)
                                        })
                                    }
                                })
                            end)
                        }
                    }, {
                        Padding = UDim.new(0, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    })
                }
            })
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

                        Fusion.ForPairs(scope, { "STR", "INT", "VIT", "DEX" }, function(_, scope: Fusion.Scope, index: number, category: string)
                            return index, BKCategoryBtn(scope, {
                                Category = category,
                                Index = index,

                                CurrentSelectedItem = Fusion.Value(scope, ""),
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
            [Children] = {

            }
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)


    end
end