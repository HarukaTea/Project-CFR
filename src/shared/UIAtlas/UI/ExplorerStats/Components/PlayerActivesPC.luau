
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ActiveSlot = require(script.Parent.ActiveSlot)
local AbilitySlot = require(script.Parent.AbilitySlot)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    ClassUltProgress: Fusion.Value<number>,
    MaxClassUltProgress: Fusion.Value<number>,

    Class: Fusion.Value<string>,

}, self: {
    CastClassUlt_C: BindableEvent,
    ActiveList: {},
    CharAbilityList: {}
}) : { Frame }

    local isSelectingUlt = Fusion.Value(scope, false)

    local lastInput = Components.FusionComponents.useXboxControllerHotInput(scope)
    local refreshBoolean = Fusion.Value(scope, false)
    table.insert(scope, KeybindsBook.OnKeybindChanged.Event:Connect(function()
        refreshBoolean:set(not Fusion.peek(refreshBoolean))
    end))

    local key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInput) :: string
        local boolean = use(refreshBoolean)

        boolean = boolean

        if input == "Controller" then
            local keybind = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.Console.ClassUlt.Name]
                or KeybindsBook.Console.ClassUlt.Name

            return Fusion.Hydrate(scope, Components:RefUI("Key_ClassUlt1_1", true))({
                Text = keybind,
                BackgroundColor3 = if AssetBook.XboxControllerColors[keybind] then
                    AssetBook.XboxControllerColors[keybind] else Components.BLACK_COLOR,
                TextColor3 = if AssetBook.XboxControllerColors[keybind] then
                    Color3.new() else Color3.new(1, 1, 1),
            })

        elseif input == "Keyboard" then
            return Fusion.Hydrate(scope, Components:RefUI("Key_ClassUlt1_1", true))({
                Text = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.PC.ClassUlt.Name]
                    or KeybindsBook.PC.ClassUlt.Name,
            })
        else
            return nil
        end
    end)

    local frame = Fusion.Hydrate(scope, Components:RefUI("PlayerActives_PActives1_1", false, true))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Div_PActives1_1"))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("PlayerControls_PActives1_1", false, true))({
                        [Children] = {
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

                            Fusion.Hydrate(scope, Components:RefUI("ClassQUlt_ActiveSlot1_1", false, false, {
                                "UICorner", "UIGradient"
                            }))({
                                [Children] = {
                                    Components.ScaledUIStroke(scope, {
                                        Thickness = 0.035,
                                        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return use(isSelectingUlt)
                                        end),
                                    }),

                                    Components.HoverImageButton(scope, {
                                        Components.ConnectSelectEvents(isSelectingUlt),

                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            self.CastClassUlt_C:Fire()
                                        end
                                    }),

                                    Fusion.Hydrate(scope, Components:RefUI("BaseIcon_ClassUlt1_1", true))({
                                        Image = Fusion.Computed(scope, function(use: Fusion.Use)
                                            local classInfo = ClassBook[use(props.Class)]
                                            if classInfo == nil then return AssetBook.ExtraIcons.Unknown end

                                            return classInfo.Icon
                                        end),
                                    }),
                                    Fusion.Hydrate(scope, Components:RefUI("Icon_ClassUlt1_1", true))({
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
                                    }),

                                    Fusion.Hydrate(scope, Components:RefUI("UltReady_ClassUlt1_1", true))({
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
                                    }),

                                    key
                                }
                            })
                        }
                    })
                }
            })
        }
    })
    local frame2 = Fusion.Hydrate(scope, Components:RefUI("PlayerActives_PActives1_1", false, true))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Div2_PActives1_1"))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("PlayerControls_PActives1_1", false, true))({
                        [Children] = {
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

        HarukaLib:Tween(classUltSlot.UIGradient, Components.TweenInfos.half, {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(x, 0),
                NumberSequenceKeypoint.new(x + 0.001, 1),
                NumberSequenceKeypoint.new(1, 1)
            })
        })
        HarukaLib:Tween(classUltSlot.Icon.UIGradient, Components.TweenInfos.half, {
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