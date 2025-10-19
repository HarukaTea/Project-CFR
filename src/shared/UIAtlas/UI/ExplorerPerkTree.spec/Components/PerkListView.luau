--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local PerkNode = require(script.Parent.PerkNode)


local NODE_POS = {
    root1 = UDim2.fromScale(0.052, 0.458),

    phy1 = UDim2.fromScale(0.17, 0.235),
    phy2 = UDim2.fromScale(0.37, 0.235),
    phy3 = UDim2.fromScale(0.57, 0.235),
    phy4 = UDim2.fromScale(0.77, 0.235),
    phy1_branch = UDim2.fromScale(0.079, 0.11),
    phy2_branch = UDim2.fromScale(0.305, 0.088),
    phy3_branch = UDim2.fromScale(0.856, 0.088),

    magic1 = UDim2.fromScale(0.17, 0.746),
    magic2 = UDim2.fromScale(0.37, 0.746),
    magic3 = UDim2.fromScale(0.57, 0.746),
    magic4 = UDim2.fromScale(0.77, 0.746),
    magic1_branch = UDim2.fromScale(0.091, 0.877),
    magic2_branch = UDim2.fromScale(0.449, 0.907),
    magic3_branch = UDim2.fromScale(0.874, 0.907),

    universal1 = UDim2.fromScale(0.267, 0.468),
    universal2 = UDim2.fromScale(0.467, 0.468),
    universal3 = UDim2.fromScale(0.667, 0.468),
}


return function (scope: Fusion.Scope, props: {
    CurrentSelectedPerk: Fusion.Value,
    Talents: Fusion.Value
})
    return Fusion.ForPairs(scope, NODE_POS, function(_, scope: Fusion.Scope, perkId: string, nodePos: UDim2)
        local isSelecting = Fusion.Value(scope, false)

        return perkId, PerkNode(scope, {
            IsSelecting = isSelecting,
            NodePos = nodePos,
            PerkId = perkId
        }, {
            CurrentSelectedPerk = props.CurrentSelectedPerk,
            Talents = props.Talents
        })
    end)
end