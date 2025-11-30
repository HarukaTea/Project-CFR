
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Signal = require(RepS.HarukaShared.Shared.Signal)

local ActiveSlot = require(script.Parent.ActiveSlot)
local AbilitySlot = require(script.Parent.AbilitySlot)


local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    ClassUltProgress: Fusion.Value<number>,
    MaxClassUltProgress: Fusion.Value<number>,

    Class: Fusion.Value<string>,

}, self: {
    CastClassUlt_C: Signal.SignalClass,
    ActiveList: {},
    CharAbilityList: {}
}) : { Frame }

    local isSelectingUlt = Fusion.Value(scope, false)


    local lastInput = Components.FusionComponents.useXboxControllerHotInput(scope)
    local refreshBoolean = Fusion.Value(scope, false)
    table.insert(scope, KeybindsBook.OnKeybindChanged:Connect(function()
        refreshBoolean:set(not Fusion.peek(refreshBoolean))
    end))


    local key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInput) :: string
        local boolean = use(refreshBoolean)

        boolean = boolean

        if input == "Controller" then
            local keybind = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.Console.ClassUlt.Name] or KeybindsBook.Console.ClassUlt.Name

            return Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = Vector2.one,
                Text = keybind,
                Size = UDim2.fromScale(0.25, 0.4),
                AutomaticSize = Enum.AutomaticSize.X,
                Position = UDim2.fromScale(1.05, 1),
                BackgroundTransparency = 0,
                BackgroundColor3 = if AssetBook.XboxControllerColors[keybind] then AssetBook.XboxControllerColors[keybind] else Components.BLACK_COLOR,
                TextColor3 = if AssetBook.XboxControllerColors[keybind] then Color3.new() else Color3.new(1, 1, 1),
                ZIndex = 2,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        elseif input == "Keyboard" then
            return Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = Vector2.one,
                Text = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.PC.ClassUlt.Name] or KeybindsBook.PC.ClassUlt.Name,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0.25, 0.4),
                Position = UDim2.fromScale(1.05, 1),
                BackgroundTransparency = 0,
                ZIndex = 2,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        else
            return nil
        end
    end)


    local frame = Components.Frame(scope, {
        Name = "PlayerActives",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1, 1),

        [Children] = {
            Components.UIScale(scope, {
                Scale = 1
            }),

            Components.Frame(scope, {
                Name = "Div",
                AnchorPoint = Vector2.xAxis,
                Position = UDim2.fromScale(0.985, -0.2),
                Size = UDim2.fromScale(0.33, 1),

                [Children] = {
                    Components.Frame(scope, {
                        Name = "PlayerControls",

                        [Children] = {
                            Components.UIListLayout(scope, {
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                Padding = UDim.new(0.015, 0)
                            }),

                            Components.Frame(scope, {
                                Name = "ClassQUlt",
                                LayoutOrder = 233,
                                Size = UDim2.fromScale(1.8, 1.8),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                BackgroundTransparency = 0,
                                BackgroundColor3 = Color3.new(),

                                [Children] = {
                                    Components.RoundUICorner(scope),

                                    Components.UIGradient(scope, {
                                        Rotation = -90,

                                        Transparency = NumberSequence.new({
                                            NumberSequenceKeypoint.new(0, 0),
                                            NumberSequenceKeypoint.new(0.001, 0),
                                            NumberSequenceKeypoint.new(0.002, 1),
                                            NumberSequenceKeypoint.new(1, 1)
                                        })
                                    }),

                                    Components.ScaledUIStroke(scope, {
                                        Thickness = 0.035,

                                        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return use(isSelectingUlt)
                                        end),
                                    }),

                                    Components.HoverImageButton(scope, {
                                        [Fusion.OnEvent("MouseEnter")] = function()
                                            isSelectingUlt:set(true)
                                        end,
                                        [Fusion.OnEvent("MouseLeave")] = function()
                                            isSelectingUlt:set(false)
                                        end,

                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            self.CastClassUlt_C:Fire()
                                        end
                                    }),

                                    Components.IconImageLabel(scope, {
                                        Name = "BaseIcon",
                                        ZIndex = 0,
                                        ImageTransparency = 0.7,
                                        BackgroundTransparency = 0.7,

                                        Image = Fusion.Computed(scope, function(use: Fusion.Use)
                                            local classInfo = ClassBook[use(props.Class)]
                                            if classInfo == nil then return AssetBook.ExtraIcons.Unknown end

                                            return classInfo.Icon
                                        end),
                                    }),
                                    Components.IconImageLabel(scope, {
                                        Name = "Icon",
                                        BackgroundTransparency = 1,

                                        Image = Fusion.Computed(scope, function(use: Fusion.Use)
                                            local classInfo = ClassBook[use(props.Class)]
                                            if classInfo == nil then return AssetBook.ExtraIcons.Unknown end

                                            return classInfo.Icon
                                        end),
                                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            local classInfo = ClassBook[use(props.Class)]
                                            if classInfo == nil then return Color3.new(1, 1, 1) end

                                            local charge, maxCharge = use(props.ClassUltProgress) :: number, use(props.MaxClassUltProgress) :: number
                                            local x = charge / maxCharge

                                            if x ~= x then x = 0 end
                                            x = math.clamp(x, 0, 0.999)
                                            if x < 0.999 then return Color3.new(1, 1, 1) end

                                            return if classInfo.Skills["UltSkill_WithoutRecolor"] then
                                                Color3.new(1, 1, 1)
                                            else classInfo.Color
                                        end),

                                        [Children] = {
                                            Components.UIGradient(scope, {
                                                Rotation = -90,

                                                Transparency = NumberSequence.new({
                                                    NumberSequenceKeypoint.new(0, 0),
                                                    NumberSequenceKeypoint.new(0.001, 0),
                                                    NumberSequenceKeypoint.new(0.002, 1),
                                                    NumberSequenceKeypoint.new(1, 1)
                                                })
                                            }),
                                        }
                                    }),

                                    Components.TextLabel(scope, {
                                        Name = "UltReady",
                                        AnchorPoint = Vector2.new(0.5, 0),
                                        Position = UDim2.fromScale(0.5, -0.25),
                                        Size = UDim2.fromScale(1, 0.25),
                                        Text = "READY",


                                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            local charge, maxCharge = use(props.ClassUltProgress) :: number, use(props.MaxClassUltProgress) :: number
                                            local x = charge / maxCharge

                                            if x ~= x then x = 0 end
                                            x = math.clamp(x, 0, 0.999)

                                            if x >= 0.999 then return true end

                                            return false
                                        end),
                                        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            local classInfo = ClassBook[use(props.Class)]

                                            if classInfo == nil then return Color3.new(1, 1, 1) end

                                            return classInfo.Color
                                        end),

                                        [Children] = {
                                            Components.ScaledTextUIStroke(scope, {})
                                        }
                                    }),

                                    key
                                }
                            }),

                            ActiveSlot(scope, {
                                Index = 1,
                                ActiveInfo = self.ActiveList[1]
                            }, self),

                            ActiveSlot(scope, {
                                Index = 2,
                                ActiveInfo = self.ActiveList[2]
                            }, self),

                            ActiveSlot(scope, {
                                Index = 3,
                                ActiveInfo = self.ActiveList[3]
                            }, self),
                        }
                    })
                }

            })

        }
    })
    local frame2 = Components.Frame(scope, {
        Name = "PlayerActives2",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1, 1),

        [Children] = {
            Components.UIScale(scope, {
                Scale = 1
            }),

            Components.Frame(scope, {
                Name = "Div2",
                AnchorPoint = Vector2.xAxis,
                Position = UDim2.fromScale(0.985, -2.5),
                Size = UDim2.fromScale(0.33, 1),

                [Children] = {
                    Components.Frame(scope, {
                        Name = "PlayerControls",

                        [Children] = {
                            Components.UIListLayout(scope, {
                                FillDirection = Enum.FillDirection.Horizontal,
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                                Padding = UDim.new(0.015, 0)
                            }),

                            AbilitySlot(scope, {
                                ActiveInfo = self.CharAbilityList[1]
                            }, self)
                        }
                    })
                }

            })

        }
    })


    local classUltSlot = frame.Div.PlayerControls.ClassQUlt
    local function _updateClassUlt()
        local charge, maxCharge = Fusion.peek(props.ClassUltProgress) :: number, Fusion.peek(props.MaxClassUltProgress) :: number
        local x = charge / maxCharge

        if x ~= x then x = 0 end
        x = math.clamp(x, 0, 0.999)


        HarukaLib:Tween(classUltSlot.UIGradient, AssetBook.TweenInfos.half, {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(x, 0),
                NumberSequenceKeypoint.new(x + 0.001, 1),
                NumberSequenceKeypoint.new(1, 1)
            })
        })
        HarukaLib:Tween(classUltSlot.Icon.UIGradient, AssetBook.TweenInfos.half, {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(x, 0),
                NumberSequenceKeypoint.new(x + 0.001, 1),
                NumberSequenceKeypoint.new(1, 1)
            })
        })
    end
    Fusion.Observer(scope, props.ClassUltProgress):onBind(_updateClassUlt)
    Fusion.Observer(scope, props.MaxClassUltProgress):onBind(_updateClassUlt)


    return { frame, frame2 }
end