
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ReverberationFrame = require(script.Components.ReverberationFrame)
local FuriosoFrame = require(script.Components.FuriosoFrame)
local ChainBar = require(script.Components.ChainBar)

local Children = Fusion.Children

local Pinia = require(script.Pinia)


return function(plr: Player)
	local self = {} :: Pinia.Self

	self.plr = plr
	self.char = plr.Character
    self.scope = Fusion.scoped()


	Pinia(self)


    if plr.PlayerGui:FindFirstChild("ClassUIs") then
        plr.PlayerGui.ClassUIs:Destroy()
    end


    local scope = self.scope :: Fusion.Scope


	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ClassUIs",
		Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown) and use(self.IsUIShown2)
        end),

	}, {
        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "ClassAbilityDiv_Bottom",

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 1
                        }),

                        ReverberationFrame(scope, self),
                        FuriosoFrame(scope, self),

                        ChainBar(scope, {
                            ClassVal = self.ChainCombo,
                            Char = self.char
                        })
                    }
                })

            }
        }
    })
    self.UI = UI


    require(script.Anims)(UI, self)



	return function ()
        Fusion.doCleanup(scope)
    end
end