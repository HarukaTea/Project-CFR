
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local Pinia = require(script.Pinia)

local Children = Fusion.Children

return function(plr: Player)
	local self = {} :: Pinia.Self

	self.plr = plr
	self.char = plr.Character
    self.scope = Fusion.scoped()

	Pinia(self)

    if plr.PlayerGui:FindFirstChild("ExplorerStatsGlobal") then
        plr.PlayerGui.ExplorerStatsGlobal:Destroy()
    end

	local scope = self.scope :: Fusion.Scope

	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ExplorerStatsGlobal",
		Parent = plr.PlayerGui,
        DisplayOrder = UIPriorityBook.Normal + 1,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown) and use(self.IsUIShown2)
        end)

	}, {
        BottomChildren = {
            Fusion.Hydrate(scope, Components:RefUI("CastTimeBars_CTB1_1", false, true))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.IsUIShown2)
                end),
            }),

            Fusion.Hydrate(scope, Components:RefUI("BadgeAwarding_BA1_1", false, true))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.IsUIShown2)
                end),
            }),

            Fusion.Hydrate(scope, Components:RefUI("ItemDrops_IDrops1_1", false, true))({
                Name = "ItemDropsDiv",

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.IsUIShown2)
                end),

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ItemAcquiredFrame_IDrops1_2", false, true))({})
                }
            })
        },

        TopChildren = {
            Fusion.Hydrate(scope, Components:RefUI("LevelEXPDiv_LEDiv1_1", false, true))({
                Name = "LevelEXP",

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(self.IsUIShown2)
                end),
            })
        }
    })
    self.UI = UI

	require(script.Anims)(UI, self)

	return function ()
        Fusion.doCleanup(scope)
    end
end