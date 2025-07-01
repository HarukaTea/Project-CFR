--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local PerkBook = require(RepS.HarukaShared.Library.PerkBook)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    PerkId: string,
})

    local absDescFrameSize = Fusion.Value(scope, Vector2.zero)


    local belongTo = "STR"
    for perkPointId: string, perkBelongTo: { any } in PerkBook do
        for id: string, _ in perkBelongTo do
            if id == props.PerkId then
                belongTo = perkPointId
                break
            end
        end
    end
    local perkInfo = PerkBook[belongTo][props.PerkId]

    if not perkInfo then return nil end


    return Components.Frame(scope, {
        Name = "ItemDesc",
        BackgroundTransparency = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.fromScale(0.98, 0.8),
        Size = UDim2.fromScale(0.28, 7),

        Visible = Fusion.Computed(scope, function()
            return props.PerkId ~= nil
        end),

        [Children] = {
            Components.UICorner(scope, { CornerRadius = UDim.new(0.015, 0) }),

            Components.UIStroke(scope, {
                Thickness = 6,
                Color = Color3.new()
            }),

            Components.UIListLayout(scope, {
                Padding = UDim.new(0.03, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),

            Components.PaddingFrame(scope, "AAA"),


            Components.Frame(scope, {
                Name = "PerkName",
                LayoutOrder = 2,
                Size = UDim2.fromScale(0.9, 0.1),

                [Children] = {
                    Components.UIAspectRatioConstraint(scope, 9.093),

                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.05, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                    }),

                    Components.Frame(scope, {
                        Name = "PerkColorIndicator",
                        Size = UDim2.fromScale(0.02, 0.65),

                        BackgroundTransparency = 0,
                        BackgroundColor3 = AssetBook.PerkPointColors[belongTo]
                    }),
                    Components.TextLabel(scope, {
                        Name = "PerkName",
                        Size = UDim2.fromScale(0.7, 0.7),
                        TextXAlignment = Enum.TextXAlignment.Left,

                        Text = perkInfo.Name,

                        [Fusion.Out("AbsoluteSize")] = absDescFrameSize,
                    }),
                    Components.Frame(scope, {
                        Name = "PerkReq",
                        Size = UDim2.fromScale(0.2, 1),

                        [Children] = {
                            Components.UIListLayout(scope, {
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                            }),

                            Components.TextLabel(scope, {
                                Name = "Req",
                                BackgroundColor3 = Components.WHITE_COLOR,
                                BackgroundTransparency = 0,
                                Size = UDim2.fromScale(1.2, 0.7),
                                TextColor3 = Components.BLACK_COLOR,

                                Text = `{perkInfo.Req} {perkInfo.Type}`,

                                [Children] = {
                                    Components.RoundUICorner(scope),
                                    Components.UIPadding(scope, {})
                                }
                            })
                        }
                    })
                }
            }),


            Components.ScrollingFrame(scope, {
                Name = "PerkDesc",
                LayoutOrder = 3,
                Size = UDim2.fromScale(0.9, 0.8),

                [Children] = {
                    Components.PaddingFrame(scope, "AAA"),

                    Components.TextLabel(scope, {
                        Name = "AAA_PerkStats",
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.fromScale(0.97, 0),
                        LayoutOrder = 1,
                        TextScaled = false,
                        TextWrapped = true,
                        RichText = true,
                        LineHeight = 1.2,

                        Text = HarukaLib:RichTextify(perkInfo.Stat),
                        TextXAlignment = Enum.TextXAlignment.Left,

                        TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return math.clamp(use(absDescFrameSize).Y / 1.1, 1, 33)
                        end),
                    }),


                    Components.Frame(scope, {
                        Name = "BBB_BBB",
                        Size = UDim2.fromOffset(1, 1),
                    }),


                    Components.TextLabel(scope, {
                        Name = "CCC_PerkDesc",
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Size = UDim2.fromScale(0.97, 0),
                        LayoutOrder = 233,
                        TextScaled = false,
                        TextWrapped = true,
                        RichText = true,
                        LineHeight = 1.2,

                        Text = HarukaLib:RichTextify(perkInfo.Desc),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextColor3 = Color3.fromRGB(159, 159, 159),

                        TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return math.clamp(use(absDescFrameSize).Y / 1.1, 1, 33 / 1.07)
                        end)
                    })
                }
            }, {
                Padding = UDim.new(0, 10),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.Name
            })
        }
    })
end
