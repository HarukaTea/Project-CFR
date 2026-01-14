
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local DevProductSlot = require(script.Components.DevProductSlot)
local LBRankSlot = require(RepS.HarukaShared.UIAtlas.Components.LBRankSlot)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "ExplorerDonation")

    Pinia(self)

    local scope = self.scope :: Fusion.Scope

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerDonation",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("FullCenter_EDonate1_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Products_EDonate1_1", false, true))({
                        [Children] = {
                            Fusion.ForPairs(scope, AssetBook.GamepassIds, function(
                                _,
                                scope: Fusion.Scope,
                                gamepass: string,
                                gamepassId: number
                            )
                                return gamepass, DevProductSlot(scope, {
                                    Type = "Gamepass",
                                    AssetId = gamepassId
                                })
                            end),

                            Fusion.ForPairs(scope, AssetBook.DevProductIds, function(
                                _,
                                scope: Fusion.Scope,
                                devProduct: string,
                                devProductId: number
                            )
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
            }
        },

        CenterChildren = {
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
                        return index, LBRankSlot(scope, {
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
        },

        BottomChildren = {
            Fusion.Hydrate(scope, Components:RefUI("SupportTip_EDonate1_1"))({})
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end