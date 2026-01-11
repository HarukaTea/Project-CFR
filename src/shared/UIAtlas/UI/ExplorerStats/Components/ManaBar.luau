
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    Mana: Fusion.Value<number>,
    MaxMana: Fusion.Value<number>,

}) : Frame

    return Components.Frame(scope, {
        Name = "ManaBar",
        LayoutOrder = 2,
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
                BackgroundColor3 = Color3.fromHex('#135eaf'),

                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local mana, maxMana = use(props.Mana) :: number, use(props.MaxMana) :: number

                    local x = mana / maxMana
                    if x ~= x then x = 0 end

                    x = math.clamp(x, 0, 1)

                    return UDim2.fromScale(x, 1)
                end), Components.TweenInfos.halfBack),

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            }),


            Components.TextLabel(scope, {
				Name = "Stat",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.94, 1),
				TextXAlignment = Enum.TextXAlignment.Right,

				Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
					return use(props.Mana) .. " / " .. use(props.MaxMana)
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
				Text = "MANA",

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
				Image = "rbxassetid://12119869276",
			}),
        }
    })
end