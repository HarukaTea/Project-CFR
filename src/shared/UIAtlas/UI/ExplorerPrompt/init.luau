--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local PromptBar = require(script.Components.PromptBar)

local Children = Fusion.Children

local udNew = UDim.new
local fromScale = UDim2.fromScale

return function(plr: Player)
	local self = {}

	self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()


	require(script.Pinia)(self)


	local scope = self.scope :: Fusion.Scope

	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ExplorerPrompt",
        DisplayOrder = UIPriorityBook.Normal,
		Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)

	}, {
        CenterProps = {
            ZIndex = 2,

            [Children] = {
                Components.Frame(scope, {
                    Name = "Prompts",
                    Position = fromScale(0.65, 0.5),
                    Size = fromScale(1, 0.7),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            Padding = udNew(0.3, 0),
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center
                        }),

                        Fusion.ForPairs(scope, self.PromptList, function(_, scope: Fusion.Scope, index: number, prompt: ObjectValue)
                            return index, PromptBar(scope, {
                                PromptObject = prompt.Value,
                                CurrentPromptIndex = self.CurrentPromptIndex,
                                LayoutOrder = index
                            })
                        end)
                    },
                }),
            }
        }
    })
    self.UI = UI


    require(script.Anims)(UI, self)



    return function ()
        Fusion.doCleanup(scope)


    end
end
