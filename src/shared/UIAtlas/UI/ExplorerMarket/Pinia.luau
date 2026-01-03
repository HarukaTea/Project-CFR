
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,

    IsUIShown: Fusion.Value<boolean>,
    CurrentSelectedItemUniqueId: Fusion.Value<string>,
    CurrentSelectedItem: Fusion.Value<string>,
    CurrentCategory: Fusion.Value<string>,
    CurrentItemCategory: Fusion.Value<string>,

    AvailableItems: Fusion.Value<Vector2>,

    IsPurchasing: Fusion.Value<boolean>,
    CurrencyUsing: Fusion.Value<string>,

    Currency: {
        Gold: Fusion.Value<number>,
        Astra: Fusion.Value<number>
    },

    Products: Fusion.Value<{
        ProductId: string,
        ProductUniqueId: string,
    } | {}>,

    ItemListAbsSize: Fusion.Value<Vector2>,

    Items: Fusion.Value<{ IntConstrainedValue }>,
    EquippingItems: Fusion.Value<{ StringValue }>
}


return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope


    self.IsUIShown = Value(false)


    self.CurrentSelectedItemUniqueId = Value("")
    self.CurrentSelectedItem = Value("")
    self.CurrentCategory = Value("Market")
    self.CurrentItemCategory = Value("Accessory")

    self.AvailableItems = Value(Vector2.zero)

    self.IsPurchasing = Value(false)
    self.CurrencyUsing = Value("Gold")

    self.Currency = {
        Gold = Value(0),
        Astra = Value(0),

        HalloweenCandy = Value(0),
        IceCandy = Value(0),
    }


    self.Products = Fusion.Value(scope, {})

    self.ItemListAbsSize = Value(Vector2.zero)

    self.Items = Components.FusionComponents.useChildren(scope, self.plr.Items)


    local folder = Components.FusionComponents.useChildren(scope, self.plr.EquippingItems)
    self.EquippingItems = folder :: Fusion.Value<{ StringValue }>



    --// track currency
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-Gold"] = function(val: number)
            self.Currency.Gold:set(val)
        end,
        ["Attr-Astra"] = function(val: number)
            self.Currency.Astra:set(val)
        end,

        ["Attr-HalloweenCandy"] = function(val: number)
            self.Currency.HalloweenCandy:set(val)
        end,
        ["Attr-IceCandy"] = function(val: number)
            self.Currency.IceCandy:set(val)
        end,
    }))



    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "Market")
        end
    }))
    table.insert(scope, Events.OpenMarketUI_S.On(function(data)
        self.Products:set(data.Products)
        self.CurrencyUsing:set(data.CurrencyId)

        self.plr:SetAttribute("CurrentUIGroup", "Market")
    end))


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_Market",
        Size = 21,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)
    })
    blur.Parent = workspace.CurrentCamera
end