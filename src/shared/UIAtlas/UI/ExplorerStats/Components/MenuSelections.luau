--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local fromScale = UDim2.fromScale


local SELECTION_ICONS = {
    TalentTree = "rbxassetid://77981089608399",
    Backpack = "rbxassetid://87334829671948",
    Menu = "rbxassetid://130903046224988",
    Character = "rbxassetid://130903046224988",

    Settings = "rbxassetid://104944402116343",
    PerkTree = "rbxassetid://77981089608399",
    Guild = "rbxassetid://132493733644902",
    Stats = "rbxassetid://97344315886689",
    Trade = "rbxassetid://129768568967812",
    Store = "rbxassetid://73470004505046",
    Achievements = "rbxassetid://135736394286615",
    TutorialBook = "rbxassetid://105305190168965",

    Empty = AssetBook.ExtraIcons.Unknown
}


local function SelectionSlot(scope: Fusion.Scope, props: {
    LayoutOrder: number,
    SelectionId: string,
    Title: string,

    MenuShownValue: Fusion.Value

}) : Frame

    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = props.SelectionId,
        LayoutOrder = props.LayoutOrder,
        SizeConstraint = Enum.SizeConstraint.RelativeYY,

        [Children] = {
            Components.UICorner(scope, { CornerRadius = UDim.new(0.05, 0) }),
            Components.UIStroke(scope, {
                Thickness = 2.5,

                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(isSelecting) then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(61, 61, 61)
                end),
            }),

            Components.ImageLabel(scope, {
                Name = "Icon",
                BackgroundTransparency = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.075),
                Size = UDim2.fromScale(0.6, 0.6),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                Image = SELECTION_ICONS[props.SelectionId] or AssetBook.ExtraIcons.Unknown,
                ImageColor3 = if props.SelectionId == "Empty" then Color3.fromRGB(110, 110, 110) else Color3.new(1, 1, 1),

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            }),
            Components.TextLabel(scope, {
                Name = "Title",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.72),
                Size = UDim2.fromScale(1, 0.2),
                RichText = true,

                Text = if props.SelectionId == "Empty" then "EMPTY" else `<u>{string.upper(props.Title)}</u>`,
                TextColor3 = if props.SelectionId == "Empty" then Color3.fromRGB(110, 110, 110) else Color3.new(1, 1, 1),
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if not props.MenuShownValue then return end

                    props.MenuShownValue:set(false)
                    Players.LocalPlayer:SetAttribute("CurrentUIGroup", props.SelectionId)
                end
            })
        }
    })
end
local function Selections(scope: Fusion.Scope, order: number, children: Fusion.Children) : Frame
    return Components.Frame(scope, {
        Name = "Selections_"..order,
        Size = fromScale(1, 0.45),
        LayoutOrder = order,

        [Children] = {
            Components.UIListLayout(scope, {
                Padding = UDim.new(0.05, 0),
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
            }),

            children
        }
    })
end

return function (scope: Fusion.Scope, props: {
    MenuShowValue: Fusion.Value,

}) : Frame
    return Components.Frame(scope, {
        Name = "MenuSelections",
        BackgroundTransparency = 0,
        Size = fromScale(0.41, 5),

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(props.MenuShowValue)
        end),

        [Children] = {
            Components.UICorner(scope, { CornerRadius = UDim.new(0.03, 0) }),
            Components.UIStroke(scope, {
                Color = Color3.fromRGB(61, 61, 61),
                Thickness = 4,
            }),

            Components.Frame(scope, {
                Name = "InnerComponent",
                Size = fromScale(0.95, 0.92),

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.07, 0),
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    }),

                    Selections(scope, 1, {
                        SelectionSlot(scope, {
                            LayoutOrder = 1,
                            SelectionId = "TutorialBook",
                            Title = "Tutorials",
                            MenuShownValue = props.MenuShowValue
                        }),
                        SelectionSlot(scope, {
                            LayoutOrder = 2,
                            SelectionId = "Guild",
                            Title = "Guild",
                            MenuShownValue = props.MenuShowValue
                        }),
                        SelectionSlot(scope, {
                            LayoutOrder = 3,
                            SelectionId = "Achievements",
                            Title = "Badges",
                            MenuShownValue = props.MenuShowValue
                        }),
                        SelectionSlot(scope, {
                            LayoutOrder = 4,
                            SelectionId = "Store",
                            Title = "Donations",
                            MenuShownValue = props.MenuShowValue
                        }),
                    }),
                    Selections(scope, 2, {
                        SelectionSlot(scope, {
                            LayoutOrder = 1,
                            SelectionId = "Empty",
                            Title = "Empty"
                        }),
                        SelectionSlot(scope, {
                            LayoutOrder = 2,
                            SelectionId = "Empty",
                            Title = "Empty"
                        }),
                        SelectionSlot(scope, {
                            LayoutOrder = 3,
                            SelectionId = "Empty",
                            Title = "Empty"
                        }),
                        SelectionSlot(scope, {
                            LayoutOrder = 4,
                            SelectionId = "Empty",
                            Title = "Empty"
                        })
                    })
                }
            })
        }

    })
end