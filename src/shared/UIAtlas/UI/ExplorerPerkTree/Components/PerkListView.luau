
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local PerkNode = require(script.Parent.PerkNode)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    CurrentCategory: Fusion.Value,
    CurrentSelectedPerk: Fusion.Value,

    PerkList: { [string]: Fusion.Value }
})
    local STR_Nodes = {
        UDim2.fromScale(0.182, 0.185),
        UDim2.fromScale(0.143, 0.459),
        UDim2.fromScale(0.191, 0.828),
        UDim2.fromScale(0.81, 0.162),
        UDim2.fromScale(0.855, 0.469),
        UDim2.fromScale(0.811, 0.808)
    }
    local INT_NODES = {
        UDim2.fromScale(0.506, 0.113),
        UDim2.fromScale(0.281, 0.492),
        UDim2.fromScale(0.507, 0.854),
        UDim2.fromScale(0.757, 0.469),
        UDim2.fromScale(0.634, 0.234),
        UDim2.fromScale(0.506, 0.469)
    }
    local VIT_NODES = {
        UDim2.fromScale(0.085, 0.368),
        UDim2.fromScale(0.192, 0.661),
        UDim2.fromScale(0.38, 0.332),
        UDim2.fromScale(0.566, 0.661),
        UDim2.fromScale(0.747, 0.332),
        UDim2.fromScale(0.91, 0.629)
    }


    local NODES = {
        STR = STR_Nodes,
        INT = INT_NODES,
        VIT = VIT_NODES
    }


    return {
        Fusion.ForValues(scope, { "STR", "INT", "VIT" }, function(_, scope: Fusion.Scope, category: string)
            return Components.Frame(scope, {
                Name = category,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.CurrentCategory) == category
                end),

                [Children] = {
                    Fusion.ForPairs(scope, NODES[category], function(_, scope: Fusion.Scope, index: number, nodePos: UDim2)
                        local isSelecting = Fusion.Value(scope, false)

                        return index, PerkNode(scope, {
                            IsSelecting = isSelecting,
                            NodePos = nodePos,
                            Index = index,
                            Category = category
                        }, {
                            CurrentSelectedPerk = props.CurrentSelectedPerk,
                            PerkPoints = props.PerkList
                        })
                    end)
                }
            })
        end)
    }
end

