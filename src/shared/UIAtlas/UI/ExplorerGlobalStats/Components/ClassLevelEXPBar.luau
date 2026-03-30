
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)

local Children = Fusion.Children

local plr = Players.LocalPlayer

return function(scope: Fusion.Scope, props: {
    AddedClassEXP: number
})

    local class = plr:GetAttribute("Class") or "Chain"
    local classLevel = plr:GetAttribute("ClassLevel_"..class) or 1
    local classEXP = plr:GetAttribute("ClassEXP_"..class) or 0
    local maxClassEXP = FormulaBook.PlayerClassLevelCurveCal({
        Level = classLevel,
    })

    return Fusion.Hydrate(scope, Components:RefUI("ClassLevelEXPBar_CLEBar1_1", false, true, { "Line2", "Title" }))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Level_CLEBar1_2", true))({
                Text = classLevel,
            }),

            Fusion.Hydrate(scope, Components:RefUI("EXP_CLEBar1_2", true))({
                Text = `{classEXP} / {maxClassEXP}`,
            }),

            Fusion.Hydrate(scope, Components:RefUI("EXPJustGained_CLEBar1_2", true))({
                Text = `+{props.AddedClassEXP}`,
            }),
        }
    })
end