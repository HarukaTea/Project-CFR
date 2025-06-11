--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


return function (self: table)
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.Enemies = FusionComponents.useTagged(scope, "EnemyEntity_Combat")
    self.EnemiesOverworld = FusionComponents.useTagged(scope, "EnemyEntity")

    self.TargetingList = FusionComponents.useFolder(scope, self.char:WaitForChild("TargetingList"))



    self.IsUIShown2 = Value(true)

    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-HideUIFactor"] = function(state: boolean)
            state = state or false

            self.IsUIShown2:set(not state)
        end
    }))
end
