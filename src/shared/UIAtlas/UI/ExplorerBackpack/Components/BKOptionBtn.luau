--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Option: string,
    Index: number
}, self: table)

    local isSelecting = Fusion.Value(scope, false)

    local ICONS = {
        Filter = "rbxassetid://88154353103061"
    }

    return Components.Frame(scope, {
        Name = props.Option,
        Size = UDim2.fromScale(0.85, 0.85),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        BackgroundTransparency = 0,
        LayoutOrder = props.Index,

        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return if use(isSelecting) then Components.WHITE_COLOR else Components.BLACK_COLOR
        end),

        [Children] = {
            Components.RoundUICorner(scope),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if props.Option == "Filter" then
                        self.FilterViewShown:set(not Fusion.peek(self.FilterViewShown))
                    end
                end
            }),

            Components.ImageLabel(scope, {
                Name = "Icon",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.6, 0.6),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                Image = ICONS[props.Option],

                ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(isSelecting) then Components.BLACK_COLOR else Components.WHITE_COLOR
                end),
            })
        }
    })
end
