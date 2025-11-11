
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope<any>, props: {
    AnchorPoint: Vector2?,
    LayoutOrder: number?,
    Position: UDim2?,
    Size: UDim2?,
    ButtonText: string?,
    ButtonClickFunc: () -> nil,
    ButtonType: "Confirm" | "Cancel" | "Info"
})
    props.AnchorPoint = props.AnchorPoint or Vector2.new()
    props.LayoutOrder = props.LayoutOrder or 1
    props.Position = props.Position or UDim2.fromScale(0, 0)
    props.Size = props.Size or UDim2.fromScale(1, 1)
    props.ButtonType = props.ButtonType or "Confirm"
    props.ButtonText = props.ButtonText or "Execute"
    props.ButtonClickFunc = props.ButtonClickFunc or function () end


    local ICONS = {
        Confirm = "rbxassetid://89237327031557",
        Cancel = "rbxassetid://103065634382876",
        Info = "rbxassetid://118039396578953"
    }
    local COLORS = {
        Confirm = Color3.fromRGB(0, 255, 127),
        Cancel = Color3.fromRGB(255, 85, 0),
        Info = Color3.fromRGB(255, 255, 255)
    }
    local SIZES = {
        Confirm = UDim2.fromScale(0.8, 0.8),
        Cancel = UDim2.fromScale(0.95, 0.95),
        Info = UDim2.fromScale(0.8, 0.8)
    }


	return Components.TextButton(scope, {
        Name = "ExecuteButton",
        AutoButtonColor = true,
        BackgroundColor3 = Components.WHITE_COLOR,
        TextColor3 = Components.HarukaColorLab.Genshin.Background,

        AnchorPoint = props.AnchorPoint,
        LayoutOrder = props.LayoutOrder,
        Position = props.Position,
        Size = props.Size,

        [Fusion.OnEvent("MouseButton1Click")] = props.ButtonClickFunc,

        [Children] = {
            Components.RoundUICorner(scope),

            Components.UIListLayout(scope, {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0.05, 0),
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
            Components.UIPadding(scope, {}),

            Components.Frame(scope, {
                Name = "Icon",
                LayoutOrder = 1,
                ZIndex = 0,
                BackgroundTransparency = 0,
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.IconImageLabel(scope, {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = SIZES[props.ButtonType],

                        Image = ICONS[props.ButtonType],
                        ImageColor3 = COLORS[props.ButtonType],
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "ButtonText",
                LayoutOrder = 2,
                Size = UDim2.fromScale(0.8, 0.9),
                TextColor3 = Color3.fromRGB(44, 49, 62),

                Text = props.ButtonText,

                [Children] = {
                    Components.UIPadding(scope, {
                        PaddingLeft = UDim.new(),
                        PaddingTop = UDim.new(),
                        PaddingBottom = UDim.new(),
                    })
                }
            })
        }
    })
end