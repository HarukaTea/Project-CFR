--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children, Computed = Fusion.Children, Fusion.Computed

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local clamp = math.clamp


return function (scope: Fusion.Scope, props: {
    ClassVal: Fusion.Value,
    ClassVal2: Fusion.Value,

    Char: Model
})
    return Components.Frame(scope, {
        Name = "FlowStyle",
        AnchorPoint = Vector2.zero,
        Position = fromScale(0, 0.5),

        Visible = Computed(scope, function(use: Fusion.Use)
            return use(props.ClassVal) > 0
        end),

        [Children] = {
            Components.Frame(scope, {
                AnchorPoint = v2New(),
                Name = "BarBG",
                BackgroundTransparency = 0,
                Position = fromScale(0.06, 0.383),
                Size = fromScale(0.25, 0.2),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.Frame(scope, {
                        Name = "TweenBar",

                        BackgroundColor3 = ClassBook.Flow.Color,
                        BackgroundTransparency = 0,

                        Size = Fusion.Tween(scope, Computed(scope, function(use: Fusion.Use)
                            local amount = use(props.ClassVal) :: number

                            amount = clamp(amount, 0, 100)
                            return fromScale(amount / 100, 1)

                        end), AssetBook.TweenInfos.twiceHalf),


                        [Children] = { Components.RoundUICorner(scope) }
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "Amount",
                Position = fromScale(0.06, -0.425),
                Size = fromScale(0.25, 0.55),

                Text = Fusion.Computed(scope, function(use: Fusion.Use)
                    local amount = use(props.ClassVal) :: number

                    return "Flow "..tostring(amount).."%"
                end),
                TextColor3 = ClassBook.Flow.Color,

                [Children] = { Components.TextUIStroke(scope, { Thickness = 2 }) }
            }),

            Components.TextLabel(scope, {
                Name = "Tip",
                Position = fromScale(0.06, 0.7),
                Size = fromScale(0.25, 0.35),
                Text = ClassBook.Flow.Hint,
                FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold, Enum.FontStyle.Italic),

                [Children] = { Components.TextUIStroke(scope, { Thickness = 1.5 }) }
            })
        }
    })
end