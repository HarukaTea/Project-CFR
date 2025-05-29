--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaListLayout = require(RepS.HarukaShared.Shared.HarukaListLayout)

local wait = task.wait

return function (UI: ScreenGui, self: table)
    local scope = self.scope :: Fusion.Scope


    --// Prompt AGL
    local animatedLayoutObj = HarukaListLayout.new(UI.Center.Prompts.UIListLayout)
    animatedLayoutObj:Enable()

    table.insert(scope, animatedLayoutObj)
end
