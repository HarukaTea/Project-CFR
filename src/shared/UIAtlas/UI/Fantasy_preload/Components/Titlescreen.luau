
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

local wait = task.wait

return function (scope: Fusion.Scope<any>, props: {
    SlotUISignal: RBXScriptSignal,
    CutsceneUISignal: RBXScriptSignal
}) : ScreenGui

    local ICONS = {
        Play = "rbxassetid://124997253539716",
        Credits = "rbxassetid://76184661737952",
        Tutorial = "rbxassetid://70702384179449"
    }

    local isShown = Fusion.Value(scope, true)

    table.insert(scope, props.CutsceneUISignal:Connect(function()
        isShown:set(true)
    end))
    table.insert(scope, props.SlotUISignal:Connect(function()
        isShown:set(false)
    end))


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "OuterTitlescreen",
        DisplayOrder = 233,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
            return use(isShown)
        end),

    }, {
        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "SidePanel",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.fromScale(0.5, -1),
                    Size = UDim2.fromScale(0.95, 1),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            VerticalAlignment = Enum.VerticalAlignment.Bottom,
                            Padding = UDim.new(0.5, 0)
                        }),

                        Fusion.ForPairs(scope, { "Play" }, function(_, scope: Fusion.Scope<any>, index: number, panelId: string)
                            local isSelecting = Fusion.Value(scope, false)

                            return index, Components.Frame(scope, {
                                Name = panelId,
                                Size = UDim2.fromScale(0.2, 0.7),
                                BackgroundTransparency = 0,
                                LayoutOrder = index,

                                BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                                    return if use(isSelecting) then Components.WHITE_COLOR else Components.BLACK_COLOR
                                end),

                                [Children] = {
                                    Components.RoundUICorner(scope),

                                    Components.TextLabel(scope, {
                                        Name = "Title",
                                        Text = string.upper(panelId),
                                        TextXAlignment = Enum.TextXAlignment.Left,

                                        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                                            return if use(isSelecting) then Color3.new() else Components.WHITE_COLOR
                                        end),

                                        [Children] = {
                                            Components.UIPadding(scope, {})
                                        }
                                    }),

                                    Components.IconImageLabel(scope, {
                                        AnchorPoint = Vector2.new(0, 0.5),
                                        Position = UDim2.fromScale(1.05, 0.5),
                                        Size = UDim2.fromScale(1.5, 1.5),

                                        Image = ICONS[panelId],
                                    }),

                                    Components.HoverImageButton(scope, {
                                        [Fusion.OnEvent("MouseEnter")] = function()
                                            isSelecting:set(true)
                                        end,
                                        [Fusion.OnEvent("MouseLeave")] = function()
                                            isSelecting:set(false)
                                        end,


                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            if panelId == "Play" then
                                                props.SlotUISignal:Fire()

                                                --- elseif panelId == "Tutorial" then
                                            end
                                        end,
                                    })
                                }
                            })
                        end)
                    }
                })
            }
        },
    })



    local shownObserver = Fusion.Observer(scope, isShown)
    shownObserver:onBind(function()
        local shown = Fusion.peek(isShown) :: boolean
        if shown then
            HarukaLib:UITween(UI.Bottom, "In", {
                FollowOriPropsWhenIn = true,

                TweenTime = 0.5,
                PosTweenStyle = "FromL2R",
                PosTweenBaseElement = UI.Bottom.SidePanel
            })
        else
            HarukaLib:UITween(UI.Bottom, "Out", {
                SetOriPropsWhenOut = true,

                PosTweenStyle = "FromR2L",
                PosTweenBaseElement = UI.Bottom.SidePanel,
            })
        end
    end)

    return UI
end