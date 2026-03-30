
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

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
    },

    ForcePosition: UDim2?,
    ForceSize: Fusion.Value<UDim2>?,

    IsMobile: boolean,

}, self: {
    plr: Player,

    RequestToCastItem: BindableEvent
})

    local isSelecting = Fusion.Value(scope, false)
    local amount = Fusion.Value(scope, 1)

    local subscribeAdd, subscribeEmpty = HarukaLib.Bin()
    table.insert(scope, subscribeEmpty)

    local refreshBoolean = Fusion.Value(scope, false)
    table.insert(scope, KeybindsBook.OnKeybindChanged.Event:Connect(function()
        refreshBoolean:set(not Fusion.peek(refreshBoolean))
    end))

    local amountUI = nil
    if props.IsMobile then
        amountUI = Fusion.Hydrate(scope, Components:RefUI("AmountMobile_ActiveSlot1_1", true))({
            Name = "Amount",

            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return `x{use(amount)}`
            end),
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(amount) > 1
            end),
        })
    else
        amountUI = Fusion.Hydrate(scope, Components:RefUI("AmountPC_ActiveSlot1_1", true))({
            Name = "Amount",

            Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return `x{use(amount)}`
            end),
            Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                return use(amount) > 1
            end),
        })
    end

    local lastInput = Components.FusionComponents.useXboxControllerHotInput(scope)
    local key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInput) :: string
        local boolean = use(refreshBoolean)

        boolean = boolean

        if input == "Controller" then
            local keybind = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.Console["Active"..props.Index].Name]
                or KeybindsBook.Console["Active"..props.Index].Name

            return Fusion.Hydrate(scope, Components:RefUI("Key_ActiveSlot1_1", true))({
                Text = keybind,
                TextColor3 = if AssetBook.XboxControllerColors[keybind] then
                    Color3.new() else Color3.new(1, 1, 1),
                BackgroundColor3 = if AssetBook.XboxControllerColors[keybind] then
                    AssetBook.XboxControllerColors[keybind] else Components.BLACK_COLOR,
            })

        elseif input == "Keyboard" then
            return Fusion.Hydrate(scope, Components:RefUI("Key_ActiveSlot1_1", true))({
                Text = KeybindsBook.KEYBIND_ID_NAMES[KeybindsBook.PC["Active"..props.Index].Name]
                    or KeybindsBook.PC["Active"..props.Index].Name,
            })
        else
            return nil
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

    return Fusion.Hydrate(scope, Components:RefUI("ActiveSlot_ActiveSlot1_1", false, false, {
        "UICorner",
    }))({
        LayoutOrder = if props.Index == 3 then 159 else props.Index,
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
            amountUI,

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