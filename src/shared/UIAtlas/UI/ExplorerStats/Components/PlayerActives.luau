--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local ActiveSlot = require(script.Parent.ActiveSlot)
local AbilitySlot = require(script.Parent.AbilitySlot)


local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Mana: Fusion.Value,
    MaxMana: Fusion.Value,

    ClassUltProgress: Fusion.Value,
    MaxClassUltProgress: Fusion.Value,

    Class: Fusion.Value,
    ClassVariant: Fusion.Value

}, self: table)

    local isSelectingUlt = Fusion.Value(scope, false)


    local lastInput = FusionComponents.useXboxControllerHotInput(scope)
    local refreshBoolean = Fusion.Value(scope, false)
    table.insert(scope, KeybindsBook.OnKeybindChanged:Connect(function()
        refreshBoolean:set(not Fusion.peek(refreshBoolean))
    end))


    local key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInput) :: string
        local boolean = use(refreshBoolean)

        if input == "Keyboard" then
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

        elseif input == "Controller" then
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
                Scale = 0.95
            }),

            Components.Frame(scope, {
                Name = "Div",
                AnchorPoint = Vector2.xAxis,
                Position = UDim2.fromScale(0.985, -0.2),
                Size = UDim2.fromScale(0.33, 1),

                [Children] = {
                    Components.Frame(scope, {
                        Name = "ManaSection",
                        AnchorPoint = Vector2.zero,
                        Position = UDim2.fromScale(0, -2),

                        [Children] = {
                            Components.IconImageLabel(scope, {
                                Name = "ManaSymbol",
                                AnchorPoint = Vector2.one,
                                Position = UDim2.fromScale(1, 1),
                                Size = UDim2.fromScale(1.2, 1.2),

                                Image = "rbxassetid://131740194041023",
                                ZIndex = 10
                            }),

                            Components.Frame(scope, {
                                Name = "Main",
                                BackgroundTransparency = 0,
                                AnchorPoint = Vector2.one,
                                Position = UDim2.fromScale(1, 0.9),
                                Size = UDim2.fromScale(0.6, 0.8),

                                [Children] = {
                                    Components.RoundUICorner(scope),

                                    Components.Frame(scope, {
                                        Name = "CornerTex",
                                        BackgroundTransparency = 0,
                                        AnchorPoint = Vector2.zero,
                                        Position = UDim2.fromScale(0, 0),
                                        Size = UDim2.fromScale(0.1, 0.5)
                                    }),

                                    Components.TextLabel(scope, {
                                        Name = "ManaStats",
                                        Position = UDim2.fromScale(0.05, 0.1),
                                        Size = UDim2.fromScale(0.675, 0.4),
                                        RichText = true,
                                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),
                                        TextColor3 = Color3.fromRGB(0, 255, 255),
                                        TextXAlignment = Enum.TextXAlignment.Right,

                                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            local mana = use(props.Mana)
                                            local maxMana = use(props.MaxMana)

                                            if mana > maxMana then mana = maxMana end

                                            return `{mana}<font color="#9f9f9f"> / {maxMana}</font>`
                                        end)
                                    }),

                                    Components.Frame(scope, {
                                        Name = "ManaBar",
                                        BackgroundTransparency = 0,
                                        BackgroundColor3 = Color3.new(),
                                        AnchorPoint = Vector2.zero,
                                        Position = UDim2.fromScale(0.05, 0.6),
                                        Size = UDim2.fromScale(0.7, 0.2),

                                        [Children] = {
                                            Components.RoundUICorner(scope),

                                            Components.Frame(scope, {
                                                Name = "Bar",
                                                AnchorPoint = Vector2.xAxis,
                                                Position = UDim2.fromScale(1, 0),
                                                BackgroundTransparency = 0,
                                                BackgroundColor3 = Color3.fromRGB(30, 144, 255),

                                                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                                                    local Mana, maxMana = use(props.Mana) :: number, use(props.MaxMana) :: number
                                                    local x = Mana / maxMana

                                                    if x ~= x then x = 0 end
                                                    x = math.clamp(x, 0, 1)

                                                    return UDim2.fromScale(x, 1)
                                                end), AssetBook.TweenInfos.half),

                                                [Children] = {
                                                    Components.RoundUICorner(scope)
                                                }
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    }),


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

                                    Components.UIStroke(scope, {
                                        Thickness = 2.5,

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
                                            self.RequestToCastClassUlt:Fire()
                                        end
                                    }),

                                    Components.IconImageLabel(scope, {
                                        Name = "BaseIcon",
                                        BackgroundTransparency = 0.3,
                                        ZIndex = 0,
                                        ImageTransparency = 0.7,

                                        Image = Fusion.Computed(scope, function(use: Fusion.Use)
                                            local classInfo = ClassBook[use(props.Class)]
                                            local variant = use(props.ClassVariant) or "None"

                                            if classInfo == nil then return AssetBook.ExtraIcons.Unknown end

                                            return classInfo.Skills["UltSkillIcon_"..variant] or ""
                                        end),
                                    }),
                                    Components.IconImageLabel(scope, {
                                        Name = "Icon",

                                        Image = Fusion.Computed(scope, function(use: Fusion.Use)
                                            local classInfo = ClassBook[use(props.Class)]
                                            local variant = use(props.ClassVariant) or "None"

                                            if classInfo == nil then return AssetBook.ExtraIcons.Unknown end

                                            return classInfo.Skills["UltSkillIcon_"..variant] or ""
                                        end),
                                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            local classInfo = ClassBook[use(props.Class)]
                                            local variant = use(props.ClassVariant) or "None"

                                            if classInfo == nil then return Color3.new(1, 1, 1) end

                                            return if classInfo.Skills["UltSkill"..variant.."_WithoutRecolor"] then
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


    return frame
end
