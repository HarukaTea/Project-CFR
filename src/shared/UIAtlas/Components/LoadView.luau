--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)

local Classbook = require(RepS.HarukaShared.Library.ClassBook)

local CAPatternTex = require(RepS.HarukaShared.UIAtlas.Components.CAPatternTex)

local Children = Fusion.Children



return function (scope: Fusion.Scope, props: {
    LoadingText: Fusion.Value | string,
})
    return Components.HarukaScreenGui(scope, {
        Name = "LoadScreen",
        DisplayOrder = UIPriorityBook.Highest - 2,
        Parent = Players.LocalPlayer.PlayerGui,

    }, {
        FullProps = {
            ZIndex = 0,
            BackgroundTransparency = 0,

            [Children] = {
                CAPatternTex(scope, {
                    Transparency = 0.985,
                    TileSize = UDim2.fromOffset(55, 55)
                })
            }
        },

        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "AllClasses",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Size = UDim2.fromScale(1, 0.6),
                    Position = UDim2.fromScale(0.5, 0),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            Padding = UDim.new(0.005, 0),
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            SortOrder = Enum.SortOrder.Name,
                        }),

                        Fusion.ForPairs(scope, Classbook, function(_, scope: Fusion.Scope, classId: string, classInfo: { any })
                            if classInfo.DevClass then return classId, nil end


                            return classId, Components.IconImageLabel(scope, {
                                Name = classId,
                                Image = classInfo.Icon,
                                ImageColor3 = classInfo.Color
                            })
                        end)
                    }
                }),

                Components.Frame(scope, {
                    Name = "Tips",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Size = UDim2.fromScale(1, 0.6),
                    Position = UDim2.fromScale(0.5, -0.8),

                    [Children] = {
                        Components.TextLabel(scope, {
                            Name = "Desc",
                            Size = UDim2.fromScale(1, 0.8),
                            Text = Fusion.Computed(scope, function(use: Fusion.Use)
                                return use(props.LoadingText)
                            end),
                        })
                    }
                })
            }
        }
    })
end
