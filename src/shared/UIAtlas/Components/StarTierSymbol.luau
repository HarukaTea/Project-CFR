--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Size: UDim2?
})
    props = props or {}

    return Components.Frame(scope, {
        Name = "Star",
        Size = props.Size or UDim2.fromScale(1, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,

        [Children] = {
            Components.ImageLabel(scope, {
                Name = "Star",
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Image = "rbxassetid://114302766654339",
                Rotation = 8,
                ImageColor3 = Color3.fromRGB(255, 204, 50)
            })
        }
    })
end
