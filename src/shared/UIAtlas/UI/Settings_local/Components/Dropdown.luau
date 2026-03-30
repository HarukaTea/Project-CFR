
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
	LayoutOrder: number,
    OptionId: string,
    OptionTitle: string,
    OptionDropdownOptions: { string },

    DropdownValue: Fusion.Value<string>
})
	local isSelecting = Fusion.Value(scope, false)
    local isSelectingDropdown = Fusion.Value(scope, false)

    local isSelectingDropdownList = Fusion.Value(scope, false)
    local totalListSize = Fusion.Value(scope, Vector2.zero)

	return Components.Frame(scope, {
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

            Components.Frame(scope, {
                Name = "DropdownButton",
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.fromScale(0.22, 1),
                BackgroundColor3 = Color3.new(),
                BackgroundTransparency = 0,

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.HoverImageButton(scope, {
                        ZIndex = 10,

                        Components.ConnectSelectEvents(isSelectingDropdown),

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            isSelectingDropdownList:set(not Fusion.peek(isSelectingDropdownList))
                        end
                    }),

                    Components.ScaledUIStroke(scope, {
                        Thickness = 0.08,

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
                        Image = "rbxassetid://125510901687900",

                        Rotation = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return if use(isSelectingDropdownList) then 0 else -180
                        end)
                    }),

                    Components.TextLabel(scope, {
                        Name = "ButtonText",
                        Position = UDim2.fromScale(0.1, 0),
                        Size = UDim2.fromScale(0.7, 1),

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(props.DropdownValue)
                        end),

                        [Children] = {
                            Components.UIPadding(scope, {})
                        }
                    })
                }
            }),

			Components.Frame(scope, {
                Name = "DropdownList",
                AnchorPoint = Vector2.xAxis,
                Position = UDim2.fromScale(1, 1.5),
                Size = UDim2.fromScale(0.235, 1),

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelectingDropdownList)
                end),

                [Children] = {
                    Components.Frame(scope, {
                        Name = "Main",
                        ZIndex = 2,

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.15, 0),
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                SortOrder = Enum.SortOrder.Name,

                                [Fusion.Out("AbsoluteContentSize")] = totalListSize
                            }),

                            Components.PaddingFrame(scope, "AAA"),
                            Components.PaddingFrame(scope, "ZZZ"),

                            Fusion.ForPairs(scope, props.OptionDropdownOptions, function(_, scope: Fusion.Scope, index: number, option: string)
                                local isHovering = Fusion.Value(scope, false)

                                return index, Components.TextButton(scope, {
                                    Name = option,
                                    Text = option,
                                    Size = UDim2.fromScale(0.9, 1),

                                    BackgroundTransparency = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        local curChosen = use(props.DropdownValue) :: string
                                        if curChosen == option then
                                            return 0
                                        end
                                        if use(isHovering) then
                                            return 0
                                        end

                                        return 1
                                    end),
                                    BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        local curChosen = use(props.DropdownValue) :: string
                                        if curChosen == option then
                                            return Components.WHITE_COLOR
                                        end

                                        if use(isHovering) then
                                            return Components.WHITE_COLOR
                                        end

                                        return Components.BLACK_COLOR
                                    end),
                                    TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        local curChosen = use(props.DropdownValue) :: string
                                        if curChosen == option then
                                            return Components.BLACK_COLOR
                                        end

                                        if use(isHovering) then
                                            return Components.BLACK_COLOR
                                        end

                                        return Components.WHITE_COLOR
                                    end),

                                    Components.ConnectSelectEvents(isHovering),

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        props.DropdownValue:set(option)
                                        isSelectingDropdownList:set(false)

                                        Events.SaveSettings_C.Fire({
                                            SettingId = props.OptionId,
                                            SettingValue = option
                                        })
                                    end,

                                    [Children] = {
                                        Components.RoundUICorner(scope),
                                        Components.UIPadding(scope, {})
                                    }
                                })
                            end)
                        }
                    }),

                    Components.Frame(scope, {
                        Name = "Background",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0, 0),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Color3.fromRGB(),

                        Size = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return UDim2.new(1, 0, 0, use(totalListSize).Y)
                        end),

                        [Children] = {
                            Components.UICorner(scope, {
                                CornerRadius = UDim.new(0.2, 0)
                            })
                        }
                    })
                }
			}),

			Components.Frame(scope, {
                Name = "Hover",

				Components.ConnectSelectEvents(isSelecting),
			})
		}
	})
end