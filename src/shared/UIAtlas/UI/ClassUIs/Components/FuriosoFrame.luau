
local RepS = game:GetService("ReplicatedStorage")


local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local Pinia = require(script.Parent.Parent.Pinia)


return function(scope: Fusion.Scope, self: Pinia.Self)
    return Components.Frame(scope, {
        Name = "FuriosoStyle",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, -1.7),
        Size = UDim2.fromScale(0.9, 1),


        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(self.Class) == "Furioso" and use(self.IsInCombat)
        end),


        [Children] = {
            Components.UIListLayout(scope, {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0.01, 0)
            }),


        }
    })
end