
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Events = require(RepS.HarukaShared.Library.Events)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    MerchantId: string,
    Price: number
})

    local blur = Instance.new("BlurEffect")
    blur.Enabled = true
    blur.Name = "UIBlur_TicketPurchase"
    blur.Parent = workspace.CurrentCamera

    local absDescSize = Fusion.Value(scope, Vector2.zero)

    local frame; frame = Fusion.Hydrate(scope, Components:RefUI("TicketPuchase_TPTicket1_1", false, true))({
        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Left_TPTicket1_1", false, true, {
                "TicketName"
            }))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("TicketDesc_TPTicket1_1"))({
                        TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(absDescSize).Y / (109 / 20)
                        end)
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("ItemIcon_TPTicket1_1", true))({
                        [Fusion.Out("AbsoluteSize")] = absDescSize,
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Right_TPTicket1_1", false, true))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("ItemPrice_TPTicket1_2", false, true, {
                        "Icon", "Title"
                    }))({
                        Fusion.Hydrate(scope, Components:RefUI("Price_TPTicket1_3"))({
                            Text = tostring(props.Price)
                        })
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("PurchaseButton_TPTicket1_2", true))({
                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            Events.BuyTicket_C.Fire(props.MerchantId)

                            if blur then blur:Destroy() end
                            if frame then frame:Destroy() end
                        end,
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("CloseButton_TPTicket1_2", true))({
                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            if blur then blur:Destroy() end
                            if frame then frame:Destroy() end
                        end,
                    }),
                }
            }),
        }
    })

    return frame, blur
end