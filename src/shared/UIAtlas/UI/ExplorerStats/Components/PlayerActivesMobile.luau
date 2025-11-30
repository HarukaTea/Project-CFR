
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Signal = require(RepS.HarukaShared.Shared.Signal)

local ActiveSlot = require(script.Parent.ActiveSlot)
local AbilitySlot = require(script.Parent.AbilitySlot)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    ClassUltProgress: Fusion.Value<number>,
    MaxClassUltProgress: Fusion.Value<number>,

    Class: Fusion.Value<string>,

}, self: {
    CastClassUlt_C: Signal.SignalClass,
    ActiveList: {},
    CharAbilityList: {}
}) : Frame

    local isSelectingUlt = Fusion.Value(scope, false)


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
                            Components.Frame(scope, {
                                Name = "ClassQUlt",
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.fromScale(0.4, -1),
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
                                }
                            }),

                            ActiveSlot(scope, {
                                Index = 1,
                                ActiveInfo = self.ActiveList[1],

                                ForcePosition = UDim2.fromScale(0.625, -0.75),
                                ForceSize = UDim2.fromScale(1.5, 1.5)
                            }, self),

                            ActiveSlot(scope, {
                                Index = 2,
                                ActiveInfo = self.ActiveList[2],

                                ForcePosition = UDim2.fromScale(0.6, -2.75),
                                ForceSize = UDim2.fromScale(1.5, 1.5)
                            }, self),

                            ActiveSlot(scope, {
                                Index = 3,
                                ActiveInfo = self.ActiveList[3],

                                ForcePosition = UDim2.fromScale(0.775, -4),
                                ForceSize = UDim2.fromScale(1.5, 1.5)
                            }, self),


                            AbilitySlot(scope, {
                                ActiveInfo = self.CharAbilityList[1],

                                ForcePosition = UDim2.fromScale(0.15, -0.25),
                                ForceSize = UDim2.fromScale(1.5, 1.5)
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