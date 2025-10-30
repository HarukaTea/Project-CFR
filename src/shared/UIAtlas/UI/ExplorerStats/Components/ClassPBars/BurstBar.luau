
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children


return function (scope: Fusion.Scope<any>, props: {
    ClassVal: Fusion.Value<number>,
    ClassVal2: Fusion.Value<number>,

    Char: Model
})
    return Components.Frame(scope, {
        Name = "BurstStyle",
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

                        BackgroundColor3 = ClassBook.Burst.Color,
                        BackgroundTransparency = 0,

                        Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                            local amount = use(props.ClassVal) :: number

                            amount = math.clamp(amount, 0, 10)
                            return UDim2.fromScale(amount / 10, 1)

                        end), AssetBook.TweenInfos.twiceHalf),


                        [Children] = { Components.RoundUICorner(scope) }
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "Amount",
                Position = UDim2.fromScale(0.06, -0.425),
                Size = UDim2.fromScale(0.25, 0.55),

                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    local amount = use(props.ClassVal) :: number
                    if amount == 1 then
                        return amount.. " Arrow"
                    else
                        return amount.. " Arrows"
                    end
                end),
                TextColor3 = ClassBook.Burst.Color,

                [Children] = { Components.TextUIStroke(scope, { Thickness = 2 }) }
            }),

            Components.TextLabel(scope, {
                Name = "Tip",
                Position = UDim2.fromScale(0.06, 0.7),
                Size = UDim2.fromScale(0.25, 0.35),
                Text = ClassBook.Burst.Hint,
                FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Italic),

                [Children] = { Components.TextUIStroke(scope, { Thickness = 1.5 }) }
            })
        }
    })
end