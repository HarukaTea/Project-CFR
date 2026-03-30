
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Controllers.ClientLib)
local Events = require(RepS.HarukaShared.Library.Events)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ClassBook = require(RepS.HarukaShared.Library.ClassBook)

local IconShadeTex = require(RepS.HarukaShared.UIAtlas.Components.IconShadeTex)
local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)

local Children = Fusion.Children

local wait = task.wait

local function Label(scope: Fusion.Scope, props: { [string]: any }, emptyVal: Fusion.Value<boolean>)
    local default = {
        AnchorPoint = Vector2.new(0.5, 0),
        TextXAlignment = Enum.TextXAlignment.Left,

        Visible = Fusion.Computed(scope, function(use: Fusion.Scope, _)
            return not use(emptyVal)
        end)
    }
    Components._reconcileProps(default, props or {})

    return Components.TextLabel(scope, default)
end

return function (scope: Fusion.Scope, props: {
    SlotId: number,
    CharacterModel: Fusion.Value<Model?>,

    SaveSlotClickedSignal: BindableEvent,
    SaveSlotBackSignal: BindableEvent,
    ReadyToTeleportSignal: BindableEvent,

    ServerListClickedSignal: BindableEvent,

    IsUIShown: Fusion.Value<boolean>,
})

    local POS = {
        0.23, 0.5, 0.77
    }
    local function Value<T>(val: T) : Fusion.Value<T>
        return Fusion.Value(scope, val)
    end
    local isSelecting = Value(false)
    local isEmpty = Value(true)
    local isVisible = Value(true)
    local posX = Value(POS[props.SlotId])

    table.insert(scope, props.SaveSlotClickedSignal.Event:Connect(function(index: number)
        isVisible:set(false)
        posX:set(POS[props.SlotId])

        if index == props.SlotId then
            isVisible:set(true)
            posX:set(0.2)
        end
    end))
    table.insert(scope, props.SaveSlotBackSignal.Event:Connect(function()
        isVisible:set(true)
        posX:set(POS[props.SlotId])
    end))

    local playerClass = Value("Burst")
    local playerLevel = Value(1)
    local playerLastJoined = Value(DateTime.now():ToIsoDate())
    local playerPlayTime = Value(0)

    local playerWeapon = Value("WoodenSword")

    local profileContainer = Players.LocalPlayer.ProfileContainer :: Folder

    table.insert(scope, HarukaLib:Hydrate(profileContainer, {
        ["Attr_Slot"..props.SlotId.."_PlayTime"] = function(val: number)
            playerPlayTime:set(val)
            isEmpty:set(val <= 0)
        end,
        ["Attr_Slot"..props.SlotId.."_Class"] = function(val: string)
            playerClass:set(val)
        end,
        ["Attr_Slot"..props.SlotId.."_Level"] = function(val: number)
            playerLevel:set(val)
        end,
        ["Attr_Slot"..props.SlotId.."_LastJoinedDateTime"] = function(val: string)
            playerLastJoined:set(val)
        end
    }))

    if profileContainer:FindFirstChild("Slot"..props.SlotId.."_Weapon1") then
        table.insert(scope, HarukaLib:Hydrate(profileContainer["Slot"..props.SlotId.."_Weapon1"], {
            ["Prop-Value"] = function(val: string)
                playerWeapon:set(val or "WoodenSword")
            end
        }))
    end

    local isSelectingEraseButton = Value(false)

    return Fusion.Hydrate(scope, Components:RefUI("Slot_CFTitle2_1", false, false, {
        "UICorner", "CAPatternTex"
    }))({
        Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Scope, _)
            return UDim2.fromScale(use(posX), 0.5)
        end), Components.TweenInfos.half),
        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(isVisible)
        end),

        [Children] = {
            Components.ScaledUIStroke(scope, {
                Thickness = 0.015,

                Color = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                    return if use(isSelecting) then Components.WHITE_COLOR else Color3.fromRGB()
                end)
            }),

            Fusion.Computed(scope, function(use: Fusion.Scope, scope: Fusion.Scope)
                if use(posX) ~= 0.2 then return nil end

                return {
                    ExecuteButton(scope, {
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.fromScale(0, 1.06),
                        Size = UDim2.fromScale(0.48, 0.095),
                        ButtonText = "BACK",
                        ButtonClickFunc = function()
                            props.SaveSlotBackSignal:Fire()
                        end,
                        ButtonType = "Cancel"
                    }),
                    ExecuteButton(scope, {
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.fromScale(1, 1.06),
                        Size = UDim2.fromScale(0.48, 0.095),
                        ButtonText = "PLAY",
                        ButtonClickFunc = function()
                            props.IsUIShown:set(false)
                            props.ReadyToTeleportSignal:Fire()

                            workspace:SetAttribute("Titlescreen_SlotId", props.SlotId)
                            workspace:SetAttribute("Titlescreen_LoadSlot", true)
                        end,
                        ButtonType = "Confirm"
                    })
                }
            end),

            Components.HoverImageButton(scope, {
                Components.ConnectSelectEvents(isSelecting),

                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.SaveSlotClickedSignal:Fire(props.SlotId)
                end,
            }),

            Components.Frame(scope, {
                Name = "Slot",

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return not use(isEmpty)
                end),

                [Children] = {
                    Fusion.Hydrate(scope, Components:RefUI("Class_CFTitle2_1", true))({
                        Image = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(playerClass) :: string

                            if not ClassBook[classId] then return AssetBook.ExtraIcons.Unknown end
                            return ClassBook[classId].Icon
                        end),
                        ImageColor3 = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            local classId = use(playerClass) :: string

                            if not ClassBook[classId] then return Color3.new(1, 1, 1) end
                            return ClassBook[classId].Color
                        end),
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("FileSelections_CFTitle2_1", false, true))({
                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                            return use(posX) == 0.2
                        end),

                        [Children] = {
                            Fusion.Hydrate(scope, Components:RefUI("EraseBtn_CFTitle2_1", false, false, {
                                "Icon"
                            }))({
                                [Children] = {
                                    IconShadeTex(scope, {
                                        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                            return use(isSelectingEraseButton)
                                        end)
                                    }),

                                    Components.HoverImageButton(scope, {
                                        Components.ConnectSelectEvents(isSelectingEraseButton),

                                        [Fusion.OnEvent("MouseButton1Click")] = function()
                                            local result = Components:CreateConfirmPrompt({
                                                Hint = "Delete this save file? <br/><red>This action cannot be undone.</font>",
                                                ConfirmText = "Confirm",
                                                CancelText = "Cancel",

                                                ConfirmUniqueId = "ConfirmSaveErase1"
                                            }).Event:Wait()

                                            if result == "NO" then return end

                                            local result = Components:CreateConfirmPrompt({
                                                Hint = "This will <red>PERMANENTLY DELETE</font> your save. <br/>Are you sure?",
                                                ConfirmText = "Confirm",
                                                CancelText = "Cancel",

                                                ConfirmUniqueId = "ConfirmSaveErase2"
                                            }).Event:Wait()

                                            if result == "NO" then return end

                                            Events.Titlescreen_SlotActions_C.Fire({
                                                ActionId = "Erase",
                                                SlotId = "Slot"..props.SlotId
                                            })
                                        end
                                    }),
                                }
                            })
                        }
                    }),

                    Fusion.Computed(scope, function(use: Fusion.Scope, scope: Fusion.Scope)
                        if use(isEmpty) then return nil end
                        if use(props.CharacterModel) == nil then return nil end
                        if use(props.CharacterModel).ClassName ~= "Model" then return nil end

                        local charModel = use(props.CharacterModel) :: Model

                        local camera = Instance.new("Camera")
                        camera.Name = "CharacterPreviewCamera_"..props.SlotId
                        camera.CameraType = Enum.CameraType.Scriptable

                        table.insert(scope, camera)

                        local vpFrame = Fusion.Hydrate(scope, Components:RefUI("CharacterPreview_CFTitle2_1", true))({
                            CurrentCamera = camera
                        })
                        camera.Parent = vpFrame

                        table.insert(scope, task.spawn(function()
                            --- weld weapons to character
                            local charClone = charModel:Clone() :: Model
                            charClone.Parent = vpFrame:FindFirstChildOfClass("WorldModel")
                            table.insert(scope, charClone)

                            local weaponId = use(playerWeapon) :: string
                            local classWeapon = RepS.Packages.ClassWeapons:FindFirstChild(weaponId, true) :: Folder?
                            if not classWeapon then return end

                            local targetFolder = classWeapon.Overworld :: Folder
                            for _, weapon: Model in targetFolder:GetChildren() do
                                weapon = weapon:Clone()
                                weapon:AddTag("ClassWeapon")

                                ClientLib:WeldWeapon(weapon, charClone)
                            end

                            repeat wait() until vpFrame.Parent

                            --- play animation
                            local anim: Animation = RepS.Packages.Anims.CharAnims.Idle1
                            local animTrack = charClone.Humanoid.Animator:LoadAnimation(anim)
                            animTrack:Play()

                            repeat wait() until Fusion.peek(props.IsUIShown)

                            camera.CFrame = CFrame.new(charClone.PrimaryPart.Position +
                                    charClone.PrimaryPart.CFrame.LookVector * 5, charClone.PrimaryPart.Position)
                        end))

                        return vpFrame
                    end),

                    Fusion.Hydrate(scope, Components:RefUI("FileId_CFTitle2_1"))({
                        Text = "File #"..props.SlotId
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("Level_CFTitle2_1"))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                            return `Lv.{use(playerLevel)}`
                        end),
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("PlayTime_CFTitle2_1"))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                            local playTime = use(playerPlayTime) :: number
                            local convertedTime = playTime / 3600
                            local isHour = true

                            if convertedTime < 1 then
                                isHour = false
                                convertedTime = playTime / 60
                            end
                            if isHour then
                                return `{string.format("%.1f", convertedTime)} Hours`
                            else
                                return `{string.format("%.0f", convertedTime)} Minutes`
                            end
                        end),
                    }),

                    Fusion.Hydrate(scope, Components:RefUI("LastJoined_CFTitle2_1"))({
                        Text = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                            return `{use(playerLastJoined)}`
                        end),
                    }),
                }
            }),

            Fusion.Hydrate(scope, Components:RefUI("Empty_CFTitle2_1"))({
                Visible = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                    return use(isEmpty)
                end)
            }),
        }
    })
end