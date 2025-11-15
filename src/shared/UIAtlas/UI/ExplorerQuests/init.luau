
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local QuestBook = require(RepS.HarukaShared.Library.QuestBook)

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
            return use(self.IsUIShown)
        end),


        [Children] = {
            Fusion.New(scope, "Folder")({
                Name = "QuestMarkers",

                [Children] = {
                    Fusion.ForValues(scope, self.Quests, function(use: Fusion.Use, scope: Fusion.Scope, questSymbol: StringValue)
                        if not questSymbol.Value then return nil end
                        if questSymbol.Value == "Delivered" then return nil end
                        if not QuestBook[questSymbol.Name] then return nil end

                        local questInfo = QuestBook[questSymbol.Name]

                        local questId = questSymbol.Name
                        local locator = QuestBook[questId].WorldLocatorId

                        if locator == "" then return nil end

                        local realLocator = nil
                        for _, thatLocator: BasePart in use(self.StoryLocators) do
                            if thatLocator.Name == locator then
                                realLocator = thatLocator
                                break
                            end
                        end
                        if realLocator == nil then return nil end


                        return Components.BillboardGui(scope, {
                            Name = "Marker",
                            Size = UDim2.fromOffset(45, 45),
                            MaxDistance = 1599 * 40,
                            Adornee = realLocator,

                            [Children] = {
                                QuestIndicator(scope, {
                                    QuestType = questInfo.QuestType,
                                    WorldPoint = realLocator.Position,

                                    CharPoint = self.CharPosition
                                })
                            }
                        })
                    end),
                    Fusion.ForValues(scope, self.Quests, function(use: Fusion.Use, scope: Fusion.Scope, questSymbol: StringValue)
                        if not questSymbol.Value then return nil end
                        if questSymbol.Value == "Delivered" then return nil end
                        if not QuestBook[questSymbol.Name] then return nil end

                        local questInfo = QuestBook[questSymbol.Name]
                        local questId = questSymbol.Name

                        local npc = QuestBook[questId].NPC
                        if npc == "" then return nil end

                        local npcs = use(self.NPCs)
                        local npcModel: Model = nil

                        for _, npcObj: Model in npcs do
                            if npcObj.Name == npc then
                                npcModel = npcObj
                                break
                            end
                        end
                        if not npcModel then return nil end


                        if npcModel:GetAttribute("NoLocationMarker") then return nil end


                        return questId, Components.BillboardGui(scope, {
                            Name = "NPCMarker_"..questId,
                            MaxDistance = 100,
                            Adornee = npcModel.PrimaryPart,
                            Size = UDim2.fromScale(3, 3),
                            StudsOffset = Vector3.yAxis * 5,

                            [Children] = {
                                Components.TextLabel(scope, {
                                    Name = "Indicator",
                                    Text = "?",
                                    TextColor3 = AssetBook.QuestTypeColors[questInfo.QuestType],
                                    FontFace = Font.fromName("Arial", Enum.FontWeight.Bold),
                                    AutoLocalize = false,

                                    [Children] = {
                                        Components.ScaledTextUIStroke(scope, {}, true)
                                    }
                                })
                            }
                        })
                    end)
                }
            })
        }

	}, {
        CenterProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "Quests",
                    AnchorPoint = Vector2.zero,
                    Position = UDim2.fromScale(0.02, 0),

                    [Children] = {
                        Components.UIScale(scope, {
                            Scale = 0.95
                        }),

                        Components.UIListLayout(scope, {
                            Padding = UDim.new(0.3, 0),
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        }),

                        Fusion.ForValues(scope, self.Quests, function(_, scope: Fusion.Scope, questSymbol: StringValue)
                            if not questSymbol.Value then return nil end
                            if questSymbol.Value == "Delivered" then return nil end
                            if not QuestBook[questSymbol.Name] then return nil end


                            local questInfo = QuestBook[questSymbol.Name]


                            return QuestBar(scope, {
                                QuestType = questInfo.QuestType,
                                QuestId = questInfo.Id,

                                QuestVal = questSymbol
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