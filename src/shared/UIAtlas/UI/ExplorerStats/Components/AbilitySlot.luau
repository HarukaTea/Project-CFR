
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)


local Signal = require(RepS.HarukaShared.Shared.Signal)


local ProgressCircle = require(RepS.HarukaShared.UIAtlas.Components.ProgressCircle)

local Children = Fusion.Children

return function(scope: Fusion.Scope<any>, props: {
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

    RequestToDash: Signal.SignalClass
})

    local isSelecting = Fusion.Value(scope, false)


    local lastInput = FusionComponents.useXboxControllerHotInput(scope)
    local refreshBoolean = Fusion.Value(scope, false)
    table.insert(scope, KeybindsBook.OnKeybindChanged:Connect(function()
        refreshBoolean:set(not Fusion.peek(refreshBoolean))
    end))


    local key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope<any>)
        local input = use(lastInput) :: string
        local boolean = use(refreshBoolean)

        if input == "Controller" then
            local keybind = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.Console.Dash.Name] or KeybindsBook.Console.Dash.Name


            return Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = Vector2.one,
                Text = keybind,
                Size = UDim2.fromScale(0.4, 0.4),
                Position = UDim2.fromScale(1.05, 1),
                BackgroundTransparency = 0,
                BackgroundColor3 = if AssetBook.XboxControllerColors[keybind] then AssetBook.XboxControllerColors[keybind] else Components.BLACK_COLOR,
                TextColor3 = if AssetBook.XboxControllerColors[keybind] then Color3.new() else Color3.new(1, 1, 1),
                ZIndex = 10,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
            })
        else
            return Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = Vector2.one,
                Text = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.PC.Dash.Name] or KeybindsBook.PC.Dash.Name,
                Size = UDim2.fromScale(0.4, 0.4),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
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


    return Components.Frame(scope, {
        Name = "Ability1",
        BackgroundTransparency = 0,
        Size = UDim2.fromScale(1.2, 1.2),
        SizeConstraint = Enum.SizeConstraint.RelativeYY,
        LayoutOrder = 0,


        [Children] = {
            Components.RoundUICorner(scope),

            Components.UIStroke(scope, {
                Thickness = 2.5,

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
                    self.RequestToDash:Fire()
                end
            }),

            Components.IconImageLabel(scope, {
                Image = "rbxassetid://89411498131129"
            }),

            key,

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

                    Components.TextUIStroke(scope, { Thickness = 2.8 })
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