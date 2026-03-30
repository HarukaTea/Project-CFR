
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)

local Children = Fusion.Children

local plr = Players.LocalPlayer

return function(scope: Fusion.Scope, props: {
    AddedEXP: number,
})

    local level = plr:GetAttribute("Level") or 1
    local exp = plr:GetAttribute("EXP") or 0
    local maxEXP = FormulaBook.PlayerLevelCurveCal({
        Level = level
    })

    return Fusion.Hydrate(scope, Components:RefUI("LevelEXPBar_LEBar1_1", false, true, { "Line", "Title" }))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Level_LEBar1_2", true))({
                Text = level,
            }),

            Fusion.Hydrate(scope, Components:RefUI("EXP_LEBar1_2", true))({
                Text = `{exp} / {maxEXP}`,
            }),

            Fusion.Hydrate(scope, Components:RefUI("EXPJustGained_LEBar1_2", true))({
                Text = `+{props.AddedEXP}`,
            }),
        }
    })
end