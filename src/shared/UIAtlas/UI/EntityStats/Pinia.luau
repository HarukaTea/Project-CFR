--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)


return function (self: table)
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.Enemies = FusionComponents.useTagged(scope, "EnemyEntity_Combat")
    self.EnemiesOverworld = FusionComponents.useTagged(scope, "EnemyEntity")

    self.TargetingList = FusionComponents.useFolder(scope, self.char:WaitForChild("TargetingList"))
end
