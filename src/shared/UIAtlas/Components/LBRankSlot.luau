
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    Index: number,
    PlayerName: string,
    Value: number,
    AvatarId: string,

    IsAbyss: boolean?
})

    local text = `{props.Value}`
    if props.IsAbyss then
        text = HarukaLib:NumToTime(props.Value / 1000, true)
    end

    return Fusion.Hydrate(scope, Components:RefUI("LBRankSlot_1", false, true))({
        BackgroundTransparency = if props.Index % 2 == 0 then 0.1 else 0.65,
        LayoutOrder = props.Index,

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Icon_LBRS1_1", true))({
                Image = props.AvatarId
            }),

            Fusion.Hydrate(scope, Components:RefUI("Title_LBRS1_1", true))({
                Text = props.PlayerName,
                TextColor3 = if props.Index <= 3 then Color3.fromRGB(255, 255, 0) else Components.WHITE_COLOR
            }),

            Fusion.Hydrate(scope, Components:RefUI("Stat_LBRS1_1", true))({
                Text = text
            })
        }
    })
end