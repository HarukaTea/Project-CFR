
--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local HarukaListLayout = require(RepS.HarukaShared.Shared.HarukaListLayout)

local wait = task.wait


return function (UI: ScreenGui, self: table)
    local scope = self.scope :: Fusion.Scope
    local top = UI.Top :: Frame


    --// targeting AGL
    local targetingAGLObj = HarukaListLayout.new(UI.Center.TargetingListDiv.TargetingList.UIListLayout)
    targetingAGLObj:Enable()

    table.insert(scope, targetingAGLObj)
end
