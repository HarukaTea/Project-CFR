--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

local Icons = {
    Backpack = "rbxassetid://87334829671948",
    Menu = "rbxassetid://130903046224988",
    Character = "rbxassetid://130903046224988",

    Settings = "rbxassetid://104944402116343",
    PerkTree = "rbxassetid://77981089608399",
    Guild = "rbxassetid://132493733644902",
    Stats = "rbxassetid://97344315886689",
    Trade = "rbxassetid://129768568967812",
    Store = "rbxassetid://84845838429032",
}
local Keys = {
    Backpack = "B",
    Character = "C",
    PerkTree = "Z",
    Settings = "N",
    Guild = "X",
    Store = "V"
}

return function(scope: Fusion.Scope, props: {
    Slot: string,
    Index: number,

}, self: table)

    local isSelecting = Fusion.Value(scope, false)

    local key = nil
    if Keys[props.Slot] then
        key = Components.TextLabel(scope, {
            Name = "Key",
            AnchorPoint = Vector2.one,
            Text = Keys[props.Slot],
            Size = UDim2.fromScale(0.5, 0.5),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Position = UDim2.fromScale(1.05, 1),
            BackgroundTransparency = 0,

            [Children] = {
                Components.RoundUICorner(scope),
                Components.UIPadding(scope, {})
            }
        })
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
                    local curUIGroup = self.plr:GetAttribute("CurrentUIGroup") :: string

                    if props.Slot == "Backpack" then
                        self.plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and "Backpack" or "None")

                    elseif props.Slot == "Character" then
                        self.plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and "CharSelfView" or "None")

                    elseif props.Slot == "PerkTree" then
                        self.plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and "PerkTree" or "None")

                    elseif props.Slot == "Guild" then
                        self.plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and "Guild" or "None")

                    elseif props.Slot == "Store" then
                        self.plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and "Store" or "None")

                    elseif props.Slot == "Settings" then
                        self.plr:SetAttribute("CurrentUIGroup", curUIGroup == "None" and "Settings" or "None")
                    end
                end,
            })
        }
    })
end
