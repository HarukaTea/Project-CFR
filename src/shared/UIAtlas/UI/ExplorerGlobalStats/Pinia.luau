--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local wait = task.wait

return function (self: { any })
    local function Value(val: any) : Fusion.Value
        return Fusion.Value(self.scope, val)
    end
    local scope = self.scope :: Fusion.Scope

    self.IsUIShown = Value(true)
    self.IsUIShown2 = Value(true)

    table.insert(scope, HarukaLib:Hydrate(workspace, {
        ["Attr-HideUIFactor"] = function(state: boolean)
            state = state or false

            self.IsUIShown2:set(not state)
        end
    }))
end