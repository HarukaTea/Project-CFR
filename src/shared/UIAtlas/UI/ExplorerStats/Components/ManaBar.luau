
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    Mana: Fusion.Value<number>,
    MaxMana: Fusion.Value<number>,

}) : Frame

    return Fusion.Hydrate(scope, Components:RefUI("ManaBar_PStat1_1", false, true, {
        "Icon", "Title"
    }))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Bar_ManaBarPStat1_2", true))({
                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local mana, maxMana = use(props.Mana) :: number, use(props.MaxMana) :: number

                    local x = mana / maxMana
                    if x ~= x then x = 0 end

                    x = math.clamp(x, 0, 1)

                    return UDim2.fromScale(x, 1)
                end), Components.TweenInfos.halfBack),
            }),

            Fusion.Hydrate(scope, Components:RefUI("Stat_ManaBarPStat1_2", true))({
				Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
					return use(props.Mana) .. " / " .. use(props.MaxMana)
				end),
			})
        }
    })
end