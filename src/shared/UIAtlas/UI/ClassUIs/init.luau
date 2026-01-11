
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ChainBar = require(script.Components.ChainBar)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function(plr: Player)
	local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "ClassUIs")

	Pinia(self)

    local scope = self.scope :: Fusion.Scope

	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ClassUIs",
		Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown) and use(self.IsUIShown2)
        end),

	}, {
        BottomChildren = {
            Fusion.Hydrate(scope, Components:RefUI("ClassAbilityDiv_Bottom_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ReverberationStyle_CA1_1", true))({
                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(self.Class) == "Reverberation" and use(self.IsInCombat)
                        end),
                    }),

                    ChainBar(scope, {
                        ClassVal = self.ChainCombo,
                        Char = self.char
                    })
                }
            })
        }
    })
    self.UI = UI

    require(script.Anims)(UI, self)

	return function ()
        Fusion.doCleanup(scope)
    end
end