
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local SaveSlot = require(script.Parent.SaveSlot)

local ServerListView = require(script.Parent.ServerListView)

local Children = Fusion.Children


return function (scope: Fusion.Scope, props: {
    SlotUISignal: RBXScriptSignal,
    CutsceneUISignal: RBXScriptSignal,

    CharVals: { Fusion.Value<Model?> },

}) : ScreenGui

    local saveSlotClickedSignal = Signal.new()
    local saveSlotBackSignal = Signal.new()
    local readyToTeleportSignal = Signal.new()
    table.insert(scope, saveSlotClickedSignal)
    table.insert(scope, saveSlotBackSignal)
    table.insert(scope, readyToTeleportSignal)

    local serverListClickedSignal = Signal.new()
    table.insert(scope, serverListClickedSignal)


    local isShown = Fusion.Value(scope, false)
    local isBackButtonShown = Fusion.Value(scope, true)

    local whichSlotIsChosen = Fusion.Value(scope, "Slot1")

    table.insert(scope, props.CutsceneUISignal:Connect(function()
        isShown:set(false)
    end))
    table.insert(scope, props.SlotUISignal:Connect(function()
        isShown:set(true)
    end))


    saveSlotClickedSignal:Connect(function(id: number)
        isBackButtonShown:set(false)

        whichSlotIsChosen:set("Slot".. tostring(id))
    end)
    saveSlotBackSignal:Connect(function()
        isBackButtonShown:set(true)
    end)


    local UI; UI = Components.HarukaScreenGui(scope, {
        Name = "InnerTitlescreen",
        DisplayOrder = 233,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
            return use(isShown)
        end),

    }, {
        BottomProps = {
            [Children] = {
                Fusion.Computed(scope, function(use: Fusion.Use, scope: Fusion.Scope)
                    if use(isBackButtonShown) then
                        return ExecuteButton(scope, {
                            AnchorPoint = Vector2.new(0.5, 0),
                            Position = UDim2.fromScale(0.5, 0),

                            Size = UDim2.fromScale(0.16, 0.68),
                            ButtonText = "BACK",
                            ButtonType = "Cancel",
                            ButtonClickFunc = function()
                                props.CutsceneUISignal:Fire()
                            end
                        })
                    else
                        return nil
                    end
                end)
            }
        },


        CenterProps = {
            [Children] = {
                Components.Frame(scope, {
                    Name = "SaveSlots",
                    Position = UDim2.fromScale(0.5, 0.3),

                    [Children] = {
                        Fusion.ForPairs(scope, props.CharVals, function(_, scope: Fusion.Scope, index: number, charVal: Fusion.Value<Model?>)
                            return index, SaveSlot(scope, {
                                SlotId = index,
                                CharacterModel = charVal,

                                SaveSlotClickedSignal = saveSlotClickedSignal,
                                SaveSlotBackSignal = saveSlotBackSignal,
                                ReadyToTeleportSignal = readyToTeleportSignal,

                                ServerListClickedSignal = serverListClickedSignal,

                                IsUIShown = isShown,
                            })
                        end)
                    }
                }),


                Components.Frame(scope, {
                    Name = "ServerList",
                    Position = UDim2.fromScale(0.5, 0.3),

                    [Children] = {
                        ServerListView(scope, {
                            SaveSlotClickedSignal = saveSlotClickedSignal,
                            SaveSlotBackSignal = saveSlotBackSignal,
                            ReadyToTeleportSignal = readyToTeleportSignal,

                            ServerListClickedSignal = serverListClickedSignal,

                            SlotChosen = whichSlotIsChosen,
                        })
                    }
                })
            }
        }
    })


    --// anims
    local shownObserver = Fusion.Observer(scope, isShown)
    shownObserver:onBind(function()
        local shown = Fusion.peek(isShown) :: boolean
        if shown then
            HarukaLib:UITween(UI.Center, "In", {
                FollowOriPropsWhenIn = true,

                TweenTime = 0.5,
                PosTweenStyle = "FromB2T",
                PosTweenBaseElement = UI.Center
            })
        else
            HarukaLib:UITween(UI.Center, "Out", {
                SetOriPropsWhenOut = true,

                PosTweenStyle = "FromT2B",
                PosTweenBaseElement = UI.Center,
            })
        end
    end)


    return UI
end