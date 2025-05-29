--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaListLayout = require(RepS.HarukaShared.Shared.HarukaListLayout)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local wait = task.wait

return function (UI: ScreenGui, self: table)
    local scope = self.scope :: Fusion.Scope


    --// Prompt AGL
    local animatedLayoutObj = HarukaListLayout.new(UI.Center.Quests.UIListLayout)
    animatedLayoutObj:Enable()

    table.insert(scope, animatedLayoutObj)


    --// enter fx
    table.insert(scope, HarukaLib:Hydrate(UI, {
        ["Prop-Enabled"] = function(newState: boolean)
            if newState then
                HarukaLib:UITween(UI, "In")
            end
        end
    }))
end
