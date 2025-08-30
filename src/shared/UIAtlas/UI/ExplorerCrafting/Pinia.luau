--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local Events = require(RepS.HarukaShared.Library.Events)

local wait = task.wait

return function (self: { any })
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(false)

    self.Items = FusionComponents.useTagged(scope, "CraftingProductEntity")
    self.PlayerItems = FusionComponents.useFolder(scope, self.plr:WaitForChild("Items", 999))
    self.EquippingItems = FusionComponents.useFolder(scope, self.plr:WaitForChild("EquippingItems", 999))

    self.Gold = Value(0)


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
    self.SortMethodList[1]:set(true)


    self.CurrentSelectedItem = Value("")
    self.CurrentSelectedItemUniqueId = Value("")
    self.CurrentCategory = Value("Crafting")

    self.CraftingMaterials = Value({})
    self.CraftingPrice = Value(0)
    self.ItemListAbsSize = Value(Vector2.zero)



    --// track item
    Fusion.Observer(scope, self.CurrentSelectedItem):onBind(function()
        self.CraftingMaterials:set({})
        self.CraftingPrice:set(0)

        local item = Fusion.peek(self.CurrentSelectedItem) :: string
        local itemInfo = ItemBook:GetItemInfo(item)
        if itemInfo == nil then return end

        self.CraftingMaterials:set(itemInfo.RecipeDesync)
        self.CraftingPrice:set(itemInfo.Price)
    end)


    --// track gold
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-Gold"] = function(val: number)
            self.Gold:set(val)
        end
    }))


    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "Crafting")
            self.FilterViewShown:set(false)
        end
    }))
    table.insert(scope, Events.OpenCraftingUI.On(function(data)
        self.plr:SetAttribute("CurrentUIGroup", "Crafting")

        HarukaLib:FreezePlayerControls("Freeze")
    end))


    table.insert(scope, function()
        HarukaLib:FreezePlayerControls("Unfreeze")
    end)


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_Crafting",
        Size = 21,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)
    })
    blur.Parent = workspace.CurrentCamera
end
