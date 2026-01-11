
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local DevProductSlot = require(script.Components.DevProductSlot)
local DonationRankSlot = require(RepS.HarukaShared.UIAtlas.Components.LBRankSlot)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope

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
                        Name = "Products",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0.45, 0),
                        Size = UDim2.fromScale(0.6, 1),

                        [Children] = {
                            Components.Frame(scope, {
                                Name = "Donations",

                                [Children] = {
                                    Components.UIGridLayout(scope, {
                                        FillDirection = Enum.FillDirection.Horizontal,
                                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                                        CellPadding = UDim2.fromScale(0.03, 0.05),
                                        CellSize = UDim2.fromScale(0.25, 0.4)
                                    }),

                                    Fusion.ForPairs(scope, AssetBook.GamepassIds, function(_, scope: Fusion.Scope, gamepass: string, gamepassId: number)
                                        return gamepass, DevProductSlot(scope, {
                                            Type = "Gamepass",
                                            AssetId = gamepassId
                                        })
                                    end),
                                    Fusion.ForPairs(scope, AssetBook.DevProductIds, function(_, scope: Fusion.Scope, devProduct: string, devProductId: number)
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
            }
        },

        CenterProps = {
            [Children] = {
                Components.ScrollingFrame(scope, {
                    Name = "DonationRankLeaderboard",
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.fromScale(0.02, 1),
                    Size = UDim2.fromScale(0.4, 7.3),
                    ScrollBarThickness = 5,
                    ScrollingDirection = Enum.ScrollingDirection.Y,

                    [Children] = {
                        Components.PaddingFrame(scope, "AAA"),

                        Fusion.ForPairs(scope, self.DonationRanks, function(_, scope: Fusion.Scope, index: number, val: IntValue)
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
        },

        BottomProps = {
            [Children] = {
                Components.TextLabel(scope, {
                    Name = "SupportTip",
                    AnchorPoint = Vector2.new(0.5, 1),
                    Position = UDim2.fromScale(0.5, 0.7),
                    Size = UDim2.fromScale(0.95, 0.5),
                    Text = "Every support is greatly appreciated!",
                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            }
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end