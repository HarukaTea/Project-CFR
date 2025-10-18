--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local AbyssTeambook = require(RepS.HarukaShared.Library.AbyssTeambook)

local wait = task.wait

return function (self: { any })
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(false)

    self.AbyssIndexSelected = Value(nil)
    self.AbyssInfo = Value({})


    --// track abyss index selected
    Fusion.Observer(scope, self.AbyssIndexSelected):onBind(function()
        local index = Fusion.peek(self.AbyssIndexSelected)
        if index == nil then self.AbyssInfo:set({}) return end
        if not AbyssTeambook[index] then self.AbyssInfo:set({}) return end

        self.AbyssInfo:set(AbyssTeambook[index].Team)
    end)


    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "AbyssView")
        end
    }))


    table.insert(scope, Events.OpenAbyssUI.On(function()
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