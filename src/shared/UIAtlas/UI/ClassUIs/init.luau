
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)


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
            return use(self.IsUIShown)
        end)

	}, {
        CenterProps = {
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(self.IsUIShown2)
            end),

            [Children] = {
                Components.Frame(scope, {
                    Name = "ClassAbilityDiv_Center",
                    AnchorPoint = Vector2.zero,
                    Position = UDim2.fromScale(0, 1.5),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 0.95
                        }),


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



	return function ()
        Fusion.doCleanup(scope)
    end
end