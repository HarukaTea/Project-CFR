--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HaurkaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    HP: Fusion.Value<number>,
    MaxHP: Fusion.Value<number>,

    Shield: Fusion.Value<number>,
    MaxShield: Fusion.Value<number>,

    IsHPRecovering: Fusion.Value<boolean>

}) : { Frame }

    local bar1: Frame, bar2 : Frame = nil, nil

    bar1 = Components.Frame(scope, {
        Name = "HPBar",
        ZIndex = 2,
        AnchorPoint = Vector2.zero,
        Position = UDim2.fromScale(0.125, 0.6),
        Size = UDim2.fromScale(0.825, 0.25),

        [Children] = {
            Components.RoundUICorner(scope),

            Components.Frame(scope, {
                Name = "Bar",
                AnchorPoint = Vector2.zero,
                BackgroundTransparency = 0,
                Position = UDim2.fromScale(0, 0),
                ZIndex = 2,

                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local HP, maxHP = use(props.HP) :: number, use(props.MaxHP) :: number

                    local x = HP / maxHP
                    if x ~= x then x = 0 end

                    x = math.clamp(x, 0, 1)

                    return UDim2.fromScale(x, 1)

                end), AssetBook.TweenInfos.half),
                BackgroundColor3 = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local isRecovering = use(props.IsHPRecovering) :: boolean

                    if isRecovering then
                        return Color3.fromHex('#7bed9f')
                    end

                    return Color3.fromRGB(193, 61, 57)
                end), AssetBook.TweenInfos.twiceHalf),

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            }),
            Components.Frame(scope, {
                Name = "BarFade",
                AnchorPoint = Vector2.zero,
                BackgroundTransparency = 0,
                Position = UDim2.fromScale(0, 0),

                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local HP, maxHP = use(props.HP) :: number, use(props.MaxHP) :: number

                    local x = HP / maxHP
                    if x ~= x then x = 0 end

                    x = math.clamp(x, 0, 1)

                    return UDim2.fromScale(x, 1)

                end), AssetBook.TweenInfos.one),
                BackgroundColor3 = Color3.fromRGB(193, 61, 57):Lerp(Color3.new(), 0.65),

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            }),

            Components.UIStroke(scope, {
                Name = "Shield",
                Thickness = 2.5,
                Color = Color3.fromRGB(255, 234, 167),

                [Children] = {
                    Components.UIGradient(scope, {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.001, 0),
                            NumberSequenceKeypoint.new(0.002, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        })
                    })
                }
            })
        }
    })
    bar2 = Components.Frame(scope, {
        Name = "HPBarFade",
        AnchorPoint = Vector2.zero,
        Position = UDim2.fromScale(0.125, 0.6),
        Size = UDim2.fromScale(0.825, 0.25),

        [Children] = {
            Components.RoundUICorner(scope),

            Components.UIStroke(scope, {
                Name = "Shield",
                Thickness = 2.5,
                Color = Color3.fromRGB(255, 234, 167):Lerp(Color3.new(), 0.65),

                [Children] = {
                    Components.UIGradient(scope, {
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(0.001, 0),
                            NumberSequenceKeypoint.new(0.002, 1),
                            NumberSequenceKeypoint.new(1, 1)
                        })
                    })
                }
            })
        }
    })

    --// Anims

    local function _updateShield()
        local shield = Fusion.peek(props.Shield) :: number
        local maxShield = Fusion.peek(props.MaxShield) :: number

        local x = shield / maxShield
        if x ~= x then x = 0 end

        x = math.clamp(x, 0, 0.999)

        local bar1 = bar1
        local bar2 = bar2

        HaurkaLib:Tween(bar1.Shield.UIGradient, AssetBook.TweenInfos.half, {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(x, 0),
                NumberSequenceKeypoint.new(x + 0.001, 1),
                NumberSequenceKeypoint.new(1, 1)
            })
        })
        HaurkaLib:Tween(bar2.Shield.UIGradient, AssetBook.TweenInfos.one, {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(x, 0),
                NumberSequenceKeypoint.new(x + 0.001, 1),
                NumberSequenceKeypoint.new(1, 1)
            })
        })
    end
    Fusion.Observer(scope, props.Shield):onBind(_updateShield)
    Fusion.Observer(scope, props.MaxShield):onBind(_updateShield)



    return { bar1, bar2 }
end