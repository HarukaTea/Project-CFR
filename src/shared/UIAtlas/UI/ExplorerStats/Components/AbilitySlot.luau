
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local KeybindsBook = require(RepS.HarukaShared.Library.KeybindsBook)

local ProgressCircle = require(RepS.HarukaShared.UIAtlas.Components.ProgressCircle)

local Children = Fusion.Children

return function(scope: Fusion.Scope, props: {
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
    },

    ForcePosition: UDim2?,
    ForceSize: Fusion.Value<UDim2>?,

}, self: {
    plr: Player,

    RequestToDash: BindableEvent
})

    local isSelecting = Fusion.Value(scope, false)

    local lastInput = Components.FusionComponents.useXboxControllerHotInput(scope)
    local refreshBoolean = Fusion.Value(scope, false)
    table.insert(scope, KeybindsBook.OnKeybindChanged.Event:Connect(function()
        refreshBoolean:set(not Fusion.peek(refreshBoolean))
    end))

    local key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInput) :: string
        local boolean = use(refreshBoolean)

        boolean = boolean

        if input == "Controller" then
            local keybind = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.Console.Dash.Name]
                or KeybindsBook.Console.Dash.Name

            return Fusion.Hydrate(scope, Components:RefUI("Key_ActiveSlot1_1", true))({
                Text = keybind,
                TextColor3 = if AssetBook.XboxControllerColors[keybind] then
                    Color3.new() else Color3.new(1, 1, 1),
                BackgroundColor3 = if AssetBook.XboxControllerColors[keybind] then
                    AssetBook.XboxControllerColors[keybind] else Components.BLACK_COLOR,
            })
        elseif input == "Keyboard" then
            return Fusion.Hydrate(scope, Components:RefUI("Key_ActiveSlot1_1", true))({
                Text = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.PC.Dash.Name]
                    or KeybindsBook.PC.Dash.Name,
            })
        else
            return nil
        end
    end)

    return Fusion.Hydrate(scope, Components:RefUI("ActiveSlot_ActiveSlot1_1", false, false, {
        "UICorner",
    }))({
        Name = "Ability1",
        LayoutOrder = 0,
        Position = props.ForcePosition or UDim2.fromScale(0.5, 0.5),

        Size = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(props.ForceSize) or UDim2.fromScale(1.2, 1.2)
        end),

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.05,
                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    self.RequestToDash:Fire()
                end
            }),

            Components.IconImageLabel(scope, {
                Image = "rbxassetid://89411498131129"
            }),

            key,

            ProgressCircle(scope, {
                Direction = "Left",
                RotationVal = props.ActiveInfo.CDRotation,
            }),
            ProgressCircle(scope, {
                Direction = "Right",
                RotationVal = props.ActiveInfo.CDRotation,
            }),

            Fusion.Hydrate(scope, Components:RefUI("Cooldown_ActiveSlot1_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.ActiveInfo.Cooldown)
                end),
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if tonumber(use(props.ActiveInfo.Cooldown)) > 0 then true else false
                end),
            })
        }
    })
end