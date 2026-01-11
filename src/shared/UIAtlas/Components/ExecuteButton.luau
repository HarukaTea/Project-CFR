
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    AnchorPoint: Vector2?,
    LayoutOrder: number?,
    Position: UDim2?,
    Size: UDim2?,
    ButtonText: string?,
    ButtonClickFunc: () -> nil,
    ButtonType: "Confirm" | "Cancel" | "Info",

    Id: string?
})
    props.AnchorPoint = props.AnchorPoint or Vector2.new()
    props.LayoutOrder = props.LayoutOrder or 1
    props.Position = props.Position or UDim2.fromScale(0, 0)
    props.Size = props.Size or UDim2.fromScale(1, 1)
    props.ButtonType = props.ButtonType or "Confirm"
    props.ButtonText = props.ButtonText or "Execute"
    props.ButtonClickFunc = props.ButtonClickFunc or function () end

    props.Id = props.Id or props.ButtonText

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

    return Fusion.Hydrate(scope, Components:RefUI("ExecuteButton", false, true))({
        Name = "ExecuteButton_"..props.Id,

        AnchorPoint = props.AnchorPoint,
        LayoutOrder = props.LayoutOrder,
        Position = props.Position,
        Size = props.Size,

        [Fusion.OnEvent("MouseButton1Click")] = props.ButtonClickFunc,

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Icon_EB1_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("IconLabel_EB1_2", true))({
                        Size = SIZES[props.ButtonType],
                        Image = ICONS[props.ButtonType],
                        ImageColor3 = COLORS[props.ButtonType],
                    })
                }
            }),
            Fusion.Hydrate(scope, Components:RefUI("ButtonText_EB1_1", true))({
                Text = props.ButtonText,
            })
        }
    })
end