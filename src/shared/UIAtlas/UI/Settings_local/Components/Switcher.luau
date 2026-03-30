
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
	LayoutOrder: number,
    OptionId: string,
    OptionTitle: string,

    BooleanValue: Fusion.Value<boolean>
})
	local isSelecting = Fusion.Value(scope, false)
    local isSelectingSwitcher = Fusion.Value(scope, false)

	return Fusion.Hydrate(scope, Components:RefUI("SwitcherT_Settings1_2", false, false, {
		"UIAspectRatioConstraint", "UICorner"
	}))({
		Name = props.OptionId,
        LayoutOrder = props.LayoutOrder,

		[Children] = {
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
				Position = UDim2.fromScale(0.81, 0.5),
				Size = UDim2.fromScale(0.05, 1),

				Text = Fusion.Computed(scope, function(use: Fusion.Use)
					return if use(props.BooleanValue) then "ON" else "OFF"
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

			Components.HoverImageButton(scope, {
				Name = "Switcher",
				BackgroundColor3 = Color3.fromRGB(55, 55, 55),
				BackgroundTransparency = 0,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.87, 0.5),
				Size = UDim2.fromScale(0.1, 0.8),

				Components.ConnectSelectEvents(isSelectingSwitcher),

				[Fusion.OnEvent("MouseButton1Click")] = function()
					props.BooleanValue:set(not Fusion.peek(props.BooleanValue))

					Events.SaveSettings_C.Fire({
						SettingId = props.OptionId,
						SettingValue = Fusion.peek(props.BooleanValue)
					})
				end,

				[Children] = {
					Components.RoundUICorner(scope),
					Components.ScaledUIStroke(scope, {
						Thickness = 0.1,

						Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
							return use(isSelectingSwitcher)
						end)
					})
				}
			}),
			Components.Frame(scope, {
				Name = "Switch",
				BackgroundTransparency = 0,
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.fromScale(0.05, 0.8),

				Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
					return if use(props.BooleanValue) then UDim2.fromScale(0.92, 0.5) else UDim2.fromScale(0.87, 0.5)
				end), Components.TweenInfos.twiceHalf),

				BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
					return if use(props.BooleanValue) then Components.WHITE_COLOR else Components.WHITE_COLOR:Lerp(Color3.fromRGB(), 0.5)
				end),

				[Children] = {
					Components.RoundUICorner(scope)
				}
			}),

			Components.Frame(scope, {
                Name = "Hover",

				Components.ConnectSelectEvents(isSelecting),
			})
		}
	})
end