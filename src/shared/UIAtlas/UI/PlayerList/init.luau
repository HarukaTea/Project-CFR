
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local PlayerBar = require(script.Components.PlayerBar)
local PlayerInfoView = require(script.Components.PlayerInfoView)
local PlayerInfoBar = require(script.Components.PlayerInfoBar)
local PartyMemberBar = require(script.Components.PartyMemberBar)

local Children = Fusion.Children

local wait = task.wait


local Pinia = require(script.Pinia)

return function(plr: Player)
	local self = {} :: Pinia.Self

	self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()


	Pinia(self)


    if plr.PlayerGui:FindFirstChild("PlayerList") then
        plr.PlayerGui.PlayerList:Destroy()
    end


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
                    Fusion.ForValues(scope, self.Characters, function(_, scope: Fusion.Scope, char: Model)
                        return PlayerInfoBar(scope, {
                            Char = char,
                            Player = Players:GetPlayerFromCharacter(char)
                        })
                    end)
                }
            }),
            Fusion.New(scope, "Folder")({
				Name = "PartyMemberMarkers",

				[Children] = {
					Fusion.ForValues(scope, self.PartyMembers, function(_, scope: Fusion.Scope, member: ObjectValue)
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

						return Components.BillboardGui(scope, {
							Name = "PartyMarker_"..member.Name,
							Size = UDim2.fromOffset(45, 45),

							Adornee = Fusion.Computed(scope, function(use: Fusion.Use)
								return use(adornee)
							end),

							[Children] = {
								Components.Frame(scope, {
									Name = "MarkerFrame",
									BackgroundColor3 = Color3.new(1, 1, 1),
									BackgroundTransparency = 0.1,
									Rotation = 45,
									Size = UDim2.fromScale(0.2, 0.2),
									ZIndex = 999,

									[Children] = {
                                        Components.UICorner(scope, {
                                            CornerRadius = UDim.new(0.2, 0)
                                        }),
										Components.ScaledUIStroke(scope, {
											Thickness = 0.15
										})
									}
								})
							}
						})
					end)
				}
			})
        }
	}, {
        TopProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "PlayerList",
                    AnchorPoint = Vector2.xAxis,
                    Position = UDim2.fromScale(1, 0),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 1.05
                        }),

                        Components.Frame(scope, {
                            Name = "PlayerListFrame",
                            AnchorPoint = Vector2.xAxis,
                            Position = UDim2.fromScale(1, 1.5),

                            [Children] = {
                                Components.PaddingFrame(scope, "ZZZ"),
                                Components.UIListLayout(scope, {
                                    FillDirection = Enum.FillDirection.Horizontal,
                                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                    Padding = UDim.new(0.01, 0),
                                    VerticalAlignment = Enum.VerticalAlignment.Top,
                                }),

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
                                }),

                                Components.TextButton(scope, {
                                    Name = "CloseButton",
                                    AnchorPoint = Vector2.xAxis,
                                    BackgroundTransparency = 0,
                                    BackgroundColor3 = Components.WHITE_COLOR,
                                    TextColor3 = Components.BLACK_COLOR,
                                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Heavy),
                                    LayoutOrder = -1,

                                    Size = UDim2.fromScale(0.03, 0.5),
                                    Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return if use(self.IsUIFolded) then "<" else ">"
                                    end),

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        self.IsUIFolded:set(not Fusion.peek(self.IsUIFolded))
                                        self.PlayerSelected:set(nil)
                                    end,

                                    [Children] = {
                                        Components.RoundUICorner(scope)
                                    }
                                })
                            }
                        })
                    }
                }),
            }
        },
        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "PartyFrame",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, -6),
                    Size = UDim2.fromScale(0.97, 1),

                    [Children] = {
                        Components.UIListLayout(scope,{
                            Padding = UDim.new(0.1, 0),
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        }),

                        Fusion.ForValues(scope, self.PartyMembers, function(_, scope: Fusion.Scope, member: ObjectValue)
                            local player = Players:FindFirstChild(member.Name) :: Player?
                            if not player then return nil end

                            return PartyMemberBar(scope, {
                                Member = member,
                            })
                        end)
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