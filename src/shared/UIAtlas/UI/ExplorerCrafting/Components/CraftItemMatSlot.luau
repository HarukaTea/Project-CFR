--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local ItemLib = require(RepS.HarukaShared.Library.ItemLib)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    ItemId: string,
    Amount: number,
})

    local itemInfo = ItemLib:GetItemInfo(props.ItemId)
    if not itemInfo then return nil end


    local isSelecting = Fusion.Value(scope, false)


    return Components.IconImageLabel(scope, {
        Image = itemInfo.Icon,
        Selectable = true,
        SelectionOrder = 0,

        [Fusion.OnEvent("MouseEnter")] = function()
            isSelecting:set(true)
        end,
        [Fusion.OnEvent("MouseLeave")] = function()
            isSelecting:set(false)
        end,

        [Children] = {
            Components.UIStroke(scope, {
                Thickness = 2.5,

                Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(isSelecting)
                end)
            }),

            Components.TextLabel(scope, {
                Name = "Amount",
                Text = "x"..props.Amount,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, 1.1),
                Size = UDim2.fromScale(1, 0.5),
                FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),

                [Children] = {
                    Components.TextUIStroke(scope, {
                        Thickness = 3
                    })
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
            })
        }
    })
end
