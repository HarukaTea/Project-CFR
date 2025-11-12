
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local wait = task.wait



export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope<any>,

    IsUIShown: Fusion.Value<boolean>,
    CurrentCategory: Fusion.Value<string>,
    DonationRanks: Fusion.Value<{ IntValue }>,

    PanelSelected: Fusion.Value<string>,

    PanelList: { string },
}



return function (self: Self)
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope<any>

    self.IsUIShown = Value(false)


    self.CurrentCategory = Value("Donation")
    self.PanelSelected = Value("Featured")

    self.PanelList = { "Donation #1", "Donation #2" }


    local ranks = Components.FusionComponents.useChildren(scope, workspace.MapComponents:WaitForChild("DonationRankContainer", 999))
    self.DonationRanks = ranks :: Fusion.Value<{ IntValue }>


    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "Donation")

            if newPanel == "Donation" then
                if game.PlaceId ~= AssetBook.PlaceIds["7037847546"].Mainworld then
                    Bindables.CloseExplorerUIs:Fire()
                    Bindables.CreateNotify:Fire("You can't donate in test place!")
                end
            end
        end
    }))


    --// track ui blur
    local blur = Components.BlurFS(scope, {
        Name = "UIBlur_Donation",
        Size = 21,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.IsUIShown)
        end)
    })
    blur.Parent = workspace.CurrentCamera
end