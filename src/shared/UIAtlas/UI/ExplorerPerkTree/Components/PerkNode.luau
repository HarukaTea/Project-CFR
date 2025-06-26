
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local PerkBook = require(RepS.HarukaShared.Library.PerkBook)

local IconShadeTex = require(RepS.HarukaShared.UIAtlas.Components.IconShadeTex)

local Children = Fusion.Children

return function (scope: Fusion.Scope, info: {
    IsSelecting: Fusion.Value,
    NodePos: UDim2,
    Index: number,

    Category: string,
}, props: {
    CurrentSelectedPerk: Fusion.Value,
    PerkPoints: { [string]: Fusion.Value }
})
    local NODE_SYMBOLS = {
        STR = "rbxassetid://134445989246357",
        INT = "rbxassetid://81020560446846",
        VIT = "rbxassetid://106075217220023",
    }


    local perkId = info.Category..info.Index :: string
    local perkInfo = PerkBook[info.Category][perkId]

    if not perkInfo then return nil end


    return Components.Frame(scope, {
        Name = "PerkNode",
        Size = UDim2.fromScale(0.16, 0.16),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        Position = info.NodePos,
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(),
        ZIndex = 2,

        [Children] = {
            Components.RoundUICorner(scope),

            Components.IconImageLabel(scope, {
                Image = NODE_SYMBOLS[info.Category] or "",

                ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local isSelecting = use(info.IsSelecting)
                    local isEnough = use(props.PerkPoints[info.Category]) >= perkInfo.Req

                    if isSelecting then return Color3.fromRGB(0, 255, 255) end
                    if isEnough then return Components.WHITE_COLOR end

                    return Color3.fromRGB(50, 50, 50)
                end)
            }),

            IconShadeTex(scope, {
                Transparency = 0.8,

                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local isSelecting = use(info.IsSelecting)
                    local isEnough = use(props.PerkPoints[info.Category]) >= perkInfo.Req

                    if isSelecting then return Color3.fromRGB(0, 255, 255) end
                    if isEnough then return Components.WHITE_COLOR end

                    return Color3.fromRGB(50, 50, 50)
                end)
            }),

            Components.TextLabel(scope, {
                Name = "Index",
                BackgroundColor3 = Components.WHITE_COLOR,
                BackgroundTransparency = 0,
                TextColor3 = Components.BLACK_COLOR,
                Text = info.Index,
                AnchorPoint = Vector2.one,
                Position = UDim2.fromScale(1, 1),
                Size = UDim2.fromScale(0.5, 0.5),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                AutoLocalize = false,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIStroke(scope, {
                        Color = Components.BLACK_COLOR,
                        Thickness = 3
                    })
                }
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    info.IsSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    info.IsSelecting:set(false)
                end,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if Fusion.peek(props.CurrentSelectedPerk) == perkId then
                        props.CurrentSelectedPerk:set(nil)
                        return
                    end

                    props.CurrentSelectedPerk:set(perkId)
                end,
            })
        }
    })
end
