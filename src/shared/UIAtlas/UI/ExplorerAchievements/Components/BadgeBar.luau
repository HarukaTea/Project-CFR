
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local CFEmblemTex = require(RepS.HarukaShared.UIAtlas.Components.CFEmblemTex)



local Children = Fusion.Children


type Dict = { [string]: any }


return function(scope: Fusion.Scope, props: {
    BadgeId: string,
    BadgeInfo: Dict,

    HasOwned: Fusion.Value<boolean>,
    IsUnlocked: Fusion.Value<boolean>,
    LayoutOrder: number
})

    local badge = props.BadgeId
    local badgeInfo = props.BadgeInfo
    local hasOwned = props.HasOwned
    local layoutOrder = props.LayoutOrder
    local isUnlocked = props.IsUnlocked

    return Components.Frame(scope, {
        Name = badge,
        Size = UDim2.fromScale(0.97, 0.22),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromHex('#cac4b9'),

        LayoutOrder = Fusion.Computed(scope, function(use: Fusion.Use, _)
            local state = use(hasOwned)
            if state then
                return layoutOrder + 233
            else
                return layoutOrder
            end
        end),


        [Children] = {
            Components.UICorner(scope, {
                CornerRadius = UDim.new(0.1, 0),
            }),
            Components.UIAspectRatioConstraint(scope, 9.016),

            Components.IconImageLabel(scope, {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.02, 0.5),
                Size = UDim2.fromScale(0.8, 0.8),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return HarukaLib:CombineRbxId(use(badgeInfo).IconImageId) or ""
                end)
            }),

            Components.TextLabel(scope, {
                Name = "Title",
                Position = UDim2.fromScale(0.13, 0.1),
                Size = UDim2.fromScale(0.8, 0.35),
                TextColor3 = Components.BLACK_COLOR,
                TextXAlignment = Enum.TextXAlignment.Left,
                RichText = true,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `<u>{use(badgeInfo).Name}</u>` or "<u>Fetching Badge Info...</u>"
                end)
            }),
            Components.TextLabel(scope, {
                Name = "Desc",
                Position = UDim2.fromScale(0.13, 0.53),
                Size = UDim2.fromScale(0.8, 0.25),
                TextColor3 = Components.BLACK_COLOR,
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(badgeInfo).Description or ""
                end)
            }),

            Components.Frame(scope, {
                Name = "Shadow",
                BackgroundTransparency = 0.3,
                BackgroundColor3 = Color3.fromRGB(),
                ZIndex = 2,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(isUnlocked)
                end),

                [Children] = {
                    Components.UICorner(scope, {
                        CornerRadius = UDim.new(0.1, 0),
                    }),
                }
            }),


            CFEmblemTex(scope, {
                Position = UDim2.fromScale(0.75, 0.5),
                Transparency = 0.85
            })
        }
    })
end
