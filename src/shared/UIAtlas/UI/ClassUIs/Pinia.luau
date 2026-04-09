
local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope,
    UI: ScreenGui,

    IsUIShown: Fusion.Value<boolean>,
    IsUIShown2: Fusion.Value<boolean>,

    IsInCombat: Fusion.Value<boolean>,
    Class: Fusion.Value<string>,


    ChainCombo: Fusion.Value<number>,
}




return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(true)

    self.Class = Value("Chain")
    self.IsInCombat = Value(false)



    self.ChainCombo = Value(0)


    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "None")
        end
    }))

    self.IsUIShown2 = Value(true)

    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-HideUIFactor"] = function(state: boolean)
            state = state or false

            self.IsUIShown2:set(not state)
        end
    }))


    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-Class"] = function(val: string)
            val = val or "Burst"

            self.Class:set(val)
        end
    }))
    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-IsInCombat"] = function(state: boolean)
            state = state or false

            self.IsInCombat:set(state)
        end
    }))


    --// track class vals
    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-ChainCombo"] = function(val: number)
            val = val or 0

            self.ChainCombo:set(val)
        end
    }))
end