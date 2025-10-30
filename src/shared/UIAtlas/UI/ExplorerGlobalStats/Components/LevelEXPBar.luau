
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)


local Children = Fusion.Children

return function(scope: Fusion.Scope<any>, props: {
    AddedEXP: number
})

    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local level = Value(1)
    local exp = Value(100)
    local maxEXP = Value(100)


    table.insert(scope, HarukaLib:Hydrate(Players.LocalPlayer, {
        ["Attr-Level"] = function(val: number)
            level:set(val)
            maxEXP:set(FormulaBook.PlayerLevelCurveCal({
                Level = val
            }))
        end,
        ["Attr-EXP"] = function(val: number)
            exp:set(val)
        end
    }))


    return Components.Frame(scope, {
        Name = "LevelEXPBar",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.fromScale(0.2, 1),

        [Children] = {
            Components.TextLabel(scope, {
                Name = "Level",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1.2, 1.2),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                TextColor3 = Color3.fromHex("#7bed9f"),


                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(level)
                end),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.TextUIStroke(scope, {
                        Name = "UIStrokeText",
                        Thickness = 2
                    }),
                    Components.UIStroke(scope, {
                        Name = "UIStroke",
                        Color = Color3.fromHex('#7bed9f'),
                        Thickness = 3
                    }),
                    Components.UIPadding(scope, {
                        PaddingTop = UDim.new(0.15, 0),
                        PaddingBottom = UDim.new(0.15, 0),
                        PaddingLeft = UDim.new(0.15, 0),
                        PaddingRight = UDim.new(0.15, 0)
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "Title",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -0.8),
                Size = UDim2.fromScale(1, 0.5),
                TextColor3 = Color3.fromHex("#7bed9f"),

                Text = "LEVEL",

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 1.5 })
                }
            }),
            Components.TextLabel(scope, {
                Name = "EXP",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 1.3),
                Size = UDim2.fromScale(1, 0.4),
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `{use(exp)}  /  {use(maxEXP)}`
                end),

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 2 })
                }
            }),
            Components.TextLabel(scope, {
                Name = "EXPGained",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 1.8),
                Size = UDim2.fromScale(1, 0.4),
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                TextColor3 = Color3.fromHex("#ffeaa7"),

                Text = `+{props.AddedEXP}`,

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 2 })
                }
            }),


            Components.Frame(scope, {
                Name = "Line",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0, 0.5),
                BackgroundTransparency = 0,
                BackgroundColor3 = Color3.fromHex('#7bed9f'),
                Size = UDim2.fromScale(0.3, 0.1)
            }),
            Components.Frame(scope, {
                Name = "Line",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.fromScale(1, 0.5),
                BackgroundTransparency = 0,
                BackgroundColor3 = Color3.fromHex('#7bed9f'),
                Size = UDim2.fromScale(0.3, 0.1)
            })
        }
    })
end