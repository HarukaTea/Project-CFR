
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local statIcons = {
    DMG = "rbxassetid://2965862892",
    Magic = "rbxassetid://2965863231",
    Gold = "rbxassetid://18421784947"
}

return function (scope: Fusion.Scope, props: {
    StatId: string,

    StatValue: Fusion.Value<number>,
    StatValue2: Fusion.Value<number>?,

    LayoutOrder: number,
})

    return Fusion.Hydrate(scope, Components:RefUI("DMGStat_PStat1_2", false, true))({
        Name = props.StatId,
        LayoutOrder = props.LayoutOrder,

        [Children] = {
            Components.IconImageLabel(scope, {
                Name = "StatIcon_"..props.StatId,
                LayoutOrder = 1,

                Image = statIcons[props.StatId],
            }),

            Fusion.Hydrate(scope, Components:RefUI("StatText_PStat1_4", true))({
                Name = "StatText_"..props.StatId,
                LayoutOrder = 2,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    if props.StatId == "DMG" then
                        return HarukaLib:AddCommaToNum(use(props.StatValue)).."-"..HarukaLib:AddCommaToNum(use(props.StatValue2))
                    else
                        return HarukaLib:AddCommaToNum(use(props.StatValue))
                    end
                end)
            })
        },
    })
end