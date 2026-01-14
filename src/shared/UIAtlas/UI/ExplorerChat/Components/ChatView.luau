
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local BL = {
    ["That Bird With A Couple Lines Of Dialogue"] = true
}

return function (scope: Fusion.Scope, props: {
    IsChatShown: Fusion.Value<boolean>,

    ChoiceList: Fusion.Value<{ string }>,
    Dialogue: Fusion.Value<string>,
    MaxUTFShown: Fusion.Value<number>,

    Speaker: Fusion.Value<string>,
    NPCId: Fusion.Value<string>,
    IsTypewriting: Fusion.Value<boolean>,

    GoToNextDialogueSignal: BindableEvent,
    GoToNextDialogueByChoiceSignal: BindableEvent,
    GoSkipDialogueSignal: BindableEvent,
})

    local absDialogueSize = Fusion.Value(scope, Vector2.zero)

    local lastInputType = Components.FusionComponents.useXboxControllerHotInput(scope)
    local key = nil

    key = Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
        local input = use(lastInputType) :: string

        if input == "Controller" then
            return Fusion.Hydrate(scope, Components:RefUI("ConsoleKeyTip_EChat1_1", true))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(props.IsTypewriting)
                end)
            })
        else
            return nil
        end
    end)

    return Fusion.Hydrate(scope, Components:RefUI("ExploringChatUI_EChat1_1", false, false, {
        "Shade", "Tex"
    }))({
        Name = "ExploringChatView",

        [Children] = {
            Fusion.Hydrate(scope, Components:RefUI("Speaker_EChat1_1", true))({
                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return `<u>{use(props.Speaker)}</u>`
                end)
            }),

            Fusion.Hydrate(scope, Components:RefUI("Dialogue_EChat1_1", true))({
                AutoLocalize = if BL[props.Speaker] then false else true,

                [Fusion.Out("AbsoluteSize")] = absDialogueSize,

                Text = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.Dialogue)
                end),
                TextSize = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(absDialogueSize).Y / (68 / 23)
                end),
                MaxVisibleGraphemes = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(props.MaxUTFShown)
                end),
            }),

            Fusion.Hydrate(scope, Components:RefUI("Triangle_EChat1_1"))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(props.IsTypewriting)
                end)
            }),

            key,

            Fusion.Hydrate(scope, Components:RefUI("SkipBtn_EChat1_1", true))({
                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.GoSkipDialogueSignal:Fire()
                end
            }),

            Fusion.Hydrate(scope, Components:RefUI("ChoicesFrame_EChat1_1", false, true))({
                [Children] = {
                    Fusion.ForPairs(scope, props.ChoiceList, function(_, scope: Fusion.Scope, index: number, choice: string)
                        local choiceType = "Default"
                        local isSelecting = Fusion.Value(scope, false)

                        if string.find(choice, "ENTERMARKET") then
                            choiceType = "Market"
                            choice = "[Enter Market]"
                        elseif string.find(choice, "ENTERCRAFTING") then
                            choiceType = "Crafting"
                            choice = "[Enter Crafting]"
                        end

                        return index, Fusion.Hydrate(scope, Components:RefUI("Choice_EChat2_1", false, true))({
                            Name = "Choice"..index,
                            LayoutOrder = index,

                            BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                return if use(isSelecting) then Components.WHITE_COLOR else Components.BLACK_COLOR
                            end),

                            [Children] = {
                                Components.HoverImageButton(scope, {
                                    Components.ConnectSelectEvents(isSelecting),

                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        props.GoToNextDialogueByChoiceSignal:Fire(index)
                                    end,
                                }),

                                Fusion.Hydrate(scope, Components:RefUI("Icon_EChat2_2", true))({
                                    Image = AssetBook.PromptIcons[choiceType],

                                    ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return if use(isSelecting) then Components.BLACK_COLOR else Color3.fromRGB(255, 231, 187)
                                    end),
                                }),

                                Fusion.Hydrate(scope, Components:RefUI("OptionText_EChat2_1"))({
                                    Text = choice,

                                    TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return if use(isSelecting) then Components.BLACK_COLOR else Components.WHITE_COLOR
                                    end),
                                })
                            }
                        })
                    end)
                }
            })
        }
    })
end