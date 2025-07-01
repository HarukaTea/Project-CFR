--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local PerkBook = require(RepS.HarukaShared.Library.PerkBook)

local wait = task.wait

return function (self: { any })
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(false)

    self.CurrentCategory = Value("STR")
    self.CurrentSelectedPerk = Value(nil)

    self.Points = {
        STR = Value(0),
        INT = Value(0),
        VIT = Value(0),
    }


    --// track points
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-STRPoints"] = function(val: number)
            self.Points.STR:set(val)
        end,
        ["Attr-INTPoints"] = function(val: number)
            self.Points.INT:set(val)
        end,
        ["Attr-VITPoints"] = function(val: number)
            self.Points.VIT:set(val)
        end
    }))


    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "PerkTree")
        end
    }))


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_PerkTree",
        Size = 21,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)
    })
    blur.Parent = workspace.CurrentCamera
end
