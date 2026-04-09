
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local QuestBook = require(RepS.HarukaShared.Library.QuestBook)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    QuestType: string,
    QuestId: string,
    QuestVal: Folder,

    COLORS: { [string]: Color3 }
})

    local questId = props.QuestId

    if not QuestBook[questId] then
        warn("Quest not found: "..questId)
        return nil
    end

    local notHasObjective = HarukaLib.TableUtils.IsEmpty(QuestBook[questId].Objectives)
    local objectiveVals = {}
    if not notHasObjective then
        for index: number, objectiveInfo: QuestBook.QuestObjectiveJSON in QuestBook[questId].Objectives do
            objectiveVals[index] = Fusion.Value(scope, objectiveInfo.Default)

            table.insert(scope, HarukaLib:Hydrate(props.QuestVal, {
                ["Attr-"..objectiveInfo.ObjectiveId] = function(val: number)
                    objectiveVals[index]:set(val)
                end
            }))
        end
    end

    return Components.Frame(scope, {
        Name = "QuestBar_"..questId,

        [Children] = {
            Components.UIListLayout(scope, {
                Padding = UDim.new(0.01, 0),
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            Components.IconImageLabel(scope, {
                Size = UDim2.fromScale(0.8, 0.8),
                Image = "rbxassetid://123153183547809",
                LayoutOrder = 1,

                [Children] = {
                    Components.Frame(scope, {
                        Name = "Symbol",
                        BackgroundColor3 = props.COLORS[props.QuestType],
                        BackgroundTransparency = 0,
                        AnchorPoint = Vector2.one,
                        Size = UDim2.fromScale(0.35, 0.35),
                        Position = UDim2.fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.ScaledUIStroke(scope, {
                                Thickness = 0.15,
                                Color = Components.BLACK_COLOR
                            })
                        }
                    }),
                }
            }),

            Components.Frame(scope, {
                Name = "Info",
                LayoutOrder = 2,

                [Children] = {
                    Components.TextLabel(scope, {
                        Name = "Title",
                        Position = UDim2.fromScale(0, 0),
                        Size = UDim2.fromScale(1, 0.5),
                        Text = QuestBook[questId].Name,
                        TextColor3 = props.COLORS[props.QuestType],
                        TextXAlignment = Enum.TextXAlignment.Left,

                        [Children] = {
                            Components.ScaledTextUIStroke(scope, {
                                Thickness = 0.1
                            })
                        }
                    }),
                    Components.TextLabel(scope, {
                        Name = "Info",
                        Position = UDim2.fromScale(0, 0.55),
                        Size = UDim2.fromScale(1, 0.4),
                        RichText = true,
                        TextXAlignment = Enum.TextXAlignment.Left,

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local target = QuestBook[questId].Target

                            if notHasObjective then
                                return HarukaLib:RichText(target)
                            end

                            local pattern = "_OBJECTIVE(%d+)_"
                            local result = string.gsub(target, pattern, function(matched: string)
                                if not matched then return "nil" end

                                local id = tonumber(matched)
                                if not id then return "nil" end

                                local val = objectiveVals[tonumber(matched)]
                                if not val then return "nil" end

                                val = use(val)

                                return tostring(val)
                            end)

                            return HarukaLib:RichText(result)
                        end),

                        [Children] = {
                            Components.ScaledTextUIStroke(scope, {
                                Thickness = 0.1
                            })
                        }
                    })
                }
            })
        }
    })
end