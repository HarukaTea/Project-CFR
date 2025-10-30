
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local wait = task.wait



export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope<any>,

    IsUIShown: Fusion.Value<boolean>,
    CurrentCategory: Fusion.Value<string>,
    DonationRanks: Fusion.Value<{ IntValue }>,
}



return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope<any>

    self.IsUIShown = Value(false)


    self.CurrentCategory = Value("RoStore")


    local ranks = FusionComponents.useFolder(scope, workspace:WaitForChild("DonationRankContainer", 999))
    self.DonationRanks = ranks :: Fusion.Value<{ IntValue }>


    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "Store")
        end
    }))


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_RoStore",
        Size = 21,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)
    })
    blur.Parent = workspace.CurrentCamera
end