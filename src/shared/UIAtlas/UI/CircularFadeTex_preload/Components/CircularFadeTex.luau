
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
            Components.ImageLabel(scope, {
                Name = "Circle",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(3, 3),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Image = "rbxassetid://72813522573875",

                [Children] = {
                    Components.UIStroke(scope, {
                        Thickness = 99999,
                        Color = Color3.fromRGB(),

                        [Fusion.Attribute("IgnoreDPI")] = true
                    })
                }
            })
        }
    })
end