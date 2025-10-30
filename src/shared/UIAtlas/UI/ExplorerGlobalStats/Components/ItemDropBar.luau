
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function(scope: Fusion.Scope<any>, props: {
    ItemId: string,
    Amount: number
})

    local itemInfo = ItemBook:GetItemInfo(props.ItemId)
    if itemInfo == nil then
        warn(`Lacking of item info for drops: {props.ItemId}`)
        return nil
    end


    local bar = Components.Frame(scope, {
        Name = "ItemDrop_"..props.ItemId,
        Size = UDim2.fromScale(0.25, 0.65),
        BackgroundTransparency = 0,

        BackgroundColor3 = AssetBook.ItemTierColors[itemInfo.Tier],

        [Children] = {
            Components.UIGradient(scope, {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.2, 0.55),
                    NumberSequenceKeypoint.new(0.8, 0.55),
                    NumberSequenceKeypoint.new(1, 1)
                })
            }),

            Components.UIListLayout(scope, {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0.025, 0),
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            Components.IconImageLabel(scope, {
                Size = UDim2.fromScale(0.8, 0.8),
                LayoutOrder = 1,

                Image = itemInfo.Icon
            }),

            Components.TextLabel(scope, {
                Name = "ItemName",
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 0.7),
                LayoutOrder = 2,

                Text = itemInfo.Name
            }),

            Components.TextLabel(scope, {
                Name = "SmallAmountTitle",
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 0.7),
                LayoutOrder = 3,

                Text = "x",
                TextColor3 = Color3.fromRGB(188, 188, 188)
            }),

            Components.TextLabel(scope, {
                Name = "Amount",
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 0.85),
                LayoutOrder = 4,
                FontFace = Font.fromName("TitilliumWeb", Enum.FontWeight.Bold),

                Text = props.Amount,
            }),
        }
    })

    return bar
end