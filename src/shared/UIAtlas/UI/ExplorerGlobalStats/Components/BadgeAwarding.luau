
local BadgeService = game:GetService("BadgeService")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local CFEmblemTex = require(RepS.HarukaShared.UIAtlas.Components.CFEmblemTex)

local Children = Fusion.Children

return function(scope: Fusion.Scope<any>, props: {
    BadgeId: number
})

    local badgeInfo = Fusion.Value(scope, {})
    table.insert(scope, task.spawn(function()
        local info
        pcall(function()
            info = BadgeService:GetBadgeInfoAsync(props.BadgeId)
        end)
        badgeInfo:set(info)
    end))


    local frame = Components.Frame(scope, {
        Name = "BadgeAwarding",
        BackgroundColor3 = Components.HarukaColorLab.COLOR_SERIES.AzurLane.Text,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(0.3, 1.5),

        [Children] = {
            Components.UICorner(scope, {
                CornerRadius = UDim.new(0.15, 0),
            }),


            Components.IconImageLabel(scope, {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0.05, 0.5),
                Size = UDim2.fromScale(0.8, 0.8),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return HarukaLib:CombineRbxId(use(badgeInfo).IconImageId) or ""
                end)
            }),

            Components.TextLabel(scope, {
                Name = "Title",
                Position = UDim2.fromScale(0.25, 0.15),
                Size = UDim2.fromScale(0.7, 0.35),
                TextColor3 = Components.BLACK_COLOR,
                TextXAlignment = Enum.TextXAlignment.Left,
                RichText = true,

                Text = "<u>New Achievement!</u>"
            }),
            Components.TextLabel(scope, {
                Name = "BadgeTitle",
                Position = UDim2.fromScale(0.25, 0.55),
                Size = UDim2.fromScale(0.7, 0.25),
                TextColor3 = Components.BLACK_COLOR,
                TextXAlignment = Enum.TextXAlignment.Left,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(badgeInfo).Name or ""
                end)
            }),


            CFEmblemTex(scope, {
                Transparency = 0.9,
                Position = UDim2.fromScale(0.5, 0.5),
            })
        }
    })

    return frame
end