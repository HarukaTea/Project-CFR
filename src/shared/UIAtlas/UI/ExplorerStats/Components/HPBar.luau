
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
}) : Frame

    local bar1: Frame = nil

    bar1 = Components.Frame(scope, {
        Name = "HPBar",
        LayoutOrder = 1,
        Size = UDim2.fromScale(0.18, 0.875),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(),


        [Children] = {
            Components.RoundUICorner(scope),

            Components.Frame(scope, {
                Name = "Bar",
                AnchorPoint = Vector2.zero,
                BackgroundTransparency = 0,
                Position = UDim2.fromScale(0, 0),
                BackgroundColor3 = Color3.fromHex('#90c21f'),

                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local HP, maxHP = use(props.HP) :: number, use(props.MaxHP) :: number

                    local x = HP / maxHP
                    if x ~= x then x = 0 end

                    x = math.clamp(x, 0, 1)

                    return UDim2.fromScale(x, 1)
                end), AssetBook.TweenInfos.halfBack),

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            }),

            Components.ScaledUIStroke(scope, {
                Name = "Shield",
                Thickness = 0.2,
                Color = Color3.fromRGB(255, 255, 0),

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
            }),



            Components.TextLabel(scope, {
				Name = "Stat",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.94, 1),
				TextXAlignment = Enum.TextXAlignment.Right,

				Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
					return use(props.HP) .. " / " .. use(props.MaxHP)
				end),

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {
                        Thickness = 0.08,
                    })
                }
			}),
			Components.TextLabel(scope, {
				Name = "Title",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.62, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextStrokeTransparency = 0.7,
				Text = "HEALTH",

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {
                        Thickness = 0.08,
                    })
                }
			}),
			Components.IconImageLabel(scope, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.02, 0.5),
				Size = UDim2.fromScale(1.8, 1.8),
				Image = "rbxassetid://104142948728530",
                ImageColor3 = Color3.fromHex('#90c21f'),
			}),
        }
    })

    --// Anims

    local function _updateShield()
        local shield = Fusion.peek(props.Shield) :: number
        local maxShield = Fusion.peek(props.MaxShield) :: number

        local x = shield / maxShield
        if x ~= x then x = 0 end

        x = math.clamp(x, 0, 0.999)


        HaurkaLib:Tween(bar1.Shield.UIGradient, AssetBook.TweenInfos.half, {
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



    return bar1
end