
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local EntityBook = require(RepS.HarukaShared.Library.EntityBook)

local Pinia = require(script.Parent.Parent.Pinia)

local Children = Fusion.Children

local ORDER = 1

return function(scope: Fusion.Scope, props: {
    Targeting: ObjectValue,

    TargetingEnemy: Fusion.Value<ObjectValue>,
    TargetArrowPos: Fusion.Value<UDim2>
}, self: Pinia.Self) : Frame
    if not ClientLib:IsCharValid(props.Targeting.Value) then return nil end

    local targeting = props.Targeting.Value :: Model

    if not EntityBook[targeting.Name] then return nil end

    ORDER += 2
    if ORDER >= math.huge - 1 then
        ORDER = 1
    end

    local function Value<T>(val: T): Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local absContentSize = Value(Vector2.zero)

    local bar = Components.Frame(scope, {
        Name = targeting.Name,
        Size = UDim2.fromScale(0.32, 0.6),
        LayoutOrder = ORDER,

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("CornerTex_1"))({
                AnchorPoint = Vector2.xAxis,
                Size = UDim2.fromScale(0.1, 0.5),

                Position = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local sizeCon = use(absContentSize).X
                    sizeCon = math.clamp(sizeCon, 15, 999)
                    sizeCon += 8

                    return UDim2.new(1.05, sizeCon * -1, 0, 0)
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("BGBlack_EntityStat1_1", false, true))({
                Size = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local sizeCon = use(absContentSize).X
                    sizeCon = math.clamp(sizeCon, 15, 999)
                    sizeCon += 8

                    return UDim2.new(0.05, sizeCon, 1, 0)
                end),

                [Children] = {
                    Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                        local isTargeting = use(props.TargetingEnemy) == props.Targeting.Value
                        if not isTargeting then return nil end

                        return Fusion.Hydrate(scope, Components:RefUI("IsTargeting_EntityStat1_1", true))({
                            Position = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                return use(props.TargetArrowPos)
                            end)
                        })
                    end)
                }
            }),

            Components.Frame(scope, {
                Name = "TitleSection",

                [Children] = {
                    Components.UIListLayout(scope, {
                        FillDirection = Enum.FillDirection.Horizontal,
                        Padding = UDim.new(0.03, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        VerticalAlignment = Enum.VerticalAlignment.Center,

                        [Fusion.Out("AbsoluteContentSize")] = absContentSize,
                    }),
                    Components.PaddingFrame(scope, "ZZZ"),

                    Fusion.Hydrate(scope, Components:RefUI("MobIcon_EntityStat1_2", true))({
                        Name = "Icon",
                        Image = EntityBook[targeting.Name].Icon,

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            self.ForceSwitchTargetFunc(targeting)
                        end
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("EnemyLevel_EntityStat1_1", true))({
                        Text = `Lv.{targeting:GetAttribute("Level")}`
                    }),
                    Fusion.Hydrate(scope, Components:RefUI("EnemyName_EntityStat1_1", true))({
                        Text = EntityBook[targeting.Name].Name
                    })
                }
            }),
        }
    })

    local bar2 = Fusion.Hydrate(scope, Components:RefUI("EffectList_EntityStat1_1", true))({
        Name = targeting.Name.."_EffectList",
        LayoutOrder = ORDER + 1,
        Visible = false
    })

    --// track effect list
    ClientLib:TrackEffectListToUI({
        Target = targeting,
        Scope = scope,
        GuiContainer = bar2
    })

    local humanoid = targeting.Humanoid :: Humanoid
    local function _updateHealth()
        local x = humanoid.Health / humanoid.MaxHealth

        if x ~= x then x = 0 end
        x = math.clamp(x, 0, 0.998)

        local result = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(x, 0),
            NumberSequenceKeypoint.new(x + 0.001, 1),
            NumberSequenceKeypoint.new(1, 1)
        })
        HarukaLib:Tween(
            bar.TitleSection.Icon.UIStroke.UIGradient,
            Components.TweenInfos.half,
            { Transparency = result }
        )
    end
    table.insert(scope, HarukaLib:Hydrate(targeting.Humanoid, {
        ["Prop-Health"] = _updateHealth,
        ["Prop-MaxHealth"] = _updateHealth,
    }))

    return {
        bar, bar2
    }
end