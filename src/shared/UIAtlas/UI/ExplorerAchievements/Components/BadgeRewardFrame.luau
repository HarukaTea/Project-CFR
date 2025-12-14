
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(RepS.HarukaShared.Library.Events)


local IconShadeTex = require(RepS.HarukaShared.UIAtlas.Components.IconShadeTex)



local Children = Fusion.Children


type Dict = { [string]: any }





return function(scope: Fusion.Scope, props: {
    BadgeCompletedCount: Fusion.Value<number>,
    HasGottenReward: Fusion.Value<boolean>
})
    return Components.Frame(scope, {
        Name = "BadgeRewards",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0.02, 1),
        Size = UDim2.fromScale(0.325, 7),

        [Children] = {
            Components.Frame(scope, {
                Name = "AwardIcon",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.15),
                Size = UDim2.fromScale(0.3, 0.3),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                [Children] = {
                    Components.IconImageLabel(scope, {
                        Image = "rbxassetid://118519686473047"
                    }),

                    IconShadeTex(scope, {
                        Transparency = 0.8
                    })
                }
            }),


            Components.TextLabel(scope, {
                Name = "Tip",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.55),
                Size = UDim2.fromScale(1, 0.08),
                Text = "<u>BADGE PRIZE</u>",
                TextColor3 = Color3.fromRGB(255, 255, 127),
                RichText = true,

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {})
                }
            }),
            Components.TextLabel(scope, {
                Name = "Progress",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.75),
                Size = UDim2.fromScale(1, 0.08),


                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `{use(props.BadgeCompletedCount)} / 6    COMPLETED`
                end),

                [Children] = {
                    Components.ScaledTextUIStroke(scope, {})
                }
            }),


            Components.Frame(scope, {
                Name = "ProgressBar",
                Position = UDim2.fromScale(0.5, 0.7),
                AnchorPoint = Vector2.new(0.5, 0),
                Size = UDim2.fromScale(0.8, 0.03),
                BackgroundColor3 = Color3.fromRGB(),
                BackgroundTransparency = 0,

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.Frame(scope, {
                        Name = "Bar",
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.fromScale(0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 127),
                        BackgroundTransparency = 0,

                        Size = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local x = use(props.BadgeCompletedCount) / 6

                            if x ~= x then x = 0 end -- NaN check
                            x = math.clamp(x, 0, 1)

                            return UDim2.fromScale(x, 1)
                        end),

                        [Children] = {
                            Components.RoundUICorner(scope)
                        }
                    })
                }
            }),


            Components.TextButton(scope, {
                Name = "ClaimButton",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.9),
                Size = UDim2.fromScale(0.4, 0.08),
                BackgroundTransparency = 0,
                TextColor3 = Components.BLACK_COLOR,
                Text = "CLAIM",

                BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(props.BadgeCompletedCount) >= 6 then Components.BLUE_COLOR else Components.RED_COLOR
                end),
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(props.HasGottenReward)
                end),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if Fusion.peek(props.BadgeCompletedCount) < 6 then
                        Bindables.CreateNotify:Fire("Collect 6 badges to claim this reward")
                        return
                    end

                    Events.ClaimBadgeReward_C.Fire()
                    props.HasGottenReward:set(true)
                end,


                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        }
    })
end