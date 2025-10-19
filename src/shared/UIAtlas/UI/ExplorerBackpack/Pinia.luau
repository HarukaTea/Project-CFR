--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,


    IsUIShown: Fusion.Value<boolean>,
    FilterViewShown: Fusion.Value<boolean>,
    FilterTierList: { Fusion.Value<boolean> },
    FilterItemText: Fusion.Value<string>,
    SortMethodList: { Fusion.Value<boolean> },

    AvailableItems: Fusion.Value<Vector2>,

    CurrentSelectedItem: Fusion.Value<string>,
    CurrentSelectedItemUniqueId: Fusion.Value<string>,
    CurrentCategory: Fusion.Value<string>,

    Currency: {
        Gold: Fusion.Value<number>,
        Astra: Fusion.Value<number>
    },

    ItemListAbsSize: Fusion.Value<Vector2>,
    Items: Fusion.Value<{ IntConstrainedValue }>,
    EquippingItems: Fusion.Value<{ StringValue }>,
}


return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope


    self.IsUIShown = Value(false)

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


    self.AvailableItems = Value(Vector2.zero)

    self.CurrentSelectedItem = Value("")
    self.CurrentSelectedItemUniqueId = Value("")
    self.CurrentCategory = Value("Accessory")

    self.Currency = {
        Gold = Value(0),
        Astra = Value(0)
    }


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

            self.FilterViewShown:set(false)
            self.IsUIShown:set(newPanel == "Backpack")
        end
    }))


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_Backpack",
        Size = 21,
        Parent = workspace.CurrentCamera,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)
    })
end