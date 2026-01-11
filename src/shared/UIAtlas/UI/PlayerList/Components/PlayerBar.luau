
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local CFEmblemTex = require(RepS.HarukaShared.UIAtlas.Components.CFEmblemTex)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    Player: Player,

    PlayerSelecting: Fusion.Value<Player?>,
    PlayerSelected: Fusion.Value<Player?>,
    PartyMembers: Fusion.Value<{ ObjectValue }>,
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
    local thatRoles = Components.FusionComponents.useChildren(scope, props.Player:WaitForChild("Roles"))
    local thatLevel = Value(1)

    table.insert(scope, HarukaLib:Hydrate(props.Player, {
        ["Attr-Class"] = function(class: string)
            thatClass:set(class)
        end,
        ["Attr-Level"] = function(level: number)
            thatLevel:set(level)
        end
    }))

    return Fusion.Hydrate(scope, Components:RefUI("PlayerBar_PL1_1", false, true))({
        Name = props.Player.Name,
        LayoutOrder = props.Index,

        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return if use(props.PlayerSelecting) == props.Player then Components.WHITE_COLOR else Components.BLACK_COLOR
        end),

        [Children] = {
            CFEmblemTex(scope, {
                Transparency = 0.94,
                Size = UDim2.fromScale(4, 4),
                Position = UDim2.fromScale(0.15, 0.5),

                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(props.PlayerSelecting) == props.Player then Components.BLACK_COLOR else Components.WHITE_COLOR
                end),
            }),

            Components.HoverImageButton(scope, {
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
            }),

            Fusion.Hydrate(scope, Components:RefUI("Main_PlayerBar1_1", false, true))({
                [Children] = {
                    Components.PaddingFrame(scope, "ZZZ"),

                    Fusion.Hydrate(scope, Components:RefUI("PlayerLevel_PB1_1", true))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return `Lv.{use(thatLevel)}`
                        end),
                        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return if use(props.PlayerSelecting) == props.Player then Components.BLACK_COLOR else Components.WHITE_COLOR
                        end),
                        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return if use(props.PlayerSelecting) == props.Player then Components.WHITE_COLOR else Components.BLACK_COLOR
                        end),
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("PlayerDisplayName_PB1_1"))({
                        Text = string.sub(props.Player.DisplayName, 1, 12),

                        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            if use(props.PlayerSelecting) == props.Player then
                                return Components.BLACK_COLOR
                            else
                                if table.find(use(props.PartyMembers), props.Player) then
                                    return Color3.fromHex('#81ecec')
                                end
                                if #use(thatRoles) > 0 then
                                    return Color3.fromHex('#ffeaa7')
                                end
                                return Components.WHITE_COLOR
                            end
                        end),
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("ClassIcon_PB1_1", true))({
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

                    Fusion.Hydrate(scope, Components:RefUI("Badges_PB1_1", true))({
                        [Children] = {
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
            })
        }
    })
end