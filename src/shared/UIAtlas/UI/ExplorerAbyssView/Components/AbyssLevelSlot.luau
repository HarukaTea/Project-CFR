
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local AbyssTeambook = require(RepS.HarukaShared.Library.AbyssTeambook)

local CAPatternTex = require(RepS.HarukaShared.UIAtlas.Components.CAPatternTex)

local Children = Fusion.Children


return function(scope: Fusion.Scope, props: {
    Index: number,
    AbyssIndexSelected: Fusion.Value<number>,
    IsInfoUI: boolean
})

    if not AbyssTeambook[props.Index] then return nil end

    local isSelecting = Fusion.Value(scope, false)


    local aspectRatioConstraint = Components.UIAspectRatioConstraint(scope, 0.325)
    if props.IsInfoUI then
        aspectRatioConstraint = nil
    end

    return Components.Frame(scope, {
        Name = "AbyssLevelSlot"..props.Index,
        LayoutOrder = props.Index,
        Size = UDim2.fromScale(0.08, 0.9),
        BackgroundColor3 = Components.BLACK_COLOR,
        BackgroundTransparency = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0.2, 0.5),

        [Children] = {
            Components.RoundUICorner(scope),
            Components.UIStroke(scope, {
                Thickness = 3,

                Color = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local isSelectingState = use(isSelecting)

                    if isSelectingState then return Color3.fromHex('#66d9e8') end

                    return Components.WHITE_COLOR
                end)
            }),
            aspectRatioConstraint,


            CAPatternTex(scope, {
                Transparency = 0.975,
                TileSize = UDim2.fromOffset(35, 35)
            }),
            Components.ImageLabel(scope, {
                Name = "HighlightTex",
                AnchorPoint = Vector2.new(0.5, 1),
                ZIndex = 0,
                Position = UDim2.fromScale(0.5, 1.08),
                Size = UDim2.fromScale(0.15, 0.15),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Image = "rbxassetid://107834707321540",
                ImageColor3 = Color3.fromRGB(255, 0, 0),
            }),


            Components.IconImageLabel(scope, {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 0.1),
                Size = UDim2.fromScale(0.7, 0.7),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                Image = AbyssTeambook[props.Index].Icon or "",
            }),

            Components.TextLabel(scope, {
                Name = "Level",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromScale(0.5, 0.9),
                Size = UDim2.fromScale(0.5, 0.5),
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                Text = tostring(props.Index),
                AutoLocalize = false
            }),


            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    if props.IsInfoUI then return end

                    props.AbyssIndexSelected:set(props.Index)
                end,
            })
        }
    })
end