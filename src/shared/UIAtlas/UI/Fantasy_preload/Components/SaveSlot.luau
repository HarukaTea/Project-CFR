
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClientLib = require(RepS.HarukaShared.Library.ClientLib)
local Events = require(RepS.HarukaShared.Library.Events)
local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ClassBook = require(RepS.HarukaShared.Library.ClassBook)

local IconShadeTex = require(RepS.HarukaShared.UIAtlas.Components.IconShadeTex)
local ExecuteButton = require(RepS.HarukaShared.UIAtlas.Components.ExecuteButton)
local CAPatternTex = require(RepS.HarukaShared.UIAtlas.Components.CAPatternTex)

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

    table.insert(scope, props.SaveSlotClickedSignal:Connect(function(index: number)
        isVisible:set(false)
        posX:set(POS[props.SlotId])

        if index == props.SlotId then
            isVisible:set(true)
            posX:set(0.2)
        end
    end))
    table.insert(scope, props.SaveSlotBackSignal:Connect(function()
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


    return Components.Frame(scope, {
        Name = "Slot"..props.SlotId,
        Size = UDim2.fromScale(0.23, 7),
        BackgroundTransparency = 0,

        Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Scope, _)
            return UDim2.fromScale(use(posX), 0.5)
        end), AssetBook.TweenInfos.half),

        Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
            return use(isVisible)
        end),

        [Children] = {
            Components.UICorner(scope, {
                CornerRadius = UDim.new(0.05, 0),
            }),
            Components.ScaledUIStroke(scope, {
                Thickness = 0.015,

                Color = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                    return if use(isSelecting) then Components.WHITE_COLOR else Color3.fromRGB()
                end)
            }),

            Fusion.Computed(scope, function(use: Fusion.Scope, scope: Fusion.Scope)
                if use(posX) == 0.2 then
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
                else
                    return nil
                end
            end),


            Components.HoverImageButton(scope, {
                [Fusion.OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [Fusion.OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,


                [Fusion.OnEvent("MouseButton1Click")] = function()
                    props.SaveSlotClickedSignal:Fire(props.SlotId)
                end,
            }),

            CAPatternTex(scope, {}),


            Label(scope, {
                Name = "FileId",
                Position = UDim2.fromScale(0.5, 0.02),
                Size = UDim2.fromScale(0.86, 0.1),
                Text = "File #"..props.SlotId,
            }, false),


            Components.IconImageLabel(scope, {
                Name = "Class",
                Position = UDim2.fromScale(0.83, 0.02),
                Size = UDim2.fromScale(0.1, 0.1),

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

                Visible = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                    return not use(isEmpty)
                end)
            }),



            Label(scope, {
                Name = "Level",
                Position = UDim2.fromScale(0.5, 0.13),
                Size = UDim2.fromScale(0.86, 0.06),

                Text = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                    return `Lv.{use(playerLevel)}`
                end),
                TextColor3 = Color3.fromHex('#ffeaa7'),

            }, isEmpty),
            Label(scope, {
                Name = "PlayTime",
                Position = UDim2.fromScale(0.5, 0.13),
                Size = UDim2.fromScale(0.86, 0.06),
                TextXAlignment = Enum.TextXAlignment.Right,

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

                TextColor3 = Color3.fromHex('#ffeaa7'),
            }, isEmpty),


            Fusion.Computed(scope, function(use: Fusion.Scope, scope: Fusion.Scope)
                if use(props.CharacterModel) == nil then
                    return nil
                elseif use(props.CharacterModel) and use(props.CharacterModel).ClassName == "Model" and not use(isEmpty) then
                    local charModel = use(props.CharacterModel) :: Model


                    local camera = Instance.new("Camera")
                    camera.Name = "CharacterPreviewCamera_"..props.SlotId
                    camera.CameraType = Enum.CameraType.Scriptable

                    table.insert(scope, camera)


                    local vpFrame = Components.ViewportFrame(scope, {
                        Name = "CharacterPreview",
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.fromScale(0.5, 0.22),
                        Size = UDim2.fromScale(0.87, 0.6),

                        Ambient = Color3.fromRGB(159, 159, 159),
                        LightColor = Color3.fromRGB(159, 159, 159),

                        CurrentCamera = camera,

                        [Children] = {
                            Fusion.New(scope, "WorldModel")({
                                Name = "WorldModel_Preview"
                            })
                        }
                    })
                    camera.Parent = vpFrame


                    table.insert(scope, task.spawn(function()
                        --- weld weapons to character
                        local charClone = charModel:Clone() :: Model
                        charClone.Parent = vpFrame:FindFirstChildOfClass("WorldModel")

                        local weaponId = use(playerWeapon) :: string

                        for _, weapon: Model in charClone:GetChildren() do
                            if weapon:HasTag("ClassWeapon") then weapon:Destroy() end
                        end
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

                        table.insert(scope, charClone)
                        table.insert(scope, RunService.RenderStepped:Connect(function()
                            if not Fusion.peek(props.IsUIShown) then return end

                            camera.CFrame = CFrame.new(charClone.PrimaryPart.Position +
                                charClone.PrimaryPart.CFrame.LookVector * 5, charClone.PrimaryPart.Position)
                        end))
                    end))

                    return vpFrame
                end
            end),


            Label(scope, {
                Name = "LastJoined",
                Position = UDim2.fromScale(0.5, 0.87),
                Size = UDim2.fromScale(0.86, 0.06),
                AutoLocalize = false,

                Text = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                    return `{use(playerLastJoined)}`
                end),
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center,
            }, isEmpty),


            Components.TextLabel(scope, {
                Name = "Empty",
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 0.1),

                Text = "EMPTY",

                Visible = Fusion.Computed(scope, function(use: Fusion.Scope, _)
                    return use(isEmpty)
                end)
            }),


            Components.Frame(scope, {
                Name = "FileSelections",
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.fromScale(0.15, 1),
                Position = UDim2.fromScale(-0.2, 0.5),

                Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                    return use(posX) == 0.2
                end),

                [Children] = {
                    Components.UIListLayout(scope, {
                        Padding = UDim.new(0.01, 0),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                    }),


                    Fusion.ForPairs(scope, { "Erase" }, function(_, scope: Fusion.Scope, index: number, id: string)
                        local thatIsSelecting = Fusion.Value(scope, false)

                        return index, Components.Frame(scope, {
                            Name = "FileSelection_"..id,
                            SizeConstraint = Enum.SizeConstraint.RelativeXX,

                            [Children] = {
                                IconShadeTex(scope, {
                                    Visible = Fusion.Computed(scope, function(use: Fusion.Use, _)
                                        return use(thatIsSelecting)
                                    end)
                                }),

                                Components.HoverImageButton(scope, {
                                    [Fusion.OnEvent("MouseEnter")] = function()
                                        thatIsSelecting:set(true)
                                    end,
                                    [Fusion.OnEvent("MouseLeave")] = function()
                                        thatIsSelecting:set(false)
                                    end,


                                    [Fusion.OnEvent("MouseButton1Click")] = function()
                                        if id == "Erase" then
                                            local result = Components:CreateConfirmPrompt(scope, {
                                                Hint = "Delete this save file? This action cannot be undone.",
                                                ConfirmText = "YES",
                                                CancelText = "NO",

                                                ConfirmUniqueId = "ConfirmSaveErase1"
                                            }).Event:Wait()

                                            if result == "NO" then return end

                                            local result = Components:CreateConfirmPrompt(scope, {
                                                Hint = "This will <red>PERMANENTLY DELETE</font> your save. Are you sure?",
                                                ConfirmText = "YES",
                                                CancelText = "NO",

                                                ConfirmUniqueId = "ConfirmSaveErase2"
                                            }).Event:Wait()

                                            if result == "NO" then return end

                                            Events.Titlescreen_SlotActions_C.Fire({
                                                ActionId = "Erase",
                                                SlotId = "Slot"..props.SlotId
                                            })
                                        end
                                    end
                                }),

                                Components.IconImageLabel(scope, {
                                    Image = "rbxassetid://81951014936836",
                                    ImageColor3 = Color3.fromHex('#ff6b81')
                                })
                            }
                        })
                    end)
                }
            })
        }
    })
end