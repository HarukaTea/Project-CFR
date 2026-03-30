
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ActiveSlot = require(script.Parent.ActiveSlot)
local AbilitySlot = require(script.Parent.AbilitySlot)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    ClassUltProgress: Fusion.Value<number>,
    MaxClassUltProgress: Fusion.Value<number>,

    Class: Fusion.Value<string>,

    UIViewportSize: Fusion.Value<Vector2>,

}, self: {
    CastClassUlt_C: BindableEvent,
    ActiveList: {},
    CharAbilityList: {}
}) : Frame

    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local isSelectingUlt = Value(false)
    local jmpBtnSize = Value(Vector2.one)

    local forceLocationsMobile = {
        UDim2.fromScale(-0.5, 0.5),
        UDim2.fromScale(-0.2, -0.225),
        UDim2.fromScale(0.5, -0.5),

        UDim2.fromScale(0.5, -1.2),

        UDim2.fromScale(-1.3, 0.5)
    }
    local forceSizeMobile = Fusion.Value(UDim2.fromScale(0.2 / 1.7, 0.2 / 1.7))

    Fusion.Observer(scope, jmpBtnSize):onBind(function()
        local size = Fusion.peek(jmpBtnSize)

        forceSizeMobile:set(UDim2.fromOffset(size.Y / 1.7, size.Y / 1.7))
    end)


    local frame = Fusion.Hydrate(scope, Components:RefUI("DivUniControls_DUC1_1", false, true))({
        [Fusion.Out("AbsoluteSize")] = jmpBtnSize,

        [Children] = {
            Components.Frame(scope, {
                Name = "Div",

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ClassQUlt_ActiveSlot1_1", false, false, {
                        "UICorner", "UIGradient"
                    }))({
                        Position = forceLocationsMobile[5],

                        Size = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(forceSizeMobile)
                        end),

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
                        }
                    }),

                    ActiveSlot(scope, {
                        Index = 1,
                        ActiveInfo = self.ActiveList[1],

                        ForcePosition = forceLocationsMobile[1],
                        ForceSize = forceSizeMobile,

                        IsMobile = true,
                    }, self),

                    ActiveSlot(scope, {
                        Index = 2,
                        ActiveInfo = self.ActiveList[2],

                        ForcePosition = forceLocationsMobile[2],
                        ForceSize = forceSizeMobile,

                        IsMobile = true,
                    }, self),

                    ActiveSlot(scope, {
                        Index = 3,
                        ActiveInfo = self.ActiveList[3],

                        ForcePosition = forceLocationsMobile[3],
                        ForceSize = forceSizeMobile,

                        IsMobile = true,
                    }, self),

                    AbilitySlot(scope, {
                        ActiveInfo = self.CharAbilityList[1],

                        ForcePosition = forceLocationsMobile[4],
                        ForceSize = forceSizeMobile,

                        IsMobile = true,
                    }, self)
                }
            })
        }
    })

    local classUltSlot = frame.Div.ClassQUlt
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

    return frame
end