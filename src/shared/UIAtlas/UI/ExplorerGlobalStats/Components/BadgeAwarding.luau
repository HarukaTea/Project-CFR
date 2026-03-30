
local BadgeService = game:GetService("BadgeService")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    BadgeId: number
})

    local badgeInfo = Fusion.Value(scope, {})
    table.insert(scope, task.spawn(function()
        local info
        pcall(function()
            info = BadgeService:GetBadgeInfoAsync(props.BadgeId)
        end)
        info = info or {}
        badgeInfo:set(info)
    end))


    local frame = Fusion.Hydrate(scope, Components:RefUI("BadgeAwardingBar_BAFX1_1", false, true, {
        "CFEmblemTex"
    }))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Icon_BAFX1_1", true))({
                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return HarukaLib:CombineRbxId(use(badgeInfo).IconImageId) or ""
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Title_BAFX1_1", true))({
                Text = "<u>New Achievement!</u>"
            }),

            Fusion.Hydrate(scope, Components:RefUI("Desc_BAFX1_1", true))({
                Name = "BadgeTitle",

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(badgeInfo).Name or ""
                end)
            }),
        }
    })

    return frame
end