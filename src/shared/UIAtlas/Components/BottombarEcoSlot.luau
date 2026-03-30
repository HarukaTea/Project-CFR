
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Currency: string,
    Index: number,

    CurrencyVal: Fusion.Value<number>
})

    local isSelecting = Fusion.Value(scope, false)

    local ICONS = AssetBook.CurrencyIcons

    return Fusion.Hydrate(scope, Components:RefUI("BottomEcoTemplate_Eco1_1", false, false, {
        "UICorner"
    }))({
        Name = props.Currency,
        LayoutOrder = props.Index,

        Components.ConnectSelectEvents(isSelecting),

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.08,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Components.PaddingFrame(scope, "AAA"),

            Components.IconImageLabel(scope, {
                Size = UDim2.fromScale(0.75, 0.75),
                Image = ICONS[props.Currency],
                LayoutOrder = 1,
            }),

            Fusion.Hydrate(scope, Components:RefUI("CurrencyHave_Eco1_1"))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local currency = use(props.CurrencyVal)

                    if use(isSelecting) then
                        return HarukaLib:AddCommaToNum(currency)
                    else
                        return HarukaLib:AbbreviateNum(currency, 1)
                    end
                end),
            })
        }
    })
end