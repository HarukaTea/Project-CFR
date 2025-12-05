
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local AbyssBook = require(RepS.HarukaShared.Library.AbyssBook)


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,

    IsUIShown: Fusion.Value<boolean>,
    AbyssIndexSelected: Fusion.Value<number>,

    AbyssRanks: Fusion.Value<{ IntValue }>,

    AbyssModifierList: Fusion.Value<{ string }>,
}



return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(false)

    self.AbyssIndexSelected = Fusion.Value(scope, nil)


    local ranks = Components.FusionComponents.useChildren(scope, workspace.MapComponents:WaitForChild("AbyssSpeedrunContainer", 999))
    self.AbyssRanks = ranks :: Fusion.Value<{ IntValue }>


    self.AbyssModifierList = Value({})

    --// track abyss index selected
    Fusion.Observer(scope, self.AbyssIndexSelected):onBind(function()
        local index = Fusion.peek(self.AbyssIndexSelected) or 0
        if index == 0 then self.AbyssModifierList:set({}) return end


        self.AbyssModifierList:set(HarukaLib.TableUtils.Cut(AbyssBook.Modifiers, index))
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