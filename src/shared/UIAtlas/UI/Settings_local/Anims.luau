--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local wait = task.wait

return function (UI: ScreenGui, self: table)
    local scope = self.scope :: Fusion.Scope


    --// enter fx
    table.insert(scope, HarukaLib:Hydrate(UI, {
        ["Prop-Enabled"] = function(newState: boolean)
            if newState then
                HarukaLib:UITween(UI.Top, "In")
                HarukaLib:UITween(UI.Full, "In")
            end
        end
    }))
end
