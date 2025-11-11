
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local Children = Fusion.Children


return function(scope: Fusion.Scope<any>, props: {
	LayoutOrder: number,
    OptionId: string,
    OptionTitle: string,

    BooleanValue: Fusion.Value<boolean>
})
	local isSelecting = Fusion.Value(scope, false)
    local isSelectingSwitcher = Fusion.Value(scope, false)


	return Components.Frame(scope, {
		Name = props.OptionId,
		Size = UDim2.fromScale(0.9, 0.08),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        LayoutOrder = props.LayoutOrder,

		[Children] = {
            Components.UIAspectRatioConstraint(scope, 26.688),

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

				[Fusion.OnEvent("MouseEnter")] = function()
					isSelectingSwitcher:set(true)
				end,
				[Fusion.OnEvent("MouseLeave")] = function()
					isSelectingSwitcher:set(false)
				end,
				[Fusion.OnEvent("MouseButton1Click")] = function()
					props.BooleanValue:set(not Fusion.peek(props.BooleanValue))

					Events.RequestToSaveSettings.Fire({
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

				BackgroundColor3 = Color3.fromRGB(255, 247, 233),

				Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
					return if use(props.BooleanValue) then UDim2.fromScale(0.92, 0.5) else UDim2.fromScale(0.87, 0.5)
				end), AssetBook.TweenInfos.twiceHalf),

				[Children] = {
					Components.RoundUICorner(scope)
				}
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
end