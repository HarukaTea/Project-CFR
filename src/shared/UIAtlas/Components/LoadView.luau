--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Classbook = require(RepS.HarukaShared.Library.ClassBook)

local CAPatternTex = require(RepS.HarukaShared.UIAtlas.Components.CAPatternTex)

local Children = Fusion.Children



return function (scope: Fusion.Scope, props: {
    LoadingText: Fusion.Value,
})

    local texFrame = Components.Frame(scope, {
        Name = "CAPatternTexFrame",

        [Children] = {
            CAPatternTex(scope, {
                Transparency = 0.985,
                TileSize = UDim2.fromOffset(55, 55)
            })
        }
    })
    local texEmblem = Components.ImageLabel(scope, {
        Name = "Emblem",
        AnchorPoint = Vector2.new(0.5, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Position = UDim2.fromScale(0.5, -1),
        Size = UDim2.fromScale(1.5, 1.5),
        Image = "rbxassetid://109494337237105",
        ImageTransparency = 0.25,
        BackgroundTransparency = 0.25,

        [Children] = {
            Components.RoundUICorner(scope)
        }
    })


    local UI = Components.HarukaScreenGui(scope, {
        Name = "LoadScreen",
        DisplayOrder = UIPriorityBook.Highest - 2,
        Parent = Players.LocalPlayer.PlayerGui,

    }, {
        FullProps = {
            ZIndex = 0,
            BackgroundTransparency = 0,

            [Children] = {
                texFrame,

                Components.ImageLabel(scope, {
                    Name = "NoctuaryBorder",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Image = "rbxassetid://113507506875113",
                    ZIndex = 2
                })
            }
        },

        BottomProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "AllClasses",
                    AnchorPoint = Vector2.new(0.5, 0),
                    Size = UDim2.fromScale(0.95, 0.6),
                    Position = UDim2.fromScale(0.5, 0),
                    ClipsDescendants = true,

                    [Children] = {
                        Components.UIListLayout(scope, {
                            Padding = UDim.new(0.008, 0),
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            SortOrder = Enum.SortOrder.Name,
                        }),


                        Components.Frame(scope, {
                            Name = "AAA_AAALine",
                            BackgroundTransparency = 0.9,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Size = UDim2.fromScale(1, 0.1)
                        }),
                        Components.Frame(scope, {
                            Name = "ZZZ_AAALine",
                            BackgroundTransparency = 0.9,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Size = UDim2.fromScale(1, 0.1)
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
                }),

                Components.Frame(scope, {
                    Name = "CFEmblemTexFrame",

                    [Children] = {
                        texEmblem
                    }
                })
            }
        }
    })


    local tween = HarukaLib:CreateTween(texFrame, TweenInfo.new(30, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 999, true, 0), {
        Position = UDim2.new(0.5, 1500 / 1.5, 0.5, 1500 / 1.5),
        Size = UDim2.new(1, 1500 * 2, 1, 1500 * 2)
    })
    local tween2 = HarukaLib:CreateTween(texEmblem, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 999, false, 0), {
        Rotation = 360
    })
    table.insert(scope, function()
        tween:Cancel()
    end)
    table.insert(scope, function()
        tween2:Cancel()
    end)
    tween:Play()
    tween2:Play()


    return UI
end