
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local CFEmblemTex = require(RepS.HarukaShared.UIAtlas.Components.CFEmblemTex)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    Player: Player,

    PlayerSelecting: Fusion.Value<Player?>,
    PlayerSelected: Fusion.Value<Player?>,

    Index: number?,
})

    local joinOrder = props.Player:GetAttribute("JoinOrder") :: number
    props.Index = joinOrder or 1

    if props.Player == Players.LocalPlayer then
        props.Index = 0
    end


    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local thatClass = Value("Burst")
    local thatRoles = FusionComponents.useFolder(scope, (props.Player :: any):WaitForChild("Roles"))
    local thatLevel = Value(1)


    table.insert(scope, HarukaLib:Hydrate(props.Player, {
        ["Attr-Class"] = function(class: string)
            thatClass:set(class)
        end,
        ["Attr-Level"] = function(level: number)
            thatLevel:set(level)
        end
    }))


    return Components.Frame(scope, {
        Name = props.Player.Name,
        BackgroundTransparency = 0,
        LayoutOrder = props.Index,
        Size = UDim2.fromScale(0.97, 0.15),


        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return if use(props.PlayerSelecting) == props.Player then Components.WHITE_COLOR else Components.BLACK_COLOR
        end),


        [Children] = {
            Components.UIAspectRatioConstraint(scope, 12.43),

            Components.RoundUICorner(scope),

            Components.UIGradient(scope, {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.25, 1),
                    NumberSequenceKeypoint.new(0.5, 0),
                    NumberSequenceKeypoint.new(1, 0),
                })
            }),


            CFEmblemTex(scope, {
                Transparency = 0.94,
                Size = UDim2.fromScale(4, 4),
                Position = UDim2.fromScale(0.3, 0.5),

                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    if use(props.PlayerSelecting) == props.Player then
                        return Components.BLACK_COLOR
                    else
                        return Components.WHITE_COLOR
                    end
                end),
            }),


            Components.Frame(scope, {
                Name = "Main",

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.015, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    }),

                    Components.PaddingFrame(scope, "ZZZ"),


                    Components.TextLabel(scope, {
                        Name = "PlayerLevel",
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2.fromScale(0, 0.8),
                        BackgroundColor3 = Components.WHITE_COLOR,
                        BackgroundTransparency = 0,
                        LayoutOrder = 233,
                        TextColor3 = Components.BLACK_COLOR,

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `Lv.{use(thatLevel)}`
                        end),

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.UIPadding(scope, {
                                PaddingTop = UDim.new(0.05, 0),
                                PaddingBottom = UDim.new(0.05, 0),
                                PaddingLeft = UDim.new(0.05, 0),
                                PaddingRight = UDim.new(0.05, 0)
                            })
                        }
                    }),


                    Components.IconImageLabel(scope, {
                        Name = "ClassIcon",
                        Size = UDim2.fromScale(0.8, 0.8),
                        LayoutOrder = 232,

                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(thatClass) :: string

                            if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                            return ClassBook[classId].Icon
                        end),
                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(thatClass) :: string

                            if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                            return ClassBook[classId].Color
                        end),
                    }),

                    Components.TextLabel(scope, {
                        Name = "PlayerDisplayName",
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2.fromScale(0, 0.6),
                        LayoutOrder = 231,
                        RichText = true,
                        AutoLocalize = false,

                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            if use(props.PlayerSelecting) == props.Player then
                                return `<u>@{props.Player.Name}</u>`
                            else
                                return props.Player.DisplayName
                            end
                        end),
                        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            if use(props.PlayerSelecting) == props.Player then
                                return Components.BLACK_COLOR
                            else
                                return Components.WHITE_COLOR
                            end
                        end),
                    }),



                    Components.Frame(scope, {
                        Name = "Badges",
                        LayoutOrder = 1,
                        Size = UDim2.fromScale(0.7, 0.7),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,

                        [Children] = {
                            Components.UIListLayout(scope, {
                                Padding = UDim.new(0.1, 0),
                                FillDirection = Enum.FillDirection.Horizontal,
                                VerticalAlignment = Enum.VerticalAlignment.Center,
                                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                                SortOrder = Enum.SortOrder.Name
                            }),


                            Fusion.ForPairs(scope, thatRoles, function(_, scope: Fusion.Scope, index: number, role: BoolValue)
                                local ICONS = {
                                    Premium = "rbxassetid://102910527174929",
                                    Tester = "rbxassetid://96080257571120",
                                    Developer = "rbxassetid://120881617359401",
                                    ContentCreator = "rbxassetid://116819996832598",
                                    Translator = "rbxassetid://96745845908397"
                                }

                                return index, Components.IconImageLabel(scope, {
                                    Name = role.Name,
                                    LayoutOrder = index,

                                    Image = ICONS[role.Name or "None"] or AssetBook.ExtraIcons.Unknown,
                                })
                            end)
                        }
                    })
                }
            }),

            Components.HoverImageButton(scope, {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.fromScale(0.7, 1),
                ZIndex = 10,


                [Fusion.OnEvent("MouseEnter")] = function()
                    props.PlayerSelecting:set(props.Player)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    props.PlayerSelecting:set(nil)
                end,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if Fusion.peek(props.PlayerSelected) == props.Player then
                        props.PlayerSelected:set(nil)
                        return
                    end

                    props.PlayerSelected:set(props.Player)
                end
            })
        }
    })
end