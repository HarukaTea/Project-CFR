--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)


local ProgressCircle = require(RepS.HarukaShared.UIAtlas.Components.ProgressCircle)

local Children = Fusion.Children


local CONTROLLER_KEYS = {
    [1] = "L1",
    [2] = "R1",
    [3] = "R2"
}

return function(scope: Fusion.Scope, props: {
    Index: number,
    ActiveInfo: table

}, self: table)

    local isSelecting = Fusion.Value(scope, false)
    local amount = Fusion.Value(scope, 1)

    local subscribeAdd, subscribeEmpty = HarukaLib.Bin()
    table.insert(scope, subscribeEmpty)


    local lastInput = FusionComponents.useXboxControllerHotInput(scope)
    local key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInput) :: string

        if input == "Keyboard" then
            return Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = Vector2.one,
                Text = props.Index,
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

        elseif input == "Controller" then
            return Components.TextLabel(scope, {
                Name = "Key",
                AnchorPoint = Vector2.one,
                Text = CONTROLLER_KEYS[props.Index],
                Size = UDim2.fromScale(0.6, 0.4),
                Position = UDim2.fromScale(1.05, 1),
                BackgroundTransparency = 0,
                ZIndex = 10,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.UIPadding(scope, {})
                }
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
        local hasItem = ItemLib:GetItemInfo(item)
        if not hasItem then return end
        if not self.plr.Items:FindFirstChild(item) then return end

        subscribeAdd(HarukaLib:Hydrate(self.plr.Items[item], {
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
                    self.RequestToCastItem:Fire(props.Index)
                end
            }),

            Components.IconImageLabel(scope, {
                Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    local itemId = use(props.ActiveInfo.ItemId)
                    if itemId == "None" then
                        return AssetBook.ExtraIcons.Null
                    end

                    local itemInfo = ItemLib:GetItemInfo(itemId)
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
                    Components.TextUIStroke(scope, {
                        Thickness = 2.5
                    })
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
