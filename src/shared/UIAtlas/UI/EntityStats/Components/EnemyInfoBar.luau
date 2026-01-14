
local RepS = game:GetService("ReplicatedStorage")

local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
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

    local function Value<T>(val: T): Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local level = Value(1)
    local HP = Value(100)

    table.insert(scope, HarukaLib:Hydrate(props.Enemy.Humanoid, {
        ["Prop-Health"] = function(newHP: number)
            HP:set(newHP)
        end,
    }))
    table.insert(scope, HarukaLib:Hydrate(props.Enemy, {
        ["Attr-Level"] = function(val: number)
            level:set(val)
        end
    }))

    return Fusion.Hydrate(scope, Components:RefUI("EnemyInfo/Info"))({
        Adornee = props.Enemy.PrimaryPart,
        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(HP) > 0
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("TitleSection_EI1_1", false, true))({
                [Children] = {
                    Components.PaddingFrame(scope, "ZZZ"),

                    Fusion.Hydrate(scope, Components:RefUI("Icon_EI1_1", true))({
                        Image = EntityBook[props.Enemy.Name].Icon
                    }),
                    Fusion.Hydrate(scope, Components:RefUI("EnemyLevel_EI1_1", true))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `Lv.{use(level)}`
                        end)
                    })
                }
            })
        }
    })
end