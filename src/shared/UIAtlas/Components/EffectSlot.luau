
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local EffectBook = require(RepS.HarukaShared.Library.StatusBook)

local ProgressCircle = require(RepS.HarukaShared.UIAtlas.Components.ProgressCircle)

local Children = Fusion.Children

return function (scope: Fusion.Scope, effect: StringValue) : ImageLabel
    local rotationVal = Fusion.Value(scope, 1)

    local rotationValForTween = Instance.new("NumberValue")
    rotationValForTween.Value = 1
    rotationValForTween.Name = "RotationVal"
    rotationValForTween.Parent = game:GetService("ServerStorage")
    table.insert(scope, rotationValForTween)

    rotationValForTween:GetPropertyChangedSignal("Value"):Connect(function()
        rotationVal:set(rotationValForTween.Value)
    end)

    local nowClock = DateTime.now().UnixTimestamp :: number
    local endClock = effect:GetAttribute("EndClock") :: number
    local tweenInfo = TweenInfo.new(endClock - nowClock, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    HarukaLib:CreateTween(rotationValForTween, tweenInfo, {
        Value = 0
    }):Play()

    local icon, iconColor, color
    local info = EffectBook[effect.Value]

    icon = info.Icon or ""
    iconColor = info.IconColor or Color3.new(1, 1, 1)
    color = info.Color or Color3.new(1, 1, 1)

    return Fusion.Hydrate(scope, Components:RefUI("EffectSlot_1", false, true))({
        Name = effect.Value,

        Image = icon,
        ImageColor3 = iconColor,

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Power_EffectSlot1_1", true))({
                Text = Fusion.Computed(scope, function()
                    local ex = effect:GetAttribute("Ex") :: number?
                    local power = effect:GetAttribute("Power") :: number?

                    if power ~= 0 then
                        if power < 1 then power += 1 end
                        power = string.format("%.1f", power)
                        return `{power}x`
                    end
                    if ex then
                        return if ex <= 0 then ex else `+{ex}`
                    end
                end),
            }),

            ProgressCircle(scope, {
                Direction = "Left",
                RotationVal = rotationVal,
                Color = color
            }),
            ProgressCircle(scope, {
                Direction = "Right",
                RotationVal = rotationVal,
                Color = color
            })
        }
    })
end