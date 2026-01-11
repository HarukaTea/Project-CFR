
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)


local IconShadeTex = require(RepS.HarukaShared.UIAtlas.Components.IconShadeTex)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Category: string,
    Index: number,

    CurrentSelectedItemUniqueId: Fusion.Value<string>,
    CurrentSelectedItem: Fusion.Value<string>,
    CurrentCategory: Fusion.Value<string>,
})

    local ICONS = {
        Artifact = "rbxassetid://118638433713167",
        Accessory = "rbxassetid://88279390879858",
        Active = "rbxassetid://81960931694446",
        Weapon = "rbxassetid://136867665323280",
        Material = "rbxassetid://132557711412384",
        Misc = "rbxassetid://139698715468743",
    }
    local COLORS = {
        Artifact = Color3.fromRGB(85, 170, 255),
        Accessory = Color3.fromRGB(255, 170, 127),
        Active = Color3.fromRGB(170, 255, 255),
        Weapon = Color3.fromRGB(255, 85, 127),
        Material = Color3.fromRGB(85, 85, 127),
        Misc = Color3.fromRGB(255, 255, 255),
    }

    local isSelecting = Fusion.Value(scope, false)

    local label = Components.Frame(scope, {
        Name = props.Category,
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        LayoutOrder = props.Index,

        [Children] = {
            Components.RoundUICorner(scope),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.CurrentSelectedItem:set("")
                    props.CurrentSelectedItemUniqueId:set("")
                    props.CurrentCategory:set(props.Category)
                end
            }),


            Components.IconImageLabel(scope, {
                Image = ICONS[props.Category],
                ImageColor3 = COLORS[props.Category],

                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),

                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(isSelecting) then UDim2.fromScale(1, 1) else UDim2.fromScale(0.9, 0.9)
                end), Components.TweenInfos.threeHalf)
            }),


            Components.Frame(scope, {
                Name = "BottomLine",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 1.2),
                Size = UDim2.fromScale(1, 0.05),
                BackgroundTransparency = 0,
                BackgroundColor3 = COLORS[props.Category],

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.CurrentCategory) == props.Category
                end)
            }),

            IconShadeTex(scope, {
                Color = COLORS[props.Category],
                Transparency = 0.7,

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.CurrentCategory) == props.Category
                end)
            })
        }
    })

    local bottomLineObserver = Fusion.Observer(scope, props.CurrentCategory)
    bottomLineObserver:onBind(function()
        local state = Fusion.peek(props.CurrentCategory) == props.Category
        if state then
            label.BottomLine.Size = UDim2.fromScale(0, 0.05)

            HarukaLib:CreateTween(label.BottomLine, Components.TweenInfos.threeHalf, {
                Size = UDim2.fromScale(1, 0.05)
            }):Play()
        end
    end)

    return label
end