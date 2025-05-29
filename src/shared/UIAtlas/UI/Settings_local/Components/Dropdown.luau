--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children


return function(scope: Fusion.Scope, props: {
	LayoutOrder: number,
    OptionId: string,
    OptionTitle: string,


})
	local isSelecting = Fusion.Value(scope, false)
    local isSelectingDropdown = Fusion.Value(scope, false)



	return Components.Frame(scope, {
		Name = props.OptionId,
		Size = UDim2.fromScale(1, 0.08),
		LayoutOrder = props.LayoutOrder,

		[Children] = {
			Components.Frame(scope, {
				Name = "FakeBGOverlay",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(-0.02, 0.5),
				Size = UDim2.fromScale(0.935, 1.2),
				BackgroundTransparency = 0,
				BackgroundColor3 = Components.BLACK_COLOR,
				ZIndex = 0,

				[Children] = {
					Components.RoundUICorner(scope),
					Components.UIStroke(scope, {
						Thickness = 2,

						Transparency = Fusion.Computed(scope, function(use: Fusion.Use)
							return if use(isSelecting) then 0 else 1
						end)
					})
				}
			}),

			Components.TextLabel(scope, {
				Name = "Title",
				Size = UDim2.fromScale(0.3, 1),
				Text = props.OptionTitle,
				TextXAlignment = Enum.TextXAlignment.Left,

				[Children] = {
					Components.UIPadding(scope, {
						PaddingTop = UDim.new(0.05, 0),
						PaddingBottom = UDim.new(0.05, 0),
						PaddingLeft = UDim.new(),
						PaddingRight = UDim.new()
					})
				}
			}),


            Components.Frame(scope, {
                Name = "DropdownButton",
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.7, 0.5),
                Size = UDim2.fromScale(0.22, 1.2),

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.HoverImageButton(scope, {
                        [Fusion.OnEvent("MouseEnter")] = function()
                            isSelectingDropdown:set(true)
                        end,
                        [Fusion.OnEvent("MouseLeave")] = function()
                            isSelectingDropdown:set(false)
                        end,

                        [Fusion.OnEvent("MouseButton1Click")] = function()

                        end
                    }),

                    Components.UIStroke(scope, {
                        Thickness = 2.5,

                        Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
                            return use(isSelectingDropdown)
                        end)
                    }),

                    Components.ImageLabel(scope, {
                        Name = "Triangle",
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromScale(0.86, 0.55),
                        Size = UDim2.fromScale(0.4, 0.4),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        Rotation = -180,
                        Image = "rbxassetid://125510901687900"
                    }),

                    Components.TextLabel(scope, {
                        Name = "ButtonText",
                        Position = UDim2.fromScale(0.1, 0),
                        Size = UDim2.fromScale(0.7, 1),

                        Text = "?",

                        [Children] = {
                            Components.UIPadding(scope, {})
                        }
                    })
                }
            }),


			Components.Frame(scope, {

			}),




			Components.HoverImageButton(scope, {
				AnchorPoint = Vector2.zero,
				Position = UDim2.fromScale(-0.02, 0),
				Size = UDim2.fromScale(0.935, 1),


				[Fusion.OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
			})
		}
	})
end
