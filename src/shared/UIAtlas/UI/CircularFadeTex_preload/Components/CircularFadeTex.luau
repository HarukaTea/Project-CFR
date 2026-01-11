
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local Children = Fusion.Children

return function (scope: Fusion.Scope)
    return Components.HarukaScreenGui(scope, {
        Name = "CircularFadeTex",
        ScreenInsets = Enum.ScreenInsets.None,
        DisplayOrder = UIPriorityBook.Highest,

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("CircleTex_1", true))({
                Name = "Circle"
            })
        }
    })
end