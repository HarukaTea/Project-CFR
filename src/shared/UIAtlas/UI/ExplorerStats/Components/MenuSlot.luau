
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local Children = Fusion.Children

local Icons = {
    Backpack = "rbxassetid://87334829671948",
    Menu = "rbxassetid://130903046224988",
    Character = "rbxassetid://92862260655045",

    Settings = "rbxassetid://104944402116343",
    PerkTree = "rbxassetid://77981089608399",
    Guild = "rbxassetid://132493733644902",
    Stats = "rbxassetid://97344315886689",
    Trade = "rbxassetid://129768568967812",
    Store = "rbxassetid://73470004505046",
    Achievements = "rbxassetid://135736394286615",
    TutorialBook = "rbxassetid://105305190168965",

    Events = "rbxassetid://74645793775122",
}

return function(scope: Fusion.Scope<any>, props: {
    Slot: string,
    Index: number,

}, self: {
    plr: Player
})

    local isSelecting = Fusion.Value(scope, false)
    local key = nil

    local refreshBoolean = Fusion.Value(scope, false)
    table.insert(scope, KeybindsBook.OnKeybindChanged:Connect(function()
        refreshBoolean:set(not Fusion.peek(refreshBoolean))
    end))


    local realSlot = props.Slot
    if props.Slot == "Character" then
        realSlot = "CharSelfView"
    end

    if KeybindsBook.PC[realSlot] then
        key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope<any>)
            local boolean = use(refreshBoolean) :: boolean

            return Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = Vector2.one,
                AutomaticSize = Enum.AutomaticSize.X,
                Text = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.PC[realSlot].Name] or KeybindsBook.PC[realSlot].Name,
                Size = UDim2.fromScale(0.5, 0.5),
                Position = UDim2.fromScale(1.05, 1),
                BackgroundTransparency = 0,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        end)
    end

    local point = nil
    if props.Slot == "Character" then
        local hasPoint = Fusion.Value(scope, false)

        table.insert(scope, HarukaLib:Hydrate(Players.LocalPlayer, {
            ["Attr-PerkPoints"] = function(val: number)
                hasPoint:set(val > 0)
            end
        }))


        point = Components.ImageLabel(scope, {
            Name = "Hint",
            BackgroundColor3 = Color3.fromRGB(195, 0, 0),
            BackgroundTransparency = 0,
            AnchorPoint = Vector2.xAxis,
            Position = UDim2.fromScale(1.05, -0.1),
            Size = UDim2.fromScale(0.4, 0.4),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            ZIndex = 3,

            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(hasPoint)
            end),

            [Children] = {
                Components.RoundUICorner(scope),
                Components.TextLabel(scope, {
                    Name = "Attention",
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Heavy),
                    Text = "!"
                })
            }
        })
    end

    return Components.Frame(scope, {
        Name = props.Slot,
        BackgroundTransparency = 0,
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        LayoutOrder = props.Index,

        [Children] = {
            Components.RoundUICorner(scope),

            Components.IconImageLabel(scope, {
                Image = Icons[props.Slot],
            }),

            Components.UIStroke(scope, {
                Thickness = 2.5,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            key, point,

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    local plr = self.plr :: Player

                    local curUIGroup = plr:GetAttribute("CurrentUIGroup") :: string

                    if props.Slot == "Character" then
                        plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and "CharSelfView" or "None")
                        return
                    end

                    plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and props.Slot or "None")
                end,
            })
        }
    })
end