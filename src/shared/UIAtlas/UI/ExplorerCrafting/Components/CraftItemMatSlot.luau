
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ItemBook = require(RepS.HarukaShared.Library.ItemBook)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    ItemId: string,
    Items: Fusion.Value<{ IntConstrainedValue }>,
    Amount: number,

    SelectedMaterialVal: Fusion.Value<string>,
})

    local itemInfo = ItemBook:GetItemInfo(props.ItemId)
    if not itemInfo then return nil end


    local isSelecting = Fusion.Value(scope, false)
    local totalAmount = Fusion.Value(scope, 0)

    local itemsObserver = Fusion.Observer(scope, props.Items)
    itemsObserver:onBind(function()
        local items = Fusion.peek(props.Items)
        local amount = 0

        for _, item: IntConstrainedValue in items do
            if item.Name == props.ItemId then
                amount += item.Value
            end
        end

        totalAmount:set(amount)
    end)


    return Components.IconImageLabel(scope, {
        Image = itemInfo.Icon,
        Selectable = true,
        SelectionOrder = 0,
        LayoutOrder = if props.ItemId == "GOLD" then 233 else 1,



        [Children] = {
            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.SelectedMaterialVal:set(props.ItemId)
                end,

                [Children] = {
                    Components.RoundUICorner(scope)
                }
            }),

            Components.ScaledUIStroke(scope, {
                Thickness = 0.05,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Components.TextLabel(scope, {
                Name = "Amount",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 1.1),
                Size = UDim2.fromScale(1.3, 0.5),
                FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `{use(totalAmount)}/{props.Amount}`
                end),
                TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(totalAmount) >= props.Amount then Color3.fromRGB(85, 255, 127) else Color3.fromRGB(255, 118, 117)
                end),


                [Children] = {
                    Components.ScaledTextUIStroke(scope, {})
                }
            }),

            Components.Frame(scope, {
                Name = "ItemName",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -0.7),
                Size = UDim2.fromScale(15, 0.5),

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end),

                [Children] = {
                    Components.TextLabel(scope, {
                        Name = "ItemName",
                        AnchorPoint = Vector2.new(0.5, 0),
                        AutomaticSize = Enum.AutomaticSize.X,
                        Position = UDim2.fromScale(0.5, 0),
                        Size = UDim2.fromScale(0, 1),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Components.WHITE_COLOR,

                        Text = itemInfo.Name,
                        TextColor3 = Components.BLACK_COLOR,

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.UIPadding(scope, {
                                PaddingLeft = UDim.new(0, 12),
                                PaddingRight = UDim.new(0, 12),
                                PaddingTop = UDim.new(0.05, 0),
                                PaddingBottom = UDim.new(0.05, 0)
                            })
                        }
                    })
                }
            }),


            Components.Frame(scope, {
                Name = "Tip",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromScale(0.5, 2.2),
                Size = UDim2.fromScale(4, 0.45),

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end),

                [Children] = {
                    Components.TextLabel(scope, {
                        Name = "ItemName",
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.fromScale(0.5, 0),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = Components.WHITE_COLOR,

                        Text = "Click icon for more info",
                        TextColor3 = Components.BLACK_COLOR,

                        [Children] = {
                            Components.RoundUICorner(scope),
                            Components.UIPadding(scope, {
                                PaddingLeft = UDim.new(0, 12),
                                PaddingRight = UDim.new(0, 12),
                                PaddingTop = UDim.new(0.05, 0),
                                PaddingBottom = UDim.new(0.05, 0)
                            })
                        }
                    })
                }
            })
        }
    })
end