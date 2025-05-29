--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    StatList: { [string]: number },
})
    return Components.ScrollingFrame(scope, {
        Name = "CharStatsPanel",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0.03, 1),
        Size = UDim2.fromScale(0.6, 7.3),
        ScrollBarThickness = 5,
        ScrollingDirection = Enum.ScrollingDirection.Y,

        [Children] = {
            Components.PaddingFrame(scope, "AAA"),

            Fusion.ForPairs(scope, props.StatList, function(_, scope: Fusion.Scope, index: number, val: {
                Id: string,
                Val: Fusion.Value
            })
                return index, Components.Frame(scope, {
                    Name = "BBB_"..val.Id,
                    BackgroundColor3 = Color3.fromRGB(),
                    BackgroundTransparency = if index % 2 == 0 then 0.1 else 0.6,
                    Size = UDim2.fromScale(1, 0.1),
                    LayoutOrder = index,

                    [Children] = {
                        Components.UIAspectRatioConstraint(scope, 21.063),

                        Components.TextLabel(scope, {
                            Name = "Title",
                            Position = UDim2.fromScale(0.02, 0),
                            Size = UDim2.fromScale(0.3, 1),
                            Text = val.Id,
                            TextXAlignment = Enum.TextXAlignment.Left,

                            [Children] = {
                                Components.UIPadding(scope, {
                                    PaddingTop = UDim.new(0.15, 0),
                                    PaddingBottom = UDim.new(0.15, 0),
                                    PaddingLeft = UDim.new(0, 0),
                                    PaddingRight = UDim.new(0, 0)
                                })
                            }
                        }),
                        Components.TextLabel(scope, {
                            Name = "Stat",
                            AnchorPoint = Vector2.xAxis,
                            Position = UDim2.fromScale(0.98, 0),
                            Size = UDim2.fromScale(0.3, 1),
                            TextXAlignment = Enum.TextXAlignment.Right,


                            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                local shouldUsePercent = false
                                if val.Id == "CRIT DMG" then
                                    shouldUsePercent = true
                                elseif string.find(val.Id, "CHANCE") then
                                    shouldUsePercent = true
                                end

                                if val.Id == "ATK" then
                                    return `{use(val.Val[1])}-{use(val.Val[2])}`
                                else
                                    return use(val.Val)..(if shouldUsePercent then "%" else "")
                                end
                            end),

                            [Children] = {
                                Components.UIPadding(scope, {
                                    PaddingTop = UDim.new(0.15, 0),
                                    PaddingBottom = UDim.new(0.15, 0),
                                    PaddingLeft = UDim.new(0, 0),
                                    PaddingRight = UDim.new(0, 0)
                                })
                            }
                        })
                    }
                })
            end)
        }

    }, {
        Padding = UDim.new(0, 0),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })
end
