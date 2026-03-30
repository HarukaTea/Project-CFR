
local BadgeService = game:GetService("BadgeService")
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local CloseTab = require(RepS.HarukaShared.UIAtlas.Components.CloseTab)
local FakeTopBGTex = require(RepS.HarukaShared.UIAtlas.Components.FakeTopBGTex)

local BadgeBar = require(script.Components.BadgeBar)
local BadgeRewardFrame = require(script.Components.BadgeRewardFrame)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "ExplorerAchievements")

    Pinia(self)

    local scope = self.scope :: Fusion.Scope

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerAchievements",
        DisplayOrder = UIPriorityBook.Z3,
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("FullCenter_EBadge1_1", false, true))({
                [Children] = {
                    Components.ScrollingFrame(scope, {
                        Name = "AchievementsList",
                        Position = UDim2.fromScale(0.35, 0),
                        Size = UDim2.fromScale(0.65, 1),
                        ScrollingDirection = Enum.ScrollingDirection.Y,

                        [Children] = {
                            Components.PaddingFrame(scope, "AAA"),
                            Components.PaddingFrame(scope, "ZZZ"),

                            Fusion.ForPairs(scope, AssetBook.BadgeIds, function(_, scope: Fusion.Scope, badge: string, badgeId: number)
                                local badgeInfo = Fusion.Value(scope, {})
                                table.insert(scope, task.spawn(function()
                                    local info
                                    pcall(function()
                                        info = BadgeService:GetBadgeInfoAsync(badgeId)
                                    end)
                                    info = info or {}
                                    badgeInfo:set(info)
                                end))

                                local isUnlocked = Fusion.Value(scope, false)
                                table.insert(scope, HarukaLib:Hydrate(plr, {
                                    ["Attr-BADGE_"..badgeId] = function(state: boolean)
                                        state = state or false
                                        isUnlocked:set(state)
                                    end
                                }))

                                return badge, BadgeBar(scope, {
                                    BadgeId = badge,
                                    BadgeInfo = badgeInfo,
                                    IsUnlocked = isUnlocked
                                })
                            end)
                        }

                    }, {
                        Padding = UDim.new(0, 12),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.Name,
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
                FakeTopBGTex(scope)
            }
        },

        CenterChildren = {
            BadgeRewardFrame(scope, {
                BadgeCompletedCount = self.BadgeCompletedCount,
                HasGottenReward = self.HasGottenReward
            })
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end