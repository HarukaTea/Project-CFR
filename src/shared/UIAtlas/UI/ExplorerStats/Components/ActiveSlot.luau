
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local Signal = require(RepS.HarukaShared.Shared.Signal)


local ProgressCircle = require(RepS.HarukaShared.UIAtlas.Components.ProgressCircle)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local Children = Fusion.Children


return function(scope: Fusion.Scope, props: {
    Index: number,
    ActiveInfo: {
        Id: string,
        CDSymbol: NumberValue,
        Cooldown: Fusion.Value<string>,
        CDRotation: Fusion.Value<number>,

        ItemId: Fusion.Value<string>,
        ItemUniqueId: Fusion.Value<string>,

        CastCD: boolean,
        DisplayOrder: number,
        KeyDisplay: string
    }

}, self: {
    plr: Player,

    RequestToCastItem: Signal.SignalClass
})

    local isSelecting = Fusion.Value(scope, false)
    local amount = Fusion.Value(scope, 1)

    local subscribeAdd, subscribeEmpty = HarukaLib.Bin()
    table.insert(scope, subscribeEmpty)


    local refreshBoolean = Fusion.Value(scope, false)
    table.insert(scope, KeybindsBook.OnKeybindChanged:Connect(function()
        refreshBoolean:set(not Fusion.peek(refreshBoolean))
    end))


    local lastInput = Components.FusionComponents.useXboxControllerHotInput(scope)
    local key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInput) :: string
        local boolean = use(refreshBoolean)

        if input == "Controller" then
            local keybind = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.Console["Active"..props.Index].Name] or KeybindsBook.Console["Active"..props.Index].Name

            return Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = Vector2.one,
                Text = keybind,
                TextColor3 = if AssetBook.XboxControllerColors[keybind] then Color3.new() else Color3.new(1, 1, 1),
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0.6, 0.4),
                Position = UDim2.fromScale(1.05, 1),
                BackgroundTransparency = 0,
                BackgroundColor3 = if AssetBook.XboxControllerColors[keybind] then AssetBook.XboxControllerColors[keybind] else Components.BLACK_COLOR,
                ZIndex = 10,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        else
            return Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = Vector2.one,
                Text = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.PC["Active"..props.Index].Name] or KeybindsBook.PC["Active"..props.Index].Name,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0.4, 0.4),
                Position = UDim2.fromScale(1.05, 1),
                BackgroundTransparency = 0,
                ZIndex = 10,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold),

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        end
    end)


    local itemObserver = Fusion.Observer(scope, props.ActiveInfo.ItemId)
    itemObserver:onBind(function()
        subscribeEmpty()

        amount:set(1)

        local item = Fusion.peek(props.ActiveInfo.ItemId) :: string
        local hasItem = ItemBook:GetItemInfo(item)
        if not hasItem then return end


        local plr = self.plr :: Player
        if not plr.Items:FindFirstChild(item) then return end

        subscribeAdd(HarukaLib:Hydrate(plr.Items[item], {
            ["Prop-Value"] = function(val: number)
                amount:set(val)
            end
        }))
    end)


    return Components.Frame(scope, {
        Name = "Active"..props.Index,
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(1.2, 1.2),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        LayoutOrder = if props.Index == 3 then 159 else props.Index,


        [Children] = {
            Components.RoundUICorner(scope),

            Components.ScaledUIStroke(scope, {
                Thickness = 0.05,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                   isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                   isSelecting:set(false)
                end,

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    self.RequestToCastItem:Fire(props.Index)
                end
            }),

            Components.IconImageLabel(scope, {
                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local itemId = use(props.ActiveInfo.ItemId)
                    if itemId == "None" then
                        return AssetBook.ExtraIcons.Null
                    end

                    local itemInfo = ItemBook:GetItemInfo(itemId)
                    if not itemInfo then
                        return AssetBook.ExtraIcons.Unknown
                    end

                    return itemInfo.Icon
                end),
            }),

            key,

            Components.TextLabel(scope, {
                Name = "Amount",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -0.45),
                Size = UDim2.fromScale(1, 0.425),
                FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `x{use(amount)}`
                end),
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(amount) > 1
                end),


                [Children] = {
                    Components.ScaledTextUIStroke(scope, {})
                }
            }),


            Components.TextLabel(scope, {
                Name = "Cooldown",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                BackgroundTransparency = 0.6,
                ZIndex = 2,
                FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.ActiveInfo.Cooldown)
                end),
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if tonumber(use(props.ActiveInfo.Cooldown)) > 0 then true else false
                end),

                [Children] = {
                    Components.RoundUICorner(scope),

                    Components.UIPadding(scope, {
                        PaddingTop = UDim.new(0.22, 0),
                        PaddingLeft = UDim.new(0.22, 0),
                        PaddingRight = UDim.new(0.22, 0),
                        PaddingBottom = UDim.new(0.22, 0),
                    }),

                    Components.ScaledTextUIStroke(scope, {})
                },
            }),


            ProgressCircle(scope, {
                Direction = "Left",
                RotationVal = props.ActiveInfo.CDRotation,
            }),
            ProgressCircle(scope, {
                Direction = "Right",
                RotationVal = props.ActiveInfo.CDRotation,
            })
        }
    })
end