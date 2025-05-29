--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Currency: string,
    Index: number,

    CurrencyVal: Fusion.Value
})

    local isSelecting = Fusion.Value(scope, false)

    local ICONS = {
        Gold = "rbxassetid://18421784947",
        Astra = "rbxassetid://93309091471652",
    }

    return Components.HoverImageButton(scope, {
        Name = props.Currency,
        AutoButtonColor = false,
        Size = UDim2.fromScale(0.15, 0.7),
        BackgroundColor3 = Color3.new(),
        BackgroundTransparency = 0.3,
        LayoutOrder = props.Index,


        [Fusion.OnEvent("MouseEnter")] = function()
            isSelecting:set(true)
        end,
        [Fusion.OnEvent("MouseLeave")] = function()
            isSelecting:set(false)
        end,


        [Children] = {
            Components.RoundUICorner(scope),

            Components.UIStroke(scope, {
                Thickness = 2,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Components.UIListLayout(scope, {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0.05, 0)
            }),

            Components.PaddingFrame(scope, "AAA"),

            Components.IconImageLabel(scope, {
                Size = UDim2.fromScale(0.75, 0.75),
                Image = ICONS[props.Currency],
                LayoutOrder = 1,
            }),

            Components.TextLabel(scope, {
                Name = "CurrencyHave",
                Size = UDim2.fromScale(0.65, 0.7),

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local currency = use(props.CurrencyVal)

                    if use(isSelecting) then
                        return HarukaLib:CommaifyNumber(currency)
                    else
                        return HarukaLib:NumberConvert(currency, 1)
                    end
                end),

                TextXAlignment = Enum.TextXAlignment.Right,
            })
        }
    })
end
