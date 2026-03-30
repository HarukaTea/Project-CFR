
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

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
    Donation = "rbxassetid://73470004505046",
    Achievements = "rbxassetid://135736394286615",
    TutorialBook = "rbxassetid://105305190168965",

    Empty = AssetBook.ExtraIcons.Unknown
}

local function SelectionSlot(scope: Fusion.Scope, props: {
    LayoutOrder: number,
    SelectionId: string,
    Title: string,

    MenuShownValue: Fusion.Value<boolean>?

}) : Frame

    local isSelecting = Fusion.Value(scope, false)

    return Fusion.Hydrate(scope, Components:RefUI("SelectionSlot_MSPStats1_3", false, false, {
        "UICorner"
    }))({
        Name = props.SelectionId,
        LayoutOrder = props.LayoutOrder,

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.025,
                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(isSelecting) then Color3.fromRGB(255, 255, 255) else Color3.fromRGB(61, 61, 61)
                end),
            }),

            Fusion.Hydrate(scope, Components:RefUI("Icon_MSPStat1_3", true))({
                Image = SELECTION_ICONS[props.SelectionId] or AssetBook.ExtraIcons.Unknown,
                ImageColor3 = if props.SelectionId == "Empty" then Color3.fromRGB(110, 110, 110) else Color3.new(1, 1, 1),
            }),
            Fusion.Hydrate(scope, Components:RefUI("Title_MSPStat1_3", true))({
                Text = if props.SelectionId == "Empty" then "EMPTY" else `<u>{string.upper(props.Title)}</u>`,
                TextColor3 = if props.SelectionId == "Empty" then Color3.fromRGB(110, 110, 110) else Color3.new(1, 1, 1),
            }),

            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if not props.MenuShownValue then return end

                    props.MenuShownValue:set(false)
                    Players.LocalPlayer:SetAttribute("CurrentUIGroup", props.SelectionId)
                end
            })
        }
    })
end
local function Selections(scope: Fusion.Scope, order: number, children: any) : Frame
    return Fusion.Hydrate(scope, Components:RefUI("Selections1_MSPStats1_2", false, true))({
        Name = "Selections_"..order,
        LayoutOrder = order,

        [Children] = {
            children
        }
    })
end

return function (scope: Fusion.Scope, props: {
    MenuShowValue: Fusion.Value<boolean>,

}) : Frame
    return Fusion.Hydrate(scope, Components:RefUI("MenuSelections_PStats1_1", false, true))({
        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(props.MenuShowValue)
        end),

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("InnerComponent_MSPStats1_1", false))({
                [Children] = {
                    Selections(scope, 1, {
                        SelectionSlot(scope, {
                            LayoutOrder = 1,
                            SelectionId = "Achievements",
                            Title = "Badges",
                            MenuShownValue = props.MenuShowValue
                        }),
                        SelectionSlot(scope, {
                            LayoutOrder = 2,
                            SelectionId = "Donation",
                            Title = "Donations",
                            MenuShownValue = props.MenuShowValue
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