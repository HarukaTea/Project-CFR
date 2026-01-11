
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)


local Children = Fusion.Children


local plr = Players.LocalPlayer

return function(scope: Fusion.Scope, props: {
    AddedEXP: number,
})

    local level = plr:GetAttribute("Level") or 1
    local exp = plr:GetAttribute("EXP") or 0
    local maxEXP = FormulaBook.PlayerLevelCurveCal({
        Level = level
    })

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
                Text = level,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.ScaledTextUIStroke(scope, {
                        Name = "UIStrokeText"
                    }),
                    Components.ScaledUIStroke(scope, {
                        Color = Color3.fromHex('#7bed9f'),
                        Thickness = 0.07
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
                    Components.ScaledTextUIStroke(scope, {})
                }
            }),
            Components.TextLabel(scope, {
                Name = "EXP",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 1.3),
                Size = UDim2.fromScale(1, 0.4),
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                Text = `{exp} / {maxEXP}`,

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {})
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
                    Components.ScaledTextUIStroke(scope, {})
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
        }
    })
end