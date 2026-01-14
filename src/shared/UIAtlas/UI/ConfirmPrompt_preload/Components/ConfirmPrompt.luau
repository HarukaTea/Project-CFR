
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local UIPriorityBook = require(RepS.HarukaShared.Library.UIPriorityBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    ConfirmText: string,
    CancelText: string,
    Hint: string,

    ResultSignal: RBXScriptSignal,
})

    local absTextBGSize = Fusion.Value(scope, Vector2.zero)

    local UI; UI = Components.HarukaScreenGui(scope, {
		Name = "ConfirmPrompt",
		DisplayOrder = UIPriorityBook.System,

	}, {
        CenterChildren = {
            Fusion.Hydrate(scope, Components:RefUI("ConfirmPrompt_1", false, true, {
                "InnerFakeStroke", "Emblem"
            }))({
                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("BtnsFrame_CP1_1", false, true))({
                        [Fusion.Out("AbsoluteSize")] = absTextBGSize,

                        [Children] = {
                            ExecuteButton(scope, {
                                Id = "Confirm",
                                Size = UDim2.fromScale(0.45, 0.75),
                                ButtonText = props.ConfirmText,
                                ButtonType = "Confirm",
                                ButtonClickFunc = function()
                                    props.ResultSignal:Fire("YES")
                                end
                            }),
                            ExecuteButton(scope, {
                                Id = "Decline",
                                LayoutOrder = 2,
                                Size = UDim2.fromScale(0.45, 0.75),
                                ButtonText = props.CancelText,
                                ButtonType = "Cancel",
                                ButtonClickFunc = function()
                                    props.ResultSignal:Fire("NO")
                                end
                            })
                        }
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("Prompt_CP1_1"))({
                        TextSize = Fusion.Computed(scope, function(use: Fusion.Use)
                            return math.ceil(use(absTextBGSize).Y / (40 / 27))
                        end),
                        Text = HarukaLib:RichTextify(props.Hint)
                    })
                }
            })
        },

        FullProps = {
            BackgroundTransparency = 0.2,
			ZIndex = 0,
			Active = true
        }
    })

    return UI
end