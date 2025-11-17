
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)


local ChainBar = require(script.Components.ChainBar)
local FlowBar = require(script.Components.FlowBar)
local ReverberationBar = require(script.Components.ReverberationBar)
local ReverberationFrame = require(script.Components.ReverberationFrame)

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

        [Children] = {
            Fusion.New(scope, "Folder")({
                Name = "ClassMarkers_Support",

                [Children] = {
                    Fusion.ForPairs(scope, self.TargetingList, function(use: Fusion.Use, scope: Fusion.Scope, index: number, symbol: ObjectValue)
                        if not ClientLib.IsCharValid(symbol.Value) then
                            return index, nil
                        end
                        local class = use(self.Class)


                        if class == "Flow" then
                            return index, FlowBar(scope, {
                                Enemy = symbol.Value
                            })
                        elseif class == "Reverberation" then
                            return index, ReverberationBar(scope, {
                                Enemy = symbol.Value
                            })
                        else
                            return index, nil
                        end
                    end)
                }
            }),
        }

	}, {
        CenterProps = {
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
        },

        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "ClassAbilityDiv_Bottom",

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 1
                        }),

                        ReverberationFrame(scope, self)
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