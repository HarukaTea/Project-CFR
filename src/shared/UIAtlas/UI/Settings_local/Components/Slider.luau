
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
	BarVal: Fusion.Value<number>,
	LayoutOrder: number,
	OptionInfo: {
		OptionTitle: string,
		Type: string,
		LayoutOrder: number,
		AllowDecimals: boolean,

		Min: number,
		Max: number,
		DefaultValue: number,

		ValChanged: BindableEvent
	},

    OptionId: string,
    OptionTitle: string,
})
	local isSelecting = Fusion.Value(scope, false)
	local barVal = props.BarVal

	local nodePosition = Fusion.Value(scope, UDim2.fromScale(1, 0.5))

	local uiDragDetector = nil
	uiDragDetector = Fusion.New(scope, "UIDragDetector")({
		ResponseStyle = Enum.UIDragDetectorResponseStyle.Scale,
		DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine,

		[Fusion.OnEvent("DragContinue")] = function()
			local scale = Fusion.peek(nodePosition).X.Scale
			local min = props.OptionInfo.Min
			local max = props.OptionInfo.Max

			scale = math.clamp(scale, 0, 1)

			local val = scale * (max - min) + min

			if props.OptionInfo.AllowDecimals then
				val = math.floor(val * 10 + 0.5) / 10
			else
				val = math.floor(val + 0.5)
			end

			barVal:set(val)
			props.OptionInfo.ValChanged:Fire(val)

			Events.SaveSettings_C.Fire({
				SettingId = props.OptionId,
				SettingValue = val
			})
		end
	}) :: UIDragDetector

	--// Init
	local percentage = ((props.OptionInfo.DefaultValue - props.OptionInfo.Min) / (props.OptionInfo.Max - props.OptionInfo.Min)) :: number

	barVal:set(props.OptionInfo.DefaultValue)
	props.OptionInfo.ValChanged:Fire(props.OptionInfo.DefaultValue)

	local node = Components.HoverImageButton(scope, {
		Name = "Node",
		BackgroundColor3 = Color3.fromRGB(209, 199, 189),
		BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1.3, 1.3),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Rotation = 45,

		[Fusion.Out("Position")] = nodePosition,

		[Children] = {
			Components.UICorner(scope, { CornerRadius = UDim.new(0.25, 0) }),
			Components.ScaledUIStroke(scope, {
				Color = Color3.new(),
				Thickness = 0.15
			}),

			uiDragDetector
		}
	})
	node.Position = UDim2.fromScale(percentage, 0.5)

	local safeNetObserver = Fusion.Observer(scope, nodePosition)
	safeNetObserver:onBind(function()
		local scale = Fusion.peek(nodePosition).X.Scale

		if scale < 0 or scale > 1 then
			scale = math.clamp(scale, 0, 1)
			node.Position = UDim2.fromScale(scale, 0.5)
		end
	end)

	local slider = Components.Frame(scope, {
		Name = props.OptionId,
		Size = UDim2.fromScale(0.9, 0.08),
        BackgroundTransparency = 0,
        LayoutOrder = props.LayoutOrder,

		[Children] = {
            Components.UIAspectRatioConstraint(scope, 29.548),

            Components.RoundUICorner(scope),
            Components.ScaledUIStroke(scope, {
                Thickness = 0.1,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
                    return use(isSelecting)
                end),
            }),

			Components.TextLabel(scope, {
				Name = "Title",
				Size = UDim2.fromScale(0.35, 1),
				Text = props.OptionTitle,
				TextXAlignment = Enum.TextXAlignment.Left,

				[Children] = {
					Components.UIPadding(scope, {
						PaddingTop = UDim.new(0.05, 0),
						PaddingBottom = UDim.new(0.05, 0)
					})
				}
			}),

			Components.TextLabel(scope, {
				Name = "Value",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.35, 0.5),
				Size = UDim2.fromScale(0.1, 1),
				TextXAlignment = Enum.TextXAlignment.Right,

				Text = Fusion.Computed(scope, function(use: Fusion.Use)
					return use(barVal)
				end),

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
				Name = "Slider",
				BackgroundTransparency = 0,
				BackgroundColor3 = Color3.fromRGB(55, 55, 55),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.47, 0.5),
				Size = UDim2.fromScale(0.5, 0.5),
				ZIndex = 10,

				[Children] = {
					Components.RoundUICorner(scope),

					Components.Frame(scope, {
						Name = "Bar",
						AnchorPoint = Vector2.zero,
						BackgroundTransparency = 0,
						BackgroundColor3 = Color3.fromRGB(255, 247, 233),
						Position = UDim2.fromScale(0, 0),

						Size = Fusion.Computed(scope, function(use: Fusion.Use)
							return UDim2.fromScale(use(nodePosition).X.Scale, 1)
						end),

						[Children] = {
							Components.RoundUICorner(scope)
						}
					}),

					node
				}
			}),

			Components.Frame(scope, {
				Name = "BoundingSlider",
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.45, 0.5),
				Size = UDim2.fromScale(0.54, 0.55),
				ZIndex = 5,
			}),

			Components.Frame(scope, {
                Name = "Hover",

				[Fusion.OnEvent("MouseEnter")] = function()
					isSelecting:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					isSelecting:set(false)
				end,
			})
		}
	})
	slider.Slider.Node.UIDragDetector.BoundingUI = slider.BoundingSlider

	return slider
end