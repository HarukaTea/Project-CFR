
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local Children = Fusion.Children


--- we dont need `RefUI` here
return function (scope: Fusion.Scope)
    return Components.HarukaScreenGui(scope, {
        Name = "GotHitShade",
        DisplayOrder = UIPriorityBook.System - 1,

        [Children] = {
            Components.Frame(scope, {
                Name = "Shade_LR",
                BackgroundTransparency = 0,
                BackgroundColor3 = Color3.fromHex('#d63031'),

                [Children] = {
                    Components.UIGradient(scope, {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.5),
                            NumberSequenceKeypoint.new(0.3, 1),
                            NumberSequenceKeypoint.new(0.7, 1),
                            NumberSequenceKeypoint.new(1, 0.5)
                        })
                    })
                }
            }),
            Components.Frame(scope, {
                Name = "Shade_TB",
                BackgroundTransparency = 0,
                BackgroundColor3 = Color3.fromHex('#ff4757'),

                [Children] = {
                    Components.UIGradient(scope, {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.5),
                            NumberSequenceKeypoint.new(0.25, 1),
                            NumberSequenceKeypoint.new(0.75, 1),
                            NumberSequenceKeypoint.new(1, 0.5)
                        }),

                        Rotation = 90
                    })
                }
            })
        }
    })
end