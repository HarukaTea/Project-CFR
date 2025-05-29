--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaListLayout = require(RepS.HarukaShared.Shared.HarukaListLayout)

local wait = task.wait

return function (UI: ScreenGui, self: table)
    local scope = self.scope :: Fusion.Scope


    --// Hint AGL
    local animatedLayoutObj = HarukaListLayout.new(UI.Top.Hints.UIListLayout)
    animatedLayoutObj:Enable()

    table.insert(scope, animatedLayoutObj)
end
