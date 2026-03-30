
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)

local PlayerBar = require(script.Components.PlayerBar)
local PlayerInfoView = require(script.Components.PlayerInfoView)
local PlayerInfoBar = require(script.Components.PlayerInfoBar)

local Children = Fusion.Children

local wait = task.wait

local Pinia = require(script.Pinia)

return function(plr: Player)
	local self = {} :: Pinia.Self

    ClientLib:InitUIFramework(self, plr, "PlayerList")

	Pinia(self)

	local scope = self.scope :: Fusion.Scope

	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "PlayerList",
		Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end),

        [Children] = {
            Fusion.New(scope, "Folder")({
                Name = "PlayerInfoBar",

                [Children] = {
                    Fusion.ForPairs(scope, self.Characters, function(_, scope: Fusion.Scope, index: number, char: Model)
                        return index, PlayerInfoBar(scope, {
                            Char = char,
                            Player = Players:GetPlayerFromCharacter(char)
                        })
                    end)
                }
            }),
            Fusion.New(scope, "Folder")({
				Name = "PartyMemberMarkers",

				[Children] = {
					Fusion.ForPairs(scope, self.PartyMembers, function(_, scope: Fusion.Scope, index: number, member: Player)
						local player = Players:FindFirstChild(member.Name) :: Player?

						if not player then return nil end
						if member.Name == self.plr.Name then return nil end

						local character = player.Character
						if not character then return nil end
						if not character.PrimaryPart then return nil end

						local adornee = Fusion.Value(scope, character.PrimaryPart)
						table.insert(scope, player.CharacterAdded:Connect(function(newChar)
							repeat wait() until newChar.PrimaryPart

							adornee:set(newChar.PrimaryPart)
						end))

						return index, { Fusion.Hydrate(scope, Components:RefUI("PartyMember/Indicator_PL1_1", true))({
                            Adornee = Fusion.Computed(scope, function(use: Fusion.Use)
								return use(adornee)
							end)

                        }), Fusion.Hydrate(scope, Components:RefUI("PartyHighlight_PL1_1", true))({
                            Adornee = Fusion.Computed(scope, function(use: Fusion.Use)
								return use(adornee)
							end)
                        })
                    }
					end)
				}
			})
        }
	}, {
        TopChildren = {
            Fusion.Hydrate(scope, Components:RefUI("PlayerListFrame_PL1_1", false, true))({
                [Children] = {
                    Components.PaddingFrame(scope, "ZZZ"),

                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        local state = use(self.IsUIFolded)
                        if state then return nil end

                        return Components.ScrollingFrame(scope, {
                            Name = "PlayerList",
                            ScrollingDirection = Enum.ScrollingDirection.Y,
                            Size = UDim2.fromScale(0.18, 4),
                            ScrollBarThickness = 0,
                            LayoutOrder = 2,

                            [Children] = {
                                Fusion.ForPairs(scope, self.Players, function(_, scope: Fusion.Scope, index: number, player: Player)
                                    return index, PlayerBar(scope, {
                                        Player = player,

                                        PlayerSelecting = self.PlayerSelecting,
                                        PlayerSelected = self.PlayerSelected,

                                        PartyMembers = self.PartyMembers,
                                    })
                                end)
                            }
                        }, {
                            Padding = UDim.new(0, 6),
                            HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        })
                    end),

                    PlayerInfoView(scope, {
                        PlayerSelecting = self.PlayerSelected,
                        PartyMembers = self.PartyMembers
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("CloseButton_PL1_1", true))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return if use(self.IsUIFolded) then "<" else ">"
                        end),

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            self.IsUIFolded:set(not Fusion.peek(self.IsUIFolded))
                            self.PlayerSelected:set(nil)
                            self.PlayerSelecting:set(nil)
                        end
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