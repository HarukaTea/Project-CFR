--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local PerkBook = require(RepS.HarukaShared.Library.PerkBookV2)

local IconShadeTex = require(RepS.HarukaShared.UIAtlas.Components.IconShadeTex)

local Children = Fusion.Children



local NODE_SYMBOLS = {
    root1 = "",

    phy1 = "",
    phy2 = "",
    phy3 = "",
    phy4 = "",
    phy1_branch = "",
    phy2_branch = "",
    phy3_branch = "",

    magic1 = "",
    magic2 = "",
    magic3 = "",
    magic4 = "",
    magic1_branch = "",
    magic2_branch = "",
    magic3_branch = "",

    universal1 = "",
    universal2 = "",
    universal3 = "",
}

return function (scope: Fusion.Scope, info: {
    IsSelecting: Fusion.Value,
    NodePos: UDim2,
    PerkId: string
}, props: {
    CurrentSelectedPerk: Fusion.Value,
    Talents: Fusion.Value
})
    local perkInfo = PerkBook.FindPerk(info.PerkId)
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
                Image = NODE_SYMBOLS[info.PerkId] or "",

                ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local isSelecting = use(info.IsSelecting)
                    local isUnlocked = false

                    for _, talent: BoolValue in use(props.Talents) do
                        if talent.Name == info.PerkId then
                            isUnlocked = true
                            break
                        end
                    end

                    if isSelecting then return Color3.fromRGB(0, 255, 255) end
                    if isUnlocked then return Components.WHITE_COLOR end

                    return Color3.fromRGB(50, 50, 50)
                end)
            }),

            IconShadeTex(scope, {
                Transparency = 0.8,

                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local isSelecting = use(info.IsSelecting)
                    local isUnlocked = false

                    for _, talent: BoolValue in use(props.Talents) do
                        if talent.Name == info.PerkId then
                            isUnlocked = true
                            break
                        end
                    end

                    if isSelecting then return Color3.fromRGB(0, 255, 255) end
                    if isUnlocked then return Components.WHITE_COLOR end

                    return Color3.fromRGB(50, 50, 50)
                end)
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    info.IsSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    info.IsSelecting:set(false)
                end,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if Fusion.peek(props.CurrentSelectedPerk) == info.PerkId then
                        props.CurrentSelectedPerk:set(nil)
                        return
                    end

                    props.CurrentSelectedPerk:set(info.PerkId)
                end,
            })
        }
    })
end