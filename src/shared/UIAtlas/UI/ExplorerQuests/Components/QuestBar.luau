
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

    return Fusion.Hydrate(scope, Components:RefUI("QuestBar_EQuests1_1", false, true))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Icon_EQuests2_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Symbol_EQuests2_1", true))({
                        BackgroundColor3 = props.COLORS[props.QuestType]
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Info_EQuests2_1"))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Info_EQuests3_2", true))({
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
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("Title_EQuests3_2", true))({
                        Text = QuestBook[questId].Name,
                        TextColor3 = props.COLORS[props.QuestType]
                    })
                }
            })
        }
    })
end