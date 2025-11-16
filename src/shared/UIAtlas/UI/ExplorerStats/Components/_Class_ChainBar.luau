
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)


local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    ClassVal: Fusion.Value<number>,
    Char: Model
})

    local frame = Components.Frame(scope, {
        Name = "ChainStyle",
        AnchorPoint = Vector2.zero,
        Position = UDim2.fromScale(0, 0.5),

        Visible = Fusion.Computed(scope, function(use: Fusion.Use)
            return use(props.ClassVal) > 0
        end),

        [Children] = {
            Components.Frame(scope, {
                AnchorPoint = Vector2.zero,
                Name = "BarBG",
                BackgroundTransparency = 0,
                Position = UDim2.fromScale(0.06, 0.383),
                Size = UDim2.fromScale(0.25, 0.2),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.Frame(scope, {
                        Name = "TweenBar",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromScale(0, 0.5),

                        BackgroundColor3 = ClassBook.Chain.Color,
                        BackgroundTransparency = 0,

                        [Children] = {
                            Components.RoundUICorner(scope)
                        }
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "ComboCount",
                Position = UDim2.fromScale(0.06, -0.425),
                Size = UDim2.fromScale(0.25, 0.55),

                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    return "CHAIN x"..use(props.ClassVal)
                end),
                TextColor3 = ClassBook.Chain.Color,

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {
                        Thickness = 0.1
                    })
                }
            }),
        }
    })


    local tween: Tween?
    local tweenInfo = TweenInfo.new(3.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)


    table.insert(scope, Events.Class_ChainUIUpdateSupport.On(function()
        if tween then
            tween:Cancel()
            tween = nil
        end

        frame.BarBG.TweenBar.Size = UDim2.fromScale(1, 1)

        tween = HarukaLib:CreateTween(frame.BarBG.TweenBar, tweenInfo, {
            Size = UDim2.fromScale(0, 1)
        })
        tween:Play()
    end))


    return frame
end