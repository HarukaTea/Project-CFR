
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local PromptBar = require(script.Components.PromptBar)

local Children = Fusion.Children

local Pinia = require(script.Pinia)

return function(plr: Player)
	local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "ExplorerPrompt")

	Pinia(self)

	local scope = self.scope :: Fusion.Scope

	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ExplorerPrompt",
        DisplayOrder = -1,
		Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)

	}, {
        CenterProps = {
            ZIndex = 2
        },
        CenterChildren = {
            Fusion.Hydrate(scope, Components:RefUI("Prompts_EPrompt1_1", false, true))({
                [Children] = {
                    Fusion.ForPairs(scope, self.PromptList, function(
                        _,
                        scope: Fusion.Scope,
                        index: number,
                        prompt: ObjectValue
                    )
                        return index, PromptBar(scope, {
                            PromptObject = prompt.Value,
                            CurrentPromptIndex = self.CurrentPromptIndex,
                            LayoutOrder = index
                        })
                    end)
                },
            })
        }
    })
    self.UI = UI

    return function ()
        Fusion.doCleanup(scope)
    end
end