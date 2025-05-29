--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


return function (self: table)
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope


    self.IsBackpackShown = Value(false)

    self.FilterViewShown = Value(false)
    self.FilterTierList = {

    }
    self.FilterItemText = Value("")
    for _ = 1, 5 do
        table.insert(self.FilterTierList, Value(true))
    end

    self.AvailableItems = Value(Vector2.zero)
    self.ItemShownSlotsLimit = Value(100)

    self.CurrentSelectedItem = Value("")
    self.CurrentSelectedItemUniqueId = Value("")
    self.CurrentCategory = Value("Accessory")

    self.Currency = {
        Gold = Value(0),
        Astra = Value(0)
    }


    self.ItemListAbsSize = Value(Vector2.zero)

    self.Items = FusionComponents.useFolder(scope, self.plr.Items)
    self.EquippingItems = FusionComponents.useFolder(scope, self.plr.EquippingItems)



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

            self.ItemShownSlotsLimit:set(100)
            self.IsBackpackShown:set(newPanel == "Backpack")
        end
    }))


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_Backpack",
        Size = 21,
        Parent = workspace.CurrentCamera,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsBackpackShown)
        end)
    })
end
