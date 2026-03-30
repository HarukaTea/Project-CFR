
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local EntityBook = require(RepS.HarukaShared.Library.EntityBook)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    Enemy: Model,
})

    if not ClientLib:IsCharValid(props.Enemy) then return nil end
    if not EntityBook[props.Enemy.Name] then return nil end

    local HP = Fusion.Value(scope, 100)

    table.insert(scope, HarukaLib:Hydrate(props.Enemy.Humanoid, {
        ["Prop-Health"] = function(newHP: number)
            HP:set(newHP)
        end,
    }))

    local billboardGui = Fusion.Hydrate(scope, Components:RefUI("EnemyInfo/HP", false, true, {
        "EffectList"
    }))({
        Adornee = props.Enemy.PrimaryPart,

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("HP_EI1_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(HP)
                end)
            })
        }
    })

    --// track effect list
    ClientLib:TrackEffectListToUI({
        Target = props.Enemy,
        Scope = scope,
        GuiContainer = billboardGui.EffectList
    })

    return billboardGui
end