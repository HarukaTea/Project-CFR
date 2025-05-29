--!nocheck

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


    return Components.IconImageLabel(scope, {
        Name = effect.Value,

        Image = Fusion.Computed(scope, function()
            if EffectBook[effect.Value] then
                return EffectBook[effect.Value].Icon
            else
                warn(`Effect Id not found in EffectBook: {effect.Value}`)
                return ""
            end
        end),

        [Children] = {
            Components.TextLabel(scope, {
                Name = "Power",
                Position = UDim2.fromScale(0, 0.6),
                Size = UDim2.fromScale(1, 0.5),
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                ZIndex = 10,

                Text = Fusion.Computed(scope, function()
                    local ex = effect:GetAttribute("Ex") :: number?
                    local power = effect:GetAttribute("Power") :: number?

                    if power ~= 0 then
                        return `{power}x`
                    end
                    if ex then
                        if ex <= 0 then
                            return ex
                        else
                            return `+{ex}`
                        end
                    end
                end),

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 1.7 })
                }
            }),


            ProgressCircle(scope, {
                Direction = "Left",
                RotationVal = rotationVal,

                Color = Fusion.Computed(scope, function()
                    if EffectBook[effect.Value] then
                        return EffectBook[effect.Value].Color
                    else
                        warn(`Effect Id not found in EffectBook: {effect.Value}`)
                        return Color3.new(1, 1, 1)
                    end
                end),
            }),
            ProgressCircle(scope, {
                Direction = "Right",
                RotationVal = rotationVal,

                Color = Fusion.Computed(scope, function()
                    if EffectBook[effect.Value] then
                        return EffectBook[effect.Value].Color
                    else
                        warn(`Effect Id not found in EffectBook: {effect.Value}`)
                        return Color3.new(1, 1, 1)
                    end
                end),
            })
        }
    })
end
