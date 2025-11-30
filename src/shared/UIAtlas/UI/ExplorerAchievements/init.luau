
local BadgeService = game:GetService("BadgeService")
local RepS = game:GetService("ReplicatedStorage")

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

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()

    local scope = self.scope :: Fusion.Scope


    Pinia(self)


    if plr.PlayerGui:FindFirstChild("ExplorerAchievements") then
        plr.PlayerGui.ExplorerAchievements:Destroy()
    end


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "ExplorerAchievements",
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

                    Components.ScrollingFrame(scope, {
                        Name = "AchievementsList",
                        Position = UDim2.fromScale(0.25, 0),
                        Size = UDim2.fromScale(0.75, 1),
                        ScrollingDirection = Enum.ScrollingDirection.Y,


                        [Children] = {
                            Components.PaddingFrame(scope, "AAA"),
                            Components.PaddingFrame(scope, "ZZZ"),


                            Fusion.ForPairs(scope, AssetBook.BadgeIds, function(_, scope: Fusion.Scope, badge: string, badgeId: number)

                                local badgeInfo = Fusion.Value(scope, {})
                                local hasOwned = Fusion.Value(scope, false)
                                table.insert(scope, task.spawn(function()
                                    local info
                                    pcall(function()
                                        info = BadgeService:GetBadgeInfoAsync(badgeId)
                                    end)
                                    badgeInfo:set(info)
                                end))
                                table.insert(scope, task.spawn(function()
                                    local state
                                    pcall(function()
                                        state = BadgeService:UserHasBadgeAsync(plr.UserId, badgeId)
                                    end)
                                    hasOwned:set(state)
                                end))


                                local isUnlocked = Fusion.Value(scope, false)
                                table.insert(scope, HarukaLib:Hydrate(plr, {
                                    ["Attr-BADGE_"..badgeId] = function(state: boolean)
                                        state = state or false

                                        isUnlocked:set(state)
                                    end
                                }))


                                local layoutOrder = 1
                                local firstChar = string.sub(badge, 1, 1)
                                local charCode = string.byte(firstChar)

                                if string.match(firstChar, "%a") then
                                    local baseCode
                                    if charCode >= 65 and charCode <= 90 then
                                        baseCode = 65
                                    elseif charCode >= 97 and charCode <= 122 then
                                        baseCode = 97
                                    else
                                        return 0
                                    end
                                    layoutOrder = charCode - baseCode + 1
                                else
                                    layoutOrder = 0
                                end


                                return badge, BadgeBar(scope, {
                                    BadgeId = badge,
                                    BadgeInfo = badgeInfo,
                                    HasOwned = hasOwned,
                                    IsUnlocked = isUnlocked,
                                    LayoutOrder = layoutOrder
                                })
                            end)
                        }

                    }, {
                        Padding = UDim.new(0, 12),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        SortOrder = Enum.SortOrder.LayoutOrder,
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

        CenterProps = {
            [Children] = {
                BadgeRewardFrame(scope, {
                    BadgeCompletedCount = self.BadgeCompletedCount,
                    HasGottenReward = self.HasGottenReward
                })
            }
        }
    })
    self.UI = UI


    return function ()
        Fusion.doCleanup(scope)
    end
end