
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local EntityBook = require(RepS.HarukaShared.Library.EntityBook)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    TargetingList: Fusion.Value<{ ObjectValue }>
})
    return Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local targetingBoss: ObjectValue = nil

        for _, symbol in use(props.TargetingList) do
            local model = symbol.Value :: Model

            if not ClientLib:IsCharValid(model) then continue end
            if not EntityBook[model.Name] then continue end

            if EntityBook[model.Name].IsBoss then
                targetingBoss = symbol
                break
            end
        end

        if targetingBoss == nil then return nil end

        local targeting = targetingBoss.Value :: Model
        local entityInfo = EntityBook[targeting.Name]

        local function Value<T>(val: T): Fusion.Value<T>
            return Fusion.Value(scope, val)
        end
        local level = Value(1)
        local HP = Value(100)
        local maxHP = Value(100)
        local DMGMultiplier = Value(100)
        local breakProgress = Value(0)
        local totalBreakProgress = Value(100)

        table.insert(scope, HarukaLib:Hydrate(targeting, {
            ["Attr-Level"] = function(val: number)
                level:set(val)
            end,
            ["Attr-DMGTakenBonus"] = function(val: number)
                DMGMultiplier:set(val)
            end,
            ["Attr-BreakProgress"] = function(val: number)
                breakProgress:set(val)
            end,
            ["Attr-TotalBreakProgress"] = function(val: number)
                totalBreakProgress:set(val)
            end
        }))
        table.insert(scope, HarukaLib:Hydrate(targeting.Humanoid, {
            ["Prop-Health"] = function(newHP: number)
                HP:set(newHP)
            end,
            ["Prop-MaxHealth"] = function(newMaxHP: number)
                maxHP:set(newMaxHP)
            end
        }))

        local frame = Fusion.Hydrate(scope, Components:RefUI("BossHPBar_Entity1_1", false, true, {
            "EffectList"
        }))({
            [Children] = {
                Fusion.Hydrate(scope, Components:RefUI("BossIcon_Entity1_1", true))({
                    Image = entityInfo.Icon
                }),
                Fusion.Hydrate(scope, Components:RefUI("BossName_Entity1_1", true))({
                    Text = entityInfo.Name
                }),
                Fusion.Hydrate(scope, Components:RefUI("BossTag_Entity1_1", true))({
                    Text = entityInfo.Tag
                }),

                Fusion.Hydrate(scope, Components:RefUI("HPBar_Entity1_1", false, true, {
                    "HighlightTex"
                }))({
                    [Children] = {
                        Fusion.Hydrate(scope, Components:RefUI("Bar_BEntity1_1", true))({
                            Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local HPState, maxHPState = use(HP) :: number, use(maxHP) :: number

                                local x = HPState / maxHPState
                                if x ~= x then x = 0 end

                                x = math.clamp(x, 0, 1)

                                return UDim2.fromScale(x, 1)
                            end), Components.TweenInfos.half)
                        }),
                        Fusion.Hydrate(scope, Components:RefUI("Bar2_BEntity1_1", true))({
                            Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local HPState, maxHPState = use(HP) :: number, use(maxHP) :: number

                                local x = HPState / maxHPState
                                if x ~= x then x = 0 end

                                x = math.clamp(x, 0, 1)

                                return UDim2.fromScale(x, 1)
                            end), Components.TweenInfos.one),
                        }),

                        Fusion.Hydrate(scope, Components:RefUI("DamageMultiplier_BEntity1_1", true))({
                            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                return `x{use(DMGMultiplier)}%`
                            end),
                            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                return use(DMGMultiplier) > 100
                            end)
                        }),
                        Fusion.Hydrate(scope, Components:RefUI("Stat_BEntity1_1", true))({
                            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local HPState, maxHPState = use(HP) :: number, use(maxHP) :: number

                                local x = HPState / maxHPState
                                if x ~= x then x = 0 end

                                x = math.clamp(x, 0, 1)
                                return string.format("%.1f", x * 100).."%"
                            end),
                        })
                    }
                }),

                Fusion.Hydrate(scope, Components:RefUI("BreakBar_Entity1_1", false, true, {
                    "Title"
                }))({
                    [Children] = {
                        Fusion.Hydrate(scope, Components:RefUI("Bar_BEntity1_2", true))({
                            Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local breakState, maxBreakState = use(breakProgress) :: number, use(totalBreakProgress) :: number

                                local x = breakState / maxBreakState
                                if x ~= x then x = 0 end

                                x = math.clamp(x, 0, 1)

                                return UDim2.fromScale(x, 1)
                            end), Components.TweenInfos.half)
                        }),
                        Fusion.Hydrate(scope, Components:RefUI("Bar2_BEntity1_2", true))({
                            Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local breakState, maxBreakState = use(breakProgress) :: number, use(totalBreakProgress) :: number

                                local x = breakState / maxBreakState
                                if x ~= x then x = 0 end

                                x = math.clamp(x, 0, 1)

                                return UDim2.fromScale(x, 1)
                            end), Components.TweenInfos.one)
                        })
                    }
                })
            }
        })

        --// track effect list
        ClientLib:TrackEffectListToUI({
            Target = targeting,
            Scope = scope,
            GuiContainer = frame.EffectList
        })

        return frame
    end)

end