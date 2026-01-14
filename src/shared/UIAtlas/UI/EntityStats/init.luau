
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local EnemyHPBar = require(script.Components.EnemyHPBar)
local EnemyInfoBar = require(script.Components.EnemyInfoBar)
local BossHPBar = require(script.Components.BossHPBar)

local PlayerTargetingBar = require(script.Components.PlayerTargetingBar)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function (plr: Player)
    local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "EntityStats")

    Pinia(self)

    local scope = self.scope

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "EntityStats",
        Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown) and use(self.IsUIShown2)
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
                    Fusion.ForPairs(scope, self.EnemiesOverworld, function(
                        _,
                        scope: Fusion.Scope,
                        index: number,
                        enemy: Model
                    )
                        return index, EnemyInfoBar(scope, {
                            Enemy = enemy,
                        })
                    end)
                }
            })
        }
    }, {
        TopChildren = {
            Fusion.Hydrate(scope, Components:RefUI("BossHPBar_1", false, true))({
                [Children] = {
                    BossHPBar(scope, {
                        TargetingList = self.TargetingList
                    })
                }
            })
        },
        CenterChildren = {
            Fusion.Hydrate(scope, Components:RefUI("TargetingListDiv_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("TargetingList_Entity1_1", false, true))({
                        [Children] = {
                            Fusion.ForPairs(scope, self.TargetingList, function(
                                _,
                                scope: Fusion.Scope,
                                index: number,
                                targeting: ObjectValue
                            )
                                return index, PlayerTargetingBar(scope, {
                                    Targeting = targeting,
                                    TargetingEnemy = self.TargetingEnemy,
                                    TargetArrowPos = self.TargetArrowPos
                                }, self)
                            end)
                        }
                    })
                }
            })
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end