--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local QuestBook = require(RepS.HarukaShared.Library.QuestBook)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    QuestType: string,
    QuestId: string,

    QuestVal: StringValue
})

    local questId = props.QuestId

    if not QuestBook[questId] then
        warn("Quest not found: "..questId)
        return nil
    end

    local notHasObjective = HarukaLib.TableUtils().IsEmpty(QuestBook[questId].Objectives)
    local objectiveVals = {}
    if not notHasObjective then
        for index: number, objectiveInfo: table in QuestBook[questId].Objectives do
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

            Components.Frame(scope, {
                Name = "Symbol",
                BackgroundColor3 = AssetBook.QuestTypeColors[props.QuestType],
                BackgroundTransparency = 0,
                Size = UDim2.fromScale(0.5, 0.5),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                LayoutOrder = 1,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIStroke(scope, {
                        Thickness = 3,
                        Color = Components.BLACK_COLOR
                    })
                }
            }),

            Components.Frame(scope, {
                Name = "Info",
                LayoutOrder = 2,

                [Children] = {
                    Components.TextLabel(scope, {
                        Name = "Title",
                        Size = UDim2.fromScale(1, 0.5),
                        Text = QuestBook[questId].Name,
                        TextColor3 = AssetBook.QuestTypeColors[props.QuestType],
                        TextXAlignment = Enum.TextXAlignment.Left,

                        [Children] = {
                            Components.TextUIStroke(scope, { Thickness = 2 })
                        }
                    }),
                    Components.TextLabel(scope, {
                        Name = "Info",
                        Position = UDim2.fromScale(0, 0.5),
                        Size = UDim2.fromScale(1, 0.4),
                        RichText = true,
                        TextXAlignment = Enum.TextXAlignment.Left,

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local target = QuestBook[questId].Target

                            if notHasObjective then
                                return HarukaLib:RichTextify(target)
                            end

                            local pattern = "_OBJECTIVE(%d+)_"
                            local result = string.gsub(target, pattern, function(matched: string)
                                if not matched then return "nil" end

                                local id = tonumber(matched)
                                if not id then return "nil" end

                                local val = objectiveVals["Objective"..matched]
                                if not val then return "nil" end

                                val = use(val)

                                return tostring(val)
                            end)

                            return HarukaLib:RichTextify(result)
                        end),

                        [Children] = {
                            Components.TextUIStroke(scope, { Thickness = 2 })
                        }
                    })
                }
            })
        }
    })
end
