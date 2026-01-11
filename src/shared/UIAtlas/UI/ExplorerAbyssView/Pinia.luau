
local RepS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local AbyssBook = require(RepS.HarukaShared.Library.AbyssBook)

export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,
    UI: ScreenGui,

    IsUIShown: Fusion.Value<boolean>,
    AbyssIndexSelected: Fusion.Value<number>,

    AbyssRanks: Fusion.Value<{ IntValue }>,
    ModifierChosen: { [string]: Fusion.Value<boolean> },

    ItemListAbsSize: Fusion.Value<Vector2>,
    SortMethodList: { Fusion.Value<boolean> },

    CurrentSelectedItem: Fusion.Value<string>,
    CurrentSelectedItemUniqueId: Fusion.Value<string>,

    Items: Fusion.Value<{ IntConstrainedValue }>
}

return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(false)

    self.AbyssIndexSelected = Fusion.Value(scope, nil)

    self.Items = Value({})

    local ranks = Components.FusionComponents.useChildren(scope, workspace.MapComponents:WaitForChild("AbyssSpeedrunContainer", 999))
    self.AbyssRanks = ranks :: Fusion.Value<{ IntValue }>

    self.ModifierChosen = {}
    for _, modifier: string in AbyssBook.Modifiers do
        self.ModifierChosen[modifier] = Value(scope, false)
    end

    self.ItemListAbsSize = Value(Vector2.zero)

    self.SortMethodList = {

    }
    for _ = 1, 2 do
        table.insert(self.SortMethodList, Value(false))
    end
    self.SortMethodList[1]:set(true)

    self.CurrentSelectedItem = Value("")
    self.CurrentSelectedItemUniqueId = Value("")

    local dawnbreakSymbol = Instance.new("IntConstrainedValue")
    dawnbreakSymbol.Name = "Dawnbreak"
    dawnbreakSymbol.Value = 1
    for index: number, _ in AbyssBook.Loots do
        dawnbreakSymbol:AddTag("AbyssLootsEntity"..index)
    end
    dawnbreakSymbol:SetAttribute("HarukaUniqueId", HttpService:GenerateGUID(false))
    dawnbreakSymbol.Parent = workspace.MapComponents.AbyssLootsContainer
    table.insert(scope, dawnbreakSymbol)

    Fusion.Observer(scope, self.AbyssIndexSelected):onBind(function()
        for _, modifier: string in AbyssBook.Modifiers do
            self.ModifierChosen[modifier]:set(false)
        end

        local index = Fusion.peek(self.AbyssIndexSelected)
        if index == nil then
            self.Items:set({})
            return
        end

        self.Items:set(CollectionService:GetTagged("AbyssLootsEntity"..index))
    end)

    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "AbyssView")
        end
    }))

    table.insert(scope, Events.OpenAbyssUI_S.On(function()
        self.plr:SetAttribute("CurrentUIGroup", "AbyssView")
    end))

    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_AbyssView",
        Size = 21,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)
    })
    blur.Parent = workspace.CurrentCamera
end