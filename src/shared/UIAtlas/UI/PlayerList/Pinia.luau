--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local wait = task.wait


return function (self: table)
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope


    self.Players = FusionComponents.useTagged(scope, "PlayerEntity")
    self.Characters = FusionComponents.useTagged(scope, "PlayerCharEntity")

    self.IsUIShown = Value(true)
    self.IsUIFolded = Value(false)

    self.PlayerSelecting = Value(nil)




    --// track menu
    table.insert(scope, HarukaLib:Hydrate(self.plr, {
        ["Attr-CurrentUIGroup"] = function(newPanel: string)
            if newPanel == nil then return end

            self.IsUIShown:set(newPanel == "None")
        end
    }))


    --// track tab input
    table.insert(scope, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        if input.KeyCode == Enum.KeyCode.Tab then
            self.IsUIFolded:set(not Fusion.peek(self.IsUIFolded))
        end
    end))
end
