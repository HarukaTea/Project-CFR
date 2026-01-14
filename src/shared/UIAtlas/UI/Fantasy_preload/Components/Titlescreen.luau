
local RepS = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    SlotUISignal: BindableEvent,
    CutsceneUISignal: BindableEvent
}) : ScreenGui

    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local isShown = Value(true)

    table.insert(scope, props.CutsceneUISignal.Event:Connect(function()
        isShown:set(true)
    end))
    table.insert(scope, props.SlotUISignal.Event:Connect(function()
        isShown:set(false)
    end))

    local isSelecting = Value(false)
    local isSelectingGroupFrame = Value(false)

    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "OuterTitlescreen",
        DisplayOrder = 233,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
            return use(isShown)
        end),

    }, {
        BottomChildren = {
            Fusion.Hydrate(scope, Components:RefUI("Logo_CFTitle1_1"))({}),

            Fusion.Hydrate(scope, Components:RefUI("PressAnyKey_CFTitle1_1", false, true))({
                BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return if use(isSelecting) then Components.WHITE_COLOR else Components.BLACK_COLOR
                end),

                [Children] = {
                    Components.HoverImageButton(scope, {
                        Components.ConnectSelectEvents(isSelecting),

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            props.SlotUISignal:Fire()
                        end
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("Tip_CFTitle1_1", true))({
                        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                            return if use(isSelecting) then Color3.new() else Components.WHITE_COLOR
                        end)
                    })
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Group_CFTitle1_1", false, false, {
                "UICorner", "Icon", "Tip", "Awards"
            }))({
                [Children] = {
                    Components.ScaledUIStroke(scope, {
                        Thickness = 0.035,

                        Enabled = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(isSelectingGroupFrame)
                        end)
                    }),
                    Components.HoverImageButton(scope, {
                        Components.ConnectSelectEvents(isSelectingGroupFrame),

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            pcall(function()
                                GroupService:PromptJoinAsync(16912246)
                            end)
                        end
                    })
                }
            })
        }
    })

    return UI
end