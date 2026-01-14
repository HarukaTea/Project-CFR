
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local Children = Fusion.Children

type Dict = { [string]: any }

return function(scope: Fusion.Scope, props: {
    BadgeCompletedCount: Fusion.Value<number>,
    HasGottenReward: Fusion.Value<boolean>
})
    return Fusion.Hydrate(scope, Components:RefUI("BadgeRewards_EBadge1_1", false, false, {
        "Tip", "AwardIcon"
    }))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("ProgressBar_EBadge2_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ProgressBar_EBadge2_2", true))({
                        Size = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local x = use(props.BadgeCompletedCount) / 6
                            if x ~= x then x = 0 end -- NaN check
                            x = math.clamp(x, 0, 1)

                            return UDim2.fromScale(x, 1)
                        end)
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("ClaimBtn_EBadge1_1", true))({
                BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(props.BadgeCompletedCount) >= 6 then Components.BLUE_COLOR else Components.RED_COLOR
                end),
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(props.HasGottenReward)
                end),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if Fusion.peek(props.BadgeCompletedCount) < 6 then
                        Bindables.CreateNotify:Fire("Collect 6 badges to claim this reward")
                        return
                    end

                    Events.ClaimBadgeReward_C.Fire()
                    props.HasGottenReward:set(true)
                end,
            }),

            Fusion.Hydrate(scope, Components:RefUI("Progress_EBadge2_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `{use(props.BadgeCompletedCount)} / 6    COMPLETED`
                end)
            })
        }
    })
end