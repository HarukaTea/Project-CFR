--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local EnemyHPBar = require(script.Components.EnemyHPBar)
local EnemyInfoBar = require(script.Components.EnemyInfoBar)
local BossHPBar = require(script.Components.BossHPBar)

local TargetingBar = require(script.Components.TargetingBar)

local Children = Fusion.Children

return function (plr: Player)
    local self = {}

    self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()


    local scope = self.scope :: Fusion.Scope


    require(script.Pinia)(self)


    if plr.PlayerGui:FindFirstChild("EntityStats") then
        plr.PlayerGui.EntityStats:Destroy()
    end


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "EntityStats",
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown2)
        end),

        [Children] = {
            Fusion.New(scope, "Folder")({
                Name = "EnemyEntity_HPBars",

                [Children] = {
                    Fusion.ForPairs(scope, self.Enemies, function(_, scope: Fusion.Scope, index: number, enemy: Model)
                        return index, EnemyHPBar(scope, {
                            Enemy = enemy,
                        })
                    end)
                }
            }),
            Fusion.New(scope, "Folder")({
                Name = "EnemyEntity_InfoBars",

                [Children] = {
                    Fusion.ForPairs(scope, self.EnemiesOverworld, function(_, scope: Fusion.Scope, index: number, enemy: Model)
                        return index, EnemyInfoBar(scope, {
                            Enemy = enemy,
                        })
                    end)
                }
            })
        }
    }, {
        TopProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "BossHPBar",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, 0.2),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        }),

                        Components.UIScale(scope, {
                            Scale = 0.85
                        }),

                        BossHPBar(scope, {
                            TargetingList = self.TargetingList
                        })
                    }
                })
            }
        },
        CenterProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "TargetingListDiv",
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.fromScale(1, 0),

                    [Children] = {
                        Components.UIScale(scope),

                        Components.Frame(scope, {
                            Name = "TargetingList",
                            AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.fromScale(0.99, -0.4),
                            Size = UDim2.fromScale(0.6, 1),

                            [Children] = {
                                Components.UIListLayout(scope, {
                                    Padding = UDim.new(0.25, 0),
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    VerticalAlignment = Enum.VerticalAlignment.Center
                                }),

                                Fusion.ForValues(scope, self.TargetingList, function(_, scope: Fusion.Scope, targeting: ObjectValue)
                                    return TargetingBar(scope, {
                                        Targeting = targeting,
                                        TargetingEnemy = self.TargetingEnemy,
                                        TargetArrowPos = self.TargetArrowPos
                                    })
                                end),
                            }
                        }),
                    }
                })
            }
        }
    })


    return function ()
        Fusion.doCleanup(scope)


    end
end