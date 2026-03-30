
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Time: number,
})

    local curTime = Fusion.Value(scope, 0)

    local timeVal = Instance.new("NumberValue")
    timeVal.Name = "CastTimeVal"
    timeVal.Value = 0
    timeVal.Parent = game:GetService("ServerStorage")
    table.insert(scope, timeVal)

    Debris:AddItem(timeVal, props.Time + 5)

    timeVal:GetPropertyChangedSignal("Value"):Connect(function()
        curTime:set(timeVal.Value)
    end)

    HarukaLib:CreateTween(
        timeVal,
        TweenInfo.new(props.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
        { Value = props.Time }
    ):Play()

    return Fusion.Hydrate(scope, Components:RefUI("CastTimeBar_CTB1_1", false, true, { "Casting" }))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Bar_CTBBar1_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Bar_CTBBar1_2", true))({
                        Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local x = (props.Time - use(curTime)) / props.Time

                            if x ~= x then x = 0 end
                            x = math.clamp(x, 0, 1)

                            return UDim2.fromScale(x, 1)
                        end), Components.TweenInfos.twiceHalf),
                    })
                }
            })
        }
    })
end