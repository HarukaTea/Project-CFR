
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local QuestBook = require(RepS.HarukaShared.Library.QuestBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local QuestBar = require(script.Components.QuestBar)
local QuestIndicator = require(script.Components.QuestIndicator)

local Children = Fusion.Children


local Pinia = require(script.Pinia)


return function(plr: Player)
	local self = {} :: Pinia.Self

	self.plr = plr
    self.char = plr.Character
    self.scope = Fusion.scoped()


	Pinia(self)


    if plr.PlayerGui:FindFirstChild("ExplorerQuests") then
        plr.PlayerGui.ExplorerQuests:Destroy()
    end


	local scope = self.scope :: Fusion.Scope

	local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ExplorerQuests",
		Parent = plr.PlayerGui,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown) and use(self.IsUIShown2)
        end),


        [Children] = {
            Fusion.New(scope, "Folder")({
                Name = "QuestMarkers",

                [Children] = {
                    Fusion.ForPairs(scope, self.Quests, function(use: Fusion.Use, scope: Fusion.Scope, index: number, questSymbol: BoolValue)
                        if questSymbol.Value then return nil end
                        if not QuestBook[questSymbol.Name] then return nil end

                        local questInfo = QuestBook[questSymbol.Name] :: QuestBook.QuestJSON
                        local questId = questSymbol.Name
                        local locator = QuestBook[questId].WorldLocatorId

                        if locator == "" then return nil end

                        local realLocator = workspace.Maps:FindFirstChild(locator, true)
                        if realLocator == nil then return nil end


                        local isCompleted = Fusion.Value(scope, false)
                        table.insert(scope, HarukaLib:Hydrate(questSymbol, {
                            ["Prop-Value"] = function(state: boolean)
                                state = state or false
                                isCompleted:set(state)
                            end
                        }))

                        return index, Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                            if use(isCompleted) then return nil end

                            return Components.BillboardGui(scope, {
                                Name = "Marker",
                                Size = UDim2.fromOffset(45, 45),
                                MaxDistance = 1599 * 40,
                                Adornee = realLocator,

                                [Children] = {
                                    QuestIndicator(scope, {
                                        QuestType = questInfo.QuestType,
                                        WorldPoint = realLocator.Position,
                                        CharPoint = self.CharPosition,
                                        COLORS = self.COLORS
                                    })
                                }
                            })
                        end)
                    end),
                    Fusion.ForPairs(scope, self.Quests, function(use: Fusion.Use, scope: Fusion.Scope, index: number, questSymbol: BoolValue)
                        if questSymbol.Value then return nil end
                        if not QuestBook[questSymbol.Name] then return nil end

                        local questInfo = QuestBook[questSymbol.Name] :: QuestBook.QuestJSON
                        local questId = questSymbol.Name

                        local npc = QuestBook[questId].NPC
                        if npc == "" then return nil end

                        local npcModel = workspace.MapComponents.NPCs:FindFirstChild(npc, true)
                        if not npcModel then return nil end


                        if npcModel:GetAttribute("_NoLocationMarker") then return nil end


                        local isCompleted = Fusion.Value(scope, false)
                        table.insert(scope, HarukaLib:Hydrate(questSymbol, {
                            ["Prop-Value"] = function(state: boolean)
                                state = state or false
                                isCompleted:set(state)
                            end
                        }))

                        return index, Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                            if use(isCompleted) then return nil end

                            return Components.BillboardGui(scope, {
                                Name = "NPCMarker_"..questId,
                                MaxDistance = 100,
                                Adornee = npcModel.PrimaryPart,
                                Size = UDim2.fromScale(3, 3),
                                StudsOffset = Vector3.yAxis * 5,

                                [Children] = {
                                    Components.TextLabel(scope, {
                                        Name = "Indicator",
                                        Text = "?",
                                        TextColor3 = self.COLORS[questInfo.QuestType],
                                        FontFace = Font.fromName("Arial", Enum.FontWeight.Bold),
                                        AutoLocalize = false,

                                        [Children] = {
                                            Components.ScaledTextUIStroke(scope, {}, true)
                                        }
                                    })
                                }
                            })
                        end)
                    end)
                }
            })
        }

	}, {
        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "Quests",
                    AnchorPoint = Vector2.zero,
                    Position = UDim2.fromScale(0.125, -0.8),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 0.95
                        }),

                        Components.UIListLayout(scope, {
                            Padding = UDim.new(0.1, 0),
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        }),

                        Fusion.ForPairs(scope, self.Quests, function(_, scope: Fusion.Scope, index: number, questSymbol: BoolValue)
                            if questSymbol.Value then return nil end
                            if not QuestBook[questSymbol.Name] then return nil end

                            local questInfo = QuestBook[questSymbol.Name] :: QuestBook.QuestJSON

                            local isCompleted = Fusion.Value(scope, false)
                            table.insert(scope, HarukaLib:Hydrate(questSymbol, {
                                ["Prop-Value"] = function(state: boolean)
                                    state = state or false
                                    isCompleted:set(state)
                                end
                            }))


                            return index, Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                                if use(isCompleted) then return nil end

                                return QuestBar(scope, {
                                    QuestType = questInfo.QuestType,
                                    QuestId = questInfo.Id,
                                    QuestVal = questSymbol,
                                    COLORS = self.COLORS
                                })
                            end)
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