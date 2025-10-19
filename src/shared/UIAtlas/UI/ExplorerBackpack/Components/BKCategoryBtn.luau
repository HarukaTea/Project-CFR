--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
    Category: string,
    Index: number,

    CurrentSelectedItemUniqueId: Fusion.Value<string>,
    CurrentSelectedItem: Fusion.Value<string>,
    CurrentCategory: Fusion.Value<string>,
})

    local ICONS = {
        Passive = "rbxassetid://118638433713167",
        Accessory = "rbxassetid://88279390879858",
        Active = "rbxassetid://81960931694446",
        Weapon = "rbxassetid://136867665323280",
        Material = "rbxassetid://132557711412384",
        Misc = "rbxassetid://139698715468743",

        Market = "rbxassetid://118291405899454",
        Sell = "rbxassetid://18421784947",

        Crafting = "rbxassetid://105673885617491",
        Gemstone = "rbxassetid://139698715468743",

        RoStore = "rbxassetid://135736394286615",
        RoLeaderboard = "rbxassetid://106569943333610",
    }
    local DEFAULT_COLOR = Color3.fromRGB(211, 188, 142)
    local COLORS = {
        Passive = DEFAULT_COLOR,
        Accessory = DEFAULT_COLOR,
        Active = DEFAULT_COLOR,
        Weapon = DEFAULT_COLOR,
        Material = DEFAULT_COLOR,
        Misc = DEFAULT_COLOR,

        Market = Color3.fromRGB(211, 217, 238),
        Sell = Color3.fromRGB(242, 170, 78),

        STR = DEFAULT_COLOR,
        DEX = DEFAULT_COLOR,
        INT = DEFAULT_COLOR,
        VIT = DEFAULT_COLOR,

        Crafting = Color3.fromRGB(255, 255, 255),
        Gemstone = DEFAULT_COLOR,

        RoStore = DEFAULT_COLOR,
        RoLeaderboard = DEFAULT_COLOR,
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
                ImageColor3 = Components.WHITE_COLOR,

                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),

                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(isSelecting) then UDim2.fromScale(1, 1) else UDim2.fromScale(0.9, 0.9)
                end), AssetBook.TweenInfos.threeHalf)
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
            })
        }
    })

    local bottomLineObserver = Fusion.Observer(scope, props.CurrentCategory)
    bottomLineObserver:onBind(function()
        local state = Fusion.peek(props.CurrentCategory) == props.Category
        if state then
            label.BottomLine.Size = UDim2.fromScale(0, 0.05)

            HarukaLib:CreateTween(label.BottomLine, AssetBook.TweenInfos.threeHalf, {
                Size = UDim2.fromScale(1, 0.05)
            }):Play()
        end
    end)

    return label
end