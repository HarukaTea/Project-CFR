
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope<any>, props: {
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


    return Components.Frame(scope, {
        Name = "CastTimeBar",
        Size = UDim2.fromScale(0.4, 1),

        [Children] = {
            Components.UIListLayout(scope, {
                Padding = UDim.new(0.15, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),

            Components.Frame(scope, {
                Name = "TimeBar",
                BackgroundTransparency = 0,
                Size = UDim2.fromScale(1, 0.25),

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.Frame(scope, {
                        Name = "Bar",
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.fromScale(0, 0),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Color3.fromHex('#7ce4f8'),

                        Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local x = (props.Time - use(curTime)) / props.Time

                            if x ~= x then x = 0 end
                            x = math.clamp(x, 0, 1)

                            return UDim2.fromScale(x, 1)
                        end), AssetBook.TweenInfos.twiceHalf),


                        [Children] = {
                            Components.RoundUICorner(scope),
                        }
                    }),
                }
            }),

            Components.TextLabel(scope, {
                Name = "TimeLeft",
                Size = UDim2.fromScale(1, 0.5),
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),

                Text = "CASTING",

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {})
                }
            })
        }
    })
end