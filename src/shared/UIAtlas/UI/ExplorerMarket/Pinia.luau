
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)


local wait = task.wait



export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,

    IsUIShown: Fusion.Value<boolean>,
    CurrentSelectedItemUniqueId: Fusion.Value<string>,
    CurrentSelectedItem: Fusion.Value<string>,
    CurrentCategory: Fusion.Value<string>,
    CurrentItemCategory: Fusion.Value<string>,

    CurrentPurchaseAction: Fusion.Value<string>,

    AvailableItems: Fusion.Value<Vector2>,

    IsPurchasing: Fusion.Value<boolean>,

    FilterViewShown: Fusion.Value<boolean>,
    FilterTierList: { Fusion.Value<boolean> },
    FilterItemText: Fusion.Value<string>,

    SortMethodList: { Fusion.Value<boolean> },

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

    self.CurrentPurchaseAction = Value("Purchase")

    self.AvailableItems = Value(Vector2.zero)

    self.IsPurchasing = Value(false)

    self.FilterViewShown = Value(false)
    self.FilterTierList = {

    }
    self.FilterItemText = Value("")
    for _ = 1, 5 do
        table.insert(self.FilterTierList, Value(true))
    end


    self.SortMethodList = {

    }
    for _ = 1, 4 do
        table.insert(self.SortMethodList, Value(false))
    end
    self.SortMethodList[4]:set(true)


    self.Currency = {
        Gold = Value(0),
        Astra = Value(0)
    }


    self.Products = Fusion.Value(scope, {})

    self.ItemListAbsSize = Value(Vector2.zero)

    self.Items = FusionComponents.useFolder(scope, (self.plr :: any).Items)


    local folder = FusionComponents.useFolder(scope, (self.plr :: any).EquippingItems)
    self.EquippingItems = folder :: Fusion.Value<{ StringValue }>



    --// track currency
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-Gold"] = function(val: number)
            self.Currency.Gold:set(val)
        end,
        ["Attr-Astra"] = function(val: number)
            self.Currency.Astra:set(val)
        end
    }))



    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "Market")
            self.FilterViewShown:set(false)
        end
    }))
    table.insert(scope, Events.OpenMarketUI.On(function(data)
        self.Products:set(data.Products)
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