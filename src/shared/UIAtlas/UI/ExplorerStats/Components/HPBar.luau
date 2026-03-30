
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HaurkaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    HP: Fusion.Value<number>,
    MaxHP: Fusion.Value<number>,

    Shield: Fusion.Value<number>,
    MaxShield: Fusion.Value<number>,
}) : Frame

    local bar1: Frame = nil

    bar1 = Fusion.Hydrate(scope, Components:RefUI("HPBar_PStats1_1", false, true, {
        "Title", "Icon", "Shield"
    }))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Bar_HPBarPStats1_1", true))({
                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local HP, maxHP = use(props.HP) :: number, use(props.MaxHP) :: number

                    local x = HP / maxHP
                    if x ~= x then x = 0 end

                    x = math.clamp(x, 0, 1)

                    return UDim2.fromScale(x, 1)
                end), Components.TweenInfos.halfBack),
            }),

            Fusion.Hydrate(scope, Components:RefUI("Stat_HPBarPStats1_1", true))({
				Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
					return use(props.HP) .. " / " .. use(props.MaxHP)
				end)
			})
        }
    })

    --// Anims

    local function _updateShield()
        local shield = Fusion.peek(props.Shield) :: number
        local maxShield = Fusion.peek(props.MaxShield) :: number

        local x = shield / maxShield
        if x ~= x then x = 0 end

        x = math.clamp(x, 0, 0.999)

        HaurkaLib:Tween(bar1.Shield.UIGradient, Components.TweenInfos.half, {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(x, 0),
                NumberSequenceKeypoint.new(x + 0.001, 1),
                NumberSequenceKeypoint.new(1, 1)
            })
        })
    end
    Fusion.Observer(scope, props.Shield):onBind(_updateShield)
    Fusion.Observer(scope, props.MaxShield):onBind(_updateShield)

    return bar1
end