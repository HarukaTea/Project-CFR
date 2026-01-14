
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    FilterTierList: { Fusion.Value<boolean> },
    FilterItemText: Fusion.Value<string>,
    SortMethodList: { Fusion.Value<boolean> },

    UIOpenState: Fusion.Value<boolean>,
})

    local isSelecting = Fusion.Value(scope, false)

    local function Title(text: string, order: number)
        return Fusion.Hydrate(scope, Components:RefUI("TitleTemplate_Filter1_1", true))({
            Name = text.."Title",
            LayoutOrder = order,
            Text = text,
        })
    end

    return {
        Fusion.Hydrate(scope, Components:RefUI("Inner_Filter1_1", false, true, {
            "PaddingAAA"
        }))({
            [Children] = {
                Fusion.Hydrate(scope, Components:RefUI("SearchTitle_Filter1_1", false, true))({
                    [Children] = {
                        Fusion.Hydrate(scope, Components:RefUI("Close_Filter1_1"))({
                            [Children] = {
                                Fusion.Hydrate(scope, Components:RefUI("Icon_FilterClose1_1"))({
                                    ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return if use(isSelecting) then Color3.fromRGB(255, 255, 0) else Color3.new(1, 1, 1)
                                    end)
                                }),

                                Components.HoverImageButton(scope, {
                                    Components.ConnectSelectEvents(isSelecting),

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        props.UIOpenState:set(false)
                                    end
                                })
                            }
                        })
                    }
                }),

                Title("Includes", 4),
                Title("Sort Order", 6),

                Fusion.Hydrate(scope, Components:RefUI("SearchBox_Filter1_1", true))({
                    Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                        return use(props.FilterItemText)
                    end),
                    [Fusion.Out("Text")] = props.FilterItemText,
                }),

                Components.ScrollingFrame(scope, {
                    Name = "Includes",
                    Size = UDim2.fromScale(0.95, 0.2),
                    LayoutOrder = 5,

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 3.408),

                        Components.PaddingFrame(scope, "AAA"),
                        Components.PaddingFrame(scope, "ZZZ"),

                        Fusion.ForPairs(scope, {"I", "III", "V"}, function(_, scope: Fusion.Scope, index: number, tier: string)
                            local isSelecting = Fusion.Value(scope, false)

                            return index, Fusion.Hydrate(scope, Components:RefUI("TierTemplate_Filter1_1", false, true))({
                                Name = "Tier"..index,

                                Text = "Tier "..tier.."+",
                                LayoutOrder = index,

                                BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.FilterTierList[index]) then Components.WHITE_COLOR else Components.GREY_COLOR
                                end),
                                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.FilterTierList[index]) then Components.GREY_COLOR else Components.WHITE_COLOR
                                end),

                                Components.ConnectSelectEvents(isSelecting),

                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    props.FilterTierList[index]:set(not Fusion.peek(props.FilterTierList[index]))
                                end,

                                [Children] = {
                                    Fusion.Hydrate(scope, Components:RefUI("IsSelected_TierFilter1_1", false, true))({
                                        BackgroundTransparency = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return if use(props.FilterTierList[index]) then 0 else 1
                                        end),

                                        [Children] = {
                                            Fusion.Hydrate(scope, Components:RefUI("SelectedIcon_TierFilter1_1"))({
                                                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                    return use(props.FilterTierList[index])
                                                end)
                                            })
                                        }
                                    })
                                }
                            })
                        end)
                    }
                }, {
                    Padding = UDim.new(0, 6),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                }),

                Components.ScrollingFrame(scope, {
                    Name = "SortOrders",
                    Size = UDim2.fromScale(0.95, 0.2),
                    LayoutOrder = 7,

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 3.408),

                        Components.PaddingFrame(scope, "AAA"),
                        Components.PaddingFrame(scope, "ZZZ"),

                        Fusion.ForPairs(scope, {"T5", "T1"}, function(_, scope: Fusion.Scope, index: number, sortMethod: string)
                            local isSelecting = Fusion.Value(scope, false)

                            local TEXTS = {
                                T5 = "Sort By Tier (V-I)",
                                T1 = "Sort By Tier (I-V)",
                            }

                            return index, Fusion.Hydrate(scope, Components:RefUI("SortMethodTemplate_SortFilter1_1", false, true))({
                                Name = "SortMethod"..index,

                                Text = TEXTS[sortMethod],
                                LayoutOrder = index,

                                BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.SortMethodList[index]) then Components.WHITE_COLOR else Components.GREY_COLOR
                                end),
                                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return if use(props.SortMethodList[index]) then Components.GREY_COLOR else Components.WHITE_COLOR
                                end),

                                Components.ConnectSelectEvents(isSelecting),

                                [Fusion.OnEvent("MouseButton1Click")] = function()
                                    for _, val in props.SortMethodList do
                                        val:set(false)
                                    end
                                    props.SortMethodList[index]:set(true)
                                end,

                                [Children] = {
                                    Fusion.Hydrate(scope, Components:RefUI("IsSelected_TierFilter1_1", false, true))({
                                        BackgroundTransparency = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return if use(props.SortMethodList[index]) then 0 else 1
                                        end),

                                        [Children] = {
                                            Fusion.Hydrate(scope, Components:RefUI("SelectedIcon_TierFilter1_1"))({
                                                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                    return use(props.SortMethodList[index])
                                                end)
                                            })
                                        }
                                    })
                                }
                            })
                        end)
                    }
                }, {
                    Padding = UDim.new(0, 6),
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                }),
            }
        }),

        Fusion.Hydrate(scope, Components:RefUI("BottomBtns_Filter1_1", false, true))({
            [Children] = {
                ExecuteButton(scope, {
                    Size = UDim2.fromScale(0.45, 1),
                    ButtonText = "Reset",
                    ButtonType = "Cancel",
                    LayoutOrder = 1,
                    ButtonClickFunc = function()
                        for _, tierStatus in props.FilterTierList do
                            tierStatus:set(true)
                        end
                        props.FilterItemText:set("")
                    end
                }),
                ExecuteButton(scope, {
                    Size = UDim2.fromScale(0.45, 1),
                    ButtonText = "Confirm",
                    ButtonType = "Confirm",
                    LayoutOrder = 2,
                    ButtonClickFunc = function()
                        props.UIOpenState:set(false)
                    end
                })
            }
        }),
    }
end