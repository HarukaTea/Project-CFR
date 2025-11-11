
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local BKCategoryBtn = require(RepS.HarukaShared.UIAtlas.UI.ExplorerBackpack.Components.BKCategoryBtn)

local DevProductSlot = require(script.Components.DevProductSlot)
local DonationRankSlot = require(script.Components.DonationRankSlot)


local Children = Fusion.Children


local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope<any>


    Pinia(self)


    if plr.PlayerGui:FindFirstChild("ExplorerDonation") then
        plr.PlayerGui.ExplorerDonation:Destroy()
    end


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerDonation",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),


        [Children] = {
            Components.Frame(scope, {
                Name = "FullCenter",
                Size = UDim2.fromScale(0.944, 0.7),
                Position = UDim2.fromScale(0.5, 0.53),

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 3.389),

                    Components.Frame(scope, {
                        Name = "ProductList",

                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(self.CurrentCategory) == "Donation"
                        end),

                        [Children] = {
                            --// FIXME: remember to use Fusion.Computed when using scrolling in the future
                            Components.UIGridLayout(scope, {
                                FillDirection = Enum.FillDirection.Horizontal,
                                CellPadding = UDim2.fromOffset(24, 24),
                                CellSize = UDim2.fromScale(0.15, 0.4)
                            }),


                            Fusion.ForPairs(scope, AssetBook.GamepassIds, function(_, scope: Fusion.Scope<any>, gamepass: string, gamepassId: number)
                                return gamepass, DevProductSlot(scope, {
                                    Type = "GamePass",
                                    AssetId = gamepassId
                                })
                            end),
                            Fusion.ForPairs(scope, AssetBook.DevProductIds, function(_, scope: Fusion.Scope<any>, devProduct: string, devProductId: number)
                                return devProduct, DevProductSlot(scope, {
                                    Type = "Product",
                                    AssetId = devProductId
                                })
                            end)
                        }
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
                CloseTab(scope, {
                    ViewShownValue = self.IsUIShown
                }),
                FakeTopBGTex(scope),


                Components.Frame(scope, {
                    Name = "Categories",

                    [Children] = {
                        Components.UIListLayout(scope, {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.015, 0),
                        }),

                        Fusion.ForPairs(scope, { "Donation", "DonationLeaderboard" }, function(_, scope: Fusion.Scope<any>, index: number, category: string)
                            return index, BKCategoryBtn(scope, {
                                Category = category,
                                Index = index,

                                CurrentSelectedItemUniqueId = Fusion.Value(scope, ""),
                                CurrentSelectedItem = Fusion.Value(scope, ""),
                                CurrentCategory = self.CurrentCategory,
                            })
                        end)
                    }
                }),
            }
        },

        CenterProps = {
            [Children] = {
                Components.ScrollingFrame(scope, {
                    Name = "DonationRankLeaderboard",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 1),
                    Size = UDim2.fromScale(0.6, 7.3),
                    ScrollBarThickness = 5,
                    ScrollingDirection = Enum.ScrollingDirection.Y,


                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(self.CurrentCategory) == "DonationLeaderboard"
                    end),

                    [Children] = {
                        Components.PaddingFrame(scope, "AAA"),

                        Fusion.ForPairs(scope, self.DonationRanks, function(_, scope: Fusion.Scope<any>, index: number, val: NumberValue)
                            return index, DonationRankSlot(scope, {
                                Index = val:GetAttribute("Order"),
                                Value = val.Value,
                                PlayerName = val:GetAttribute("PlayerName"),
                                AvatarId = val:GetAttribute("PlayerThumbnail"),
                            })
                        end)
                    }

                }, {
                    Padding = UDim.new(0, 0),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                })
            }
        }
    })
    self.UI = UI


    return function ()
        Fusion.doCleanup(scope)


    end
end