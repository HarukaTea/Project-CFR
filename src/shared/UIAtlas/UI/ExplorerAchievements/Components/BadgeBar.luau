
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

type Dict = { [string]: any }

return function(scope: Fusion.Scope, props: {
    BadgeId: string,
    BadgeInfo: Dict,

    IsUnlocked: Fusion.Value<boolean>,
    LayoutOrder: number
})
    local badge = props.BadgeId
    local badgeInfo = props.BadgeInfo
    local isUnlocked = props.IsUnlocked

    return Fusion.Hydrate(scope, Components:RefUI("Badge_EBadge2_1", false, true, {
        "CFEmblemTex"
    }))({
        Name = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local prefix = if use(isUnlocked) then "BBB_" else "CCC_"
            return prefix..badge
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Icon_EBadge2_1", true))({
                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return HarukaLib:CombineRbxId(use(badgeInfo).IconImageId)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Title_EBadge2_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `<u>{use(badgeInfo).Name}</u>` or "???"
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Desc_EBadge2_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(badgeInfo).Description or "???"
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Shadow_EBadge2_1", true))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(isUnlocked)
                end)
            })
        }
    })
end
