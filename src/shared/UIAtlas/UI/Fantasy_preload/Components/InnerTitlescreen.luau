--!nocheck

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")

local Bindables = require(RepS.HarukaShared.Library.Bindables)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local SaveSlot = require(script.Parent.SaveSlot)

local FriendListView = require(script.Parent.FriendListView)
local ClassSelectionView = require(script.Parent.ClassSelectionView)


local Haruka3DifyUI = require(RepS.HarukaShared.Shared.Haruka3DifyUI)

local Children = Fusion.Children

local wait = task.wait

return function (scope: Fusion.Scope, props: {
    SlotUISignal: RBXScriptSignal,
    CutsceneUISignal: RBXScriptSignal,

    CharVals: { Fusion.Value },

}) : ScreenGui

    local saveSlotClickedSignal = Signal.new()
    local saveSlotBackSignal = Signal.new()
    local readyToTeleportSignal = Signal.new()
    table.insert(scope, saveSlotClickedSignal)
    table.insert(scope, saveSlotBackSignal)
    table.insert(scope, readyToTeleportSignal)

    local friendListClickedSignal = Signal.new()
    local serverListClickedSignal = Signal.new()
    table.insert(scope, friendListClickedSignal)
    table.insert(scope, serverListClickedSignal)


    local isShown = Fusion.Value(scope, false)
    local isBackButtonShown = Fusion.Value(scope, true)

    local whichSlotIsChosen = Fusion.Value(scope, "Slot1")

    local isSelectingStartClass = Fusion.Value(scope, false)

    table.insert(scope, props.CutsceneUISignal:Connect(function()
        isShown:set(false)
    end))
    table.insert(scope, props.SlotUISignal:Connect(function()
        isShown:set(true)
    end))
    table.insert(scope, readyToTeleportSignal:Connect(function()
        isShown:set(false)
        isSelectingStartClass:set(false)
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
                        Fusion.ForPairs(scope, props.CharVals, function(_, scope: Fusion.Scope, index: number, charVal: Fusion.Value)
                            return index, SaveSlot(scope, {
                                SlotId = index,
                                CharacterModel = charVal,

                                SaveSlotClickedSignal = saveSlotClickedSignal,
                                SaveSlotBackSignal = saveSlotBackSignal,
                                ReadyToTeleportSignal = readyToTeleportSignal,

                                FriendListClickedSignal = friendListClickedSignal,
                                ServerListClickedSignal = serverListClickedSignal,

                                IsUIShown = isShown,
                                IsSelectingClass = isSelectingStartClass,
                            })
                        end)
                    }
                }),


                Components.Frame(scope, {
                    Name = "FriendList",
                    Position = UDim2.fromScale(0.5, 0.3),

                    [Children] = {
                        FriendListView(scope, {
                            SaveSlotClickedSignal = saveSlotClickedSignal,
                            SaveSlotBackSignal = saveSlotBackSignal,
                            ReadyToTeleportSignal = readyToTeleportSignal,

                            FriendListClickedSignal = friendListClickedSignal,
                            ServerListClickedSignal = serverListClickedSignal,

                            SlotChosen = whichSlotIsChosen,
                        })
                    }
                })
            }
        }
    })
    local UI2; UI2 = Components.HarukaScreenGui(scope, {
        Name = "InnerTitlescreen",
        DisplayOrder = 233,

        Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
            return use(isSelectingStartClass)
        end),

        [Children] = {
            ClassSelectionView(scope, {
                IsSelectingStartClass = isSelectingStartClass,
                ReadyToTeleportSignal = readyToTeleportSignal,
                IsUIShown = isShown,
                SlotId = whichSlotIsChosen,
            })
        }
    }, {})


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



    local screen3DObj = Haruka3DifyUI.new(UI2, 5)
    local part2D_classSelection = screen3DObj:GetPart2D(UI2.ClassSelection)

    part2D_classSelection:SetOffsetY(4)
    part2D_classSelection:Enable()


    table.insert(scope, screen3DObj)




    --// change class scene request
    table.insert(scope, Bindables.Titlescreen_ChangeClassScene:Connect(function()
        workspace.MapComponents.Titlescreen.CameraLocator.Value = workspace.MapComponents.Titlescreen.CameraLocator2_Chain

        local ClientLib = require(RepS.HarukaShared.Library.ClientLib)

        ClientLib:LoadLightingPreset("ClassSelection_Chain")
    end))



    return { UI, UI2 }
end