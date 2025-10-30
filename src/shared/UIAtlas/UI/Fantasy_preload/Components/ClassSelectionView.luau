
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Events = require(RepS.HarukaShared.Library.Events)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Signal = require(RepS.HarukaShared.Shared.Signal)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local FrameBorderTex = require(RepS.HarukaShared.UIAtlas.Components.FrameBorderTex)

local Children = Fusion.Children

local wait = task.wait

return function (scope: Fusion.Scope, props: {
    IsSelectingStartClass: Fusion.Value,
    ReadyToTeleportSignal: RBXScriptSignal,
    IsUIShown: Fusion.Value,
    SlotId: string,
})

    local function Value(val: any)
        return Fusion.Value(scope, val)
    end
    local currentClassSelected = Value("Chain")
    local absPanelSize = Value(Vector2.zero)
    local isClassSelected = Value(false)


    local classSelected = Signal.new()
    table.insert(scope, classSelected)


    local frame = Components.Frame(scope, {
        Name = "ClassSelection",
        BackgroundTransparency = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.fromScale(0.97, 0.5),
        Size = UDim2.fromScale(0.28, 0.7),


        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(props.IsSelectingStartClass)
        end),

        [Children] = {
            Components.UIAspectRatioConstraint(scope, 1.009),
            Components.UIStroke(scope, {
                Thickness = 4,
                Color = Color3.new()
            }),

            FrameBorderTex(scope, {
                BorderType = "Outer"
            }),

            Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                if not use(isClassSelected) then
                    return ExecuteButton(scope, {
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.fromScale(0.5, 1.06),
                        Size = UDim2.fromScale(0.55, 0.1),
                        ButtonText = "SELECT",
                        ButtonClickFunc = function()
                            SoundService.SFXs.QuestCompleted:Play()

                            props.ReadyToTeleportSignal:Fire()
                            Bindables.CreateCircularFade:Fire(2)

                            wait(0.5)
                            Events.RequestToChooseWhichSlotToPlay.Fire({
                                SlotId = Fusion.peek(props.SlotId),
                                ClassChosen = Fusion.peek(currentClassSelected)
                            })
                            props.IsUIShown:set(false)
                            props.IsSelectingStartClass:set(false)
                        end,
                        ButtonType = "Confirm"
                    })
                else return nil
                end
            end),


            Components.Frame(scope, {
                Name = "CenterSquare",
                Size = UDim2.fromScale(0.9, 0.9),

                [Fusion.Out("AbsoluteSize")] = absPanelSize,

                [Children] = {
                    Components.UIListLayout(scope, {
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        Padding = UDim.new(0.05, 0),
                    }),

                    Components.Frame(scope, {
                        LayoutOrder = 1,
                        Name = "Classes",
                        Size = UDim2.fromScale(1, 0.15),

                        [Children] = {
                            Components.UIListLayout(scope, {
                                FillDirection = Enum.FillDirection.Horizontal,
                                Padding = UDim.new(0.05, 0),
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                SortOrder = Enum.SortOrder.Name,
                            }),

                            Fusion.ForPairs(scope, ClassBook, function(_, scope: Fusion.Scope, classId: string, info: { any })
                                local whiteList = { "Chain", "Burst", "Flow" }
                                if not table.find(whiteList, classId) then return classId, nil end

                                local isSelecting = Fusion.Value(scope, false)
                                local isSelected = false
                                if classId == Fusion.peek(currentClassSelected) then
                                    isSelected = true
                                    isSelecting:set(true)
                                end

                                classSelected:Connect(function()
                                    isSelecting:set(false)
                                    isSelected = false
                                end)

                                return classId, Components.Frame(scope, {
                                    Name = classId,
                                    BackgroundTransparency = 0,
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,

                                    [Children] = {
                                        Components.RoundUICorner(scope),

                                        Components.ImageLabel(scope, {
                                            Name = "Icon",
                                            BackgroundTransparency = 0,
                                            SizeConstraint = Enum.SizeConstraint.RelativeYY,

                                            Image = info.Icon,
                                            ImageColor3 = info.Color,

                                            [Children] = {
                                                Components.RoundUICorner(scope)
                                            }
                                        }),
                                        Components.ImageLabel(scope, {
                                            Name = "Shade",
                                            Size = UDim2.fromScale(1.7, 1.7),
                                            AnchorPoint = Vector2.new(0.5, 0.5),
                                            Position = UDim2.fromScale(0.5, 0.5),
                                            ZIndex = 0,

                                            Visible = Fusion.Computed(scope, function(use: Fusion.Use)
                                                return use(isSelecting) or use(currentClassSelected) == classId
                                            end),

                                            Image = "rbxassetid://91832243782412",
                                            ImageTransparency = 0.3,
                                            ImageColor3 = info.Color,
                                        }),

                                        Components.HoverImageButton(scope, {
                                            ZIndex = 2,

                                            [Fusion.OnEvent("MouseEnter")] = function()
                                                isSelecting:set(true)
                                            end,
                                            [Fusion.OnEvent("MouseLeave")] = function()
                                                if not isSelected then isSelecting:set(false) end
                                            end,
                                            [Fusion.OnEvent("MouseButton1Click")] = function()
                                                classSelected:Fire()

                                                isSelecting:set(true)
                                                isSelected = true

                                                currentClassSelected:set(classId)

                                                workspace:SetAttribute("Titlescreen_TempClass", classId)
                                            end,
                                        })
                                    }
                                })
                            end)
                        }
                    }),

                    Components.TextLabel(scope, {
                        Name = "Class",
                        LayoutOrder = 2,
                        Size = UDim2.fromScale(1, 0.08),
                        RichText = true,

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `<u>{use(currentClassSelected)}</u>`
                        end),
                        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return ClassBook[use(currentClassSelected)].Color
                        end),
                    }),

                    Components.ScrollingFrame(scope, {
                        Name = "PanelInfo",
                        LayoutOrder = 4,
                        Size = UDim2.fromScale(1, 0.5),
                        ScrollingDirection = Enum.ScrollingDirection.Y,

                        [Children] = {
                            Components.TextLabel(scope, {
                                Name = "Info",
                                RichText = true,
                                AutomaticSize = Enum.AutomaticSize.Y,
                                Size = UDim2.fromScale(0.9, 0),
                                LineHeight = 1.2,

                                TextXAlignment = Enum.TextXAlignment.Left,
                                TextYAlignment = Enum.TextYAlignment.Top,
                                TextScaled = false,
                                TextWrapped = true,

                                TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return use(absPanelSize).X / (294 / 20)
                                end),
                                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                    return HarukaLib:RichTextify(ClassBook[use(currentClassSelected)].Desc)
                                end)
                            })
                        }
                    }, {
                        Padding = UDim.new(0, 12),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    }),
                }
            })
        }
    })



    local shownObserver = Fusion.Observer(scope, props.IsSelectingStartClass)
    shownObserver:onBind(function()
        local shown = Fusion.peek(props.IsSelectingStartClass) :: boolean
        if shown then
            HarukaLib:UITween(frame, "In", {
                FollowOriPropsWhenIn = true,

                TweenTime = 0.5,
                PosTweenStyle = "FromB2T",
                PosTweenBaseElement = frame
            })
        else
            HarukaLib:UITween(frame, "Out", {
                SetOriPropsWhenOut = true,

                PosTweenStyle = "FromT2B",
                PosTweenBaseElement = frame
            })
        end
    end)


    return frame
end