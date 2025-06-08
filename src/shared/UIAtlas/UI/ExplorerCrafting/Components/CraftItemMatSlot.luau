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


    return Components.IconImageLabel(scope, {
        Image = itemInfo.Icon,

        [Children] = {
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
            })
        }
    })
end
