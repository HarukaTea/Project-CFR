
repeat task.wait() until workspace:GetAttribute("Haruka_PlayerClientInited")


local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")


local Fusion = require(ReplicatedStorage.HarukaShared.Shared.Fusion)
local ClientLib = require(ReplicatedStorage.HarukaShared.Library.ClientLib)
local Bindables = require(ReplicatedStorage.HarukaShared.Library.Bindables)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local BezierMath = require(ReplicatedStorage.HarukaShared.Shared.HarmonyLib.BezierMath)
local Events = require(ReplicatedStorage.HarukaShared.Library.Events)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)
local VFXSceneLib = require(ReplicatedStorage.HarukaShared.Library.VFXSceneLib)



local effectsFolder = ReplicatedStorage.Packages.Effects :: Folder


local wait = task.wait
local plr = Players.LocalPlayer


type ClientWorldLibClass = {
    Funcs: { [string]: () -> nil },

    Init: (self: ClientWorldLibClass) -> nil
}


local ClientWorldLib = {} :: ClientWorldLibClass
ClientWorldLib.Funcs = {}


function ClientWorldLib:Init()
    for _, func: () -> nil in self.Funcs do
        func()
    end
end


table.insert(ClientWorldLib.Funcs, function()
    local function playTween(data: {
        TweenInfo: string,
        Goal: { [string]: any },
        Objs: { Instance },
        UseHarukaTween: boolean?
    })
        local style, goal, objs, useHarukaTween = data.TweenInfo, data.Goal, data.Objs, data.UseHarukaTween

        style = AssetBook.TweenInfos[style]
        if not style then return end

        for _, obj: Instance in objs do
            pcall(function()
                if not useHarukaTween then
                    HarukaLib:CreateTween(obj, style, goal):Play()
                else
                    HarukaLib:Tween(obj, style, goal)
                end
            end)
        end
    end
    Bindables.ClientTween:Connect(playTween)



    local function playSound(sound: Sound, timePos: number?)
        if not sound then return end
        if sound.Name == "ResetSound" then
            for _, music: Sound in SoundService:QueryDescendants("Sound") do
                if music:IsDescendantOf(SoundService.Environment) then continue end
                if music:IsDescendantOf(SoundService.FS_SFXs) then continue end

                music:Stop()
            end
            return
        end
        if sound.IsPlaying then sound:Stop() end

        sound:Play()
        if timePos then sound.TimePosition = timePos end
    end
    Events.PlaySound_S.On(playSound)
    Bindables.PlaySound:Connect(playSound)



    local function playCameraScene(part: BasePart)
        if not part then return end

        local camera = workspace.CurrentCamera
        if part.Name == "ResetCamera" then
            camera.CameraType = Enum.CameraType.Custom

            if not ClientLib:IsCharValid(plr.Character) then return end
            camera.CameraSubject = plr.Character.Humanoid
            return
        end


        camera.CameraType = Enum.CameraType.Scriptable
        camera.CameraSubject = part
        camera.CFrame = part.CFrame
    end
    Events.UpdateCameraPart_S.On(playCameraScene)
    Bindables.UpdateCameraPart:Connect(playCameraScene)


    local function updateCameraCFrame(cframe: CFrame)
        workspace.CurrentCamera.CFrame = cframe
    end
    Events.UpdateCameraCF_S.On(updateCameraCFrame)
    Bindables.UpdateCameraCF:Connect(updateCameraCFrame)
end)



table.insert(ClientWorldLib.Funcs, function()
    local function _handleChest(chest: Model)
        local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt then return end

        prompt.Enabled = false

        local itemInfo = ItemBook:GetItemInfo(chest.Name)
        if itemInfo == nil then return end

        prompt.Enabled = true

        local blackList = { "Consumable" }
        if table.find(blackList, itemInfo.Type) then return end

        local items = plr.Items :: Folder

        if items:FindFirstChild(itemInfo.ItemId) then
            chest.Top:PivotTo(chest.Top.PrimaryPart.CFrame * CFrame.Angles(math.rad(50), 0, 0))
            prompt.Enabled = false
        end
    end
    for _, chest: Model in CollectionService:GetTagged("ChestEntity") do
        _handleChest(chest)
    end
    CollectionService:GetInstanceAddedSignal("ChestEntity"):Connect(_handleChest)
end)



table.insert(ClientWorldLib.Funcs, function()
    local function _updateBorder(border: Model)
        if not border:IsDescendantOf(workspace) then return end

        Promise.new(function(resolve)
            repeat wait() until border and border.PrimaryPart
            repeat wait() until border:FindFirstChild("Border")
            repeat wait() until border.Border:FindFirstChild("Owner")

            local distance = plr:DistanceFromCharacter(border.PrimaryPart.Position)
            if distance <= 0 or distance > 200 then
                wait()
                border:Destroy()

                resolve()
                return
            end

            local innerBorder = border.Border

            ---// update color
            if border:HasTag("EncounterBorder") then
                local owner = border:GetAttribute("Owner") or "nil" :: string

                if owner == plr.Name then
                    if plr:DistanceFromCharacter(border.PrimaryPart.Position) > 17 then
                        plr.Character:PivotTo(CFrame.new(border.PrimaryPart.Position))
                    end
                    for _, part: BasePart in innerBorder:GetChildren() do
                        if HarukaLib:IsBasePartType(part) and part.Name == "Part" then
                            part.CollisionGroup = "Hitbox"
                        end
                    end
                end

                local combatMode = border:GetAttribute("CombatMode")
                if combatMode then
                    local color = Color3.fromRGB(255, 255, 255)
                    if combatMode == "Solo" then
                        color = Color3.fromHex('#f03e3e')
                    elseif combatMode == "Party" then
                        color = Color3.fromHex('#339af0')
                    end
                    for _, child: Instance in innerBorder:GetChildren() do
                        if HarukaLib:IsBasePartType(child) and child.Name == "Part" then
                            child.Beam.Color = ColorSequence.new(color, Color3.new())
                            child.Beam.Transparency = NumberSequence.new(1, 1)
                        end
                    end
                end
            end


            ---// update transparency
            for _, child: Instance in innerBorder:GetChildren() do
                if HarukaLib:IsBasePartType(child) and child.Name == "Part" then
                    HarukaLib:Tween(child.Beam, AssetBook.TweenInfos.twiceHalfOne, { Transparency = NumberSequence.new(0.1, 1) })
                end
            end

            resolve()
        end):timeout(5):catch(function() end)
    end
    CollectionService:GetInstanceAddedSignal("CombatBorder"):Connect(_updateBorder)
    CollectionService:GetInstanceAddedSignal("EncounterBorder"):Connect(_updateBorder)
end)


table.insert(ClientWorldLib.Funcs, function()
    local function _updateOrb(orb: Model)
        if not orb:IsDescendantOf(workspace) then return end

        local middle = orb:FindFirstChild("Middle") or orb:FindFirstChild("Base") :: BasePart

        Promise.try(function()
            middle.Beam1.Transparency = NumberSequence.new(1, 1)
            middle.Beam2.Transparency = NumberSequence.new(1, 1)
            orb.Part.Transparency = 1
            orb.ForceField.Transparency = 1

            orb.Part.Position += Vector3.yAxis * 6
            orb.ForceField.Position -= Vector3.yAxis * 6

            Bindables.ClientTween:Fire({
                Objs = { middle.Beam1, middle.Beam2 },
                Goal = { Transparency = NumberSequence.new(-1, 1) },
                TweenInfo = "one",
                UseHarukaTween = true
            })

            HarukaLib:CreateTween(orb.ForceField, AssetBook.TweenInfos.onceHalf, {
                Transparency = 0,
                Position = orb.ForceField.Position + Vector3.yAxis * 6
            }):Play()

            HarukaLib:CreateTween(orb.Part, AssetBook.TweenInfos.half, {
                Transparency = 0,
                Position = orb.Part.Position - Vector3.yAxis * 6
            }):Play()


            local lifeTime = orb:GetAttribute("Duration") :: number
            Promise.delay(lifeTime - 5):andThen(function()
                if not ClientLib:IsModelValid(orb) then return end

                local countdown = effectsFolder.RespawnTimer:Clone() :: BasePart
                countdown.Transparency = 1
                countdown.BillboardGui.TextLabel.TextColor3 = Color3.fromHex('#ffffff')
                countdown.CFrame = orb.PrimaryPart.CFrame
                countdown.Parent = orb
                Debris:AddItem(countdown, 5)

                Promise.try(function()
                    for i = 5, 1, -1 do
                        if not ClientLib:IsModelValid(orb) then break end
                        if countdown == nil then break end

                        countdown.BillboardGui.TextLabel.Text = tostring(i)
                        wait(1)
                    end
                end):catch(function() end)

            end):catch(function() end)
            Promise.delay(lifeTime - 0.5):andThen(function()
                if not ClientLib:IsModelValid(orb) then return end

                orb:RemoveTag("OrbEntity")

                Bindables.ClientTween:Fire({
                    Objs = { middle.Beam1, middle.Beam2 },
                    Goal = { Transparency = NumberSequence.new(1, 1) },
                    TweenInfo = "half",
                    UseHarukaTween = true
                })


                HarukaLib:CreateTween(orb.ForceField, AssetBook.TweenInfos.onceHalf, {
                    Transparency = 1,
                    Position = orb.ForceField.Position + Vector3.new(0, -6, 0)
                }):Play()

                HarukaLib:CreateTween(orb.Part, AssetBook.TweenInfos.half, {
                    Transparency = 1
                }):Play()

                HarukaLib:CreateTween(orb.Part, AssetBook.TweenInfos.onceHalf, {
                    Position = orb.Part.Position + Vector3.new(0, 6, 0)
                }):Play()
            end):catch(function() end)

        end):catch(function()
            warn("Failed to update Orb Entity")
            Debris:AddItem(orb, 0.15)
        end)
    end
    CollectionService:GetInstanceAddedSignal("OrbEntity"):Connect(_updateOrb)
end)



table.insert(ClientWorldLib.Funcs, function()
    local random = Random.new()

    local function _spawnDMGNumber(target: Model, text: string, color: Color3)
        if text == "0" then text = "MISS" end
        local targetPart = target.PrimaryPart

        Promise.try(function()
            local randomOffset = Vector3.new(
                random:NextNumber(-5, 5),
                0,
                random:NextNumber(-5, 5)
            )

            local part = effectsFolder.DMGNumber:Clone() :: BasePart
            part.Transparency = 1
            part.Parent = workspace.Terrain
            Debris:AddItem(part, 5)

            local heightValue = Instance.new("NumberValue")
            heightValue.Value = 0
            heightValue.Parent = part

            HarukaLib:CreateTween(heightValue, AssetBook.TweenInfos.two, { Value = 15 }):Play()

            local promise; promise = Promise.new(function(resolve, reject)
                while RunService.Heartbeat:Wait() do
                    if not part.Parent or not targetPart.Parent then
                        if part.Parent then part:Destroy() end
                        promise:cancel()
                        return
                    end

                    part.CFrame = CFrame.new(targetPart.Position + randomOffset + Vector3.new(0, heightValue.Value, 0))
                end
            end):catch(function() end)

            RunService.Heartbeat:Wait()

            local ui = part.BillboardGui.Number :: TextLabel
            ui.Text = text
            ui.TextColor3 = color or Color3.new(1, 1, 1)

            part.BillboardGui.Size = UDim2.fromScale(15, 15)

            HarukaLib:CreateTween(part.BillboardGui, AssetBook.TweenInfos.twiceHalfOne, {
                Size = UDim2.fromScale(5, 5)
            }):Play()

            Promise.delay(1.5):andThen(function()
                HarukaLib:CreateTween(ui, AssetBook.TweenInfos.half, { TextTransparency = 1 }):Play()
                HarukaLib:CreateTween(ui.UIStroke, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()

            end):catch(function() end)

        end):catch(function(err)
            if RunService:IsStudio() then warn(tostring(err)) end
        end)
    end
    Events.ShowDMGNumber_S.On(function(data)
        _spawnDMGNumber(data.Target, data.DMGNumber, data.DMGColor)
    end)
end)


table.insert(ClientWorldLib.Funcs, function()
    local random = Random.new()

    local function _spawnText(target: Model, text: string, color: Color3)
        local targetPart = target.PrimaryPart

        Promise.try(function()
            local randomOffset = Vector3.new(
                random:NextNumber(-5, 5),
                -1,
                random:NextNumber(-5, 5)
            )

            local part = effectsFolder.Text:Clone() :: BasePart
            part.Transparency = 1
            part.Parent = workspace.Terrain
            Debris:AddItem(part, 5)

            local heightValue = Instance.new("NumberValue")
            heightValue.Value = 0
            heightValue.Parent = part

            HarukaLib:CreateTween(heightValue, AssetBook.TweenInfos.two, { Value = 15 }):Play()

            local promise; promise = Promise.new(function(resolve, reject)
                while RunService.Heartbeat:Wait() do
                    if not part.Parent or not target.Parent then
                        if part.Parent then part:Destroy() end
                        promise:cancel()
                        return
                    end

                    part.CFrame = CFrame.new(targetPart.Position + randomOffset + Vector3.new(0, heightValue.Value, 0))
                end
            end):catch(function() end)

            RunService.Heartbeat:Wait()

            local ui = part.BillboardGui.Label :: TextLabel
            ui.Text = text
            ui.TextColor3 = color or Color3.new(1, 1, 1)

            part.BillboardGui.Size = UDim2.fromScale(30 / 1.5, 4 / 1.5)

            Promise.delay(1.5):andThen(function()
                HarukaLib:CreateTween(ui, AssetBook.TweenInfos.half, { TextTransparency = 1 }):Play()
                HarukaLib:CreateTween(ui.UIStroke, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()

            end):catch(function() end)

        end):catch(function(err)
            if RunService:IsStudio() then warn(tostring(err)) end
        end)
    end
    Events.ShowText_S.On(function(data)
        _spawnText(data.Target, data.Text, data.TextColor)
    end)
end)



table.insert(ClientWorldLib.Funcs, function()
    local function _onHit(entity: Model)
        if not ClientLib:IsModelValid(entity) then return end
        if not entity:IsDescendantOf(workspace) then return end

        Promise.try(function()
            local hitHighlight = effectsFolder.HitHighlight:Clone() :: Highlight
            hitHighlight.Adornee = entity
            hitHighlight.Parent = entity

            Debris:AddItem(hitHighlight, 1)

            HarukaLib:CreateTween(hitHighlight, AssetBook.TweenInfos.one, {
                FillTransparency = 1,
                OutlineTransparency = 1
            }):Play()


            local hitEff = effectsFolder.HitEffect.BillboardGui:Clone() :: BillboardGui
            hitEff.Adornee = entity.PrimaryPart
            hitEff.Hit.Rotation = math.random(1, 360)
            hitEff.Parent = entity
            Debris:AddItem(hitEff, 2)

            HarukaLib:CreateTween(hitEff.Hit, AssetBook.TweenInfos.half, {
                ImageTransparency = 1
            }):Play()

            HarukaLib:CreateTween(hitEff, AssetBook.TweenInfos.half, {
                Size = UDim2.fromScale(25, 25)
            }):Play()

        end):catch(function() end)
    end
    Events.PlayVFXStatusToEntity_S.On(function(data)
        if data.StatusId ~= "Hit" then return end

        _onHit(data.Entity)
    end)
end)



table.insert(ClientWorldLib.Funcs, function()
    local function _doSimpleVFXEntity(holder: BasePart)
        if not holder:IsDescendantOf(workspace) then return end

        HarukaLib:EmitParticles(holder)
    end
    CollectionService:GetInstanceAddedSignal("VFXEntity"):Connect(_doSimpleVFXEntity)


    local function _doComplexVFXEntity(holder: BasePart)
        if not holder:IsDescendantOf(workspace) then return end

        if not VFXSceneLib.LockedPartTypes[holder.Name] then
            warn("Invalid Complex VFX ID: ".. holder.Name)
            return
        end

        Promise.try(VFXSceneLib.LockedPartTypes[holder.Name], holder):catch(function(err)
            if RunService:IsStudio() then warn(tostring(err)) end
        end)
    end
    CollectionService:GetInstanceAddedSignal("ComplexVFXEntity"):Connect(_doComplexVFXEntity)


    local function _doParticleVFXEntity(holder: ParticleEmitter)
        if not holder:IsDescendantOf(workspace) then return end

        HarukaLib:EmitParticles(holder)

        wait(0.4)
        holder.Enabled = false
    end
    CollectionService:GetInstanceAddedSignal("ParticleEntity"):Connect(_doParticleVFXEntity)
end)


table.insert(ClientWorldLib.Funcs, function()
    local itemDropsContainer = Instance.new("Folder")
    itemDropsContainer.Name = "ItemDropsContainer_Client"
    itemDropsContainer.Parent = workspace.MapComponents

    local RNG = Random.new()

    Events.SpawnItemDrop_S.On(function(data)
        local location = data.ItemDropLocationPos :: Vector3
        local autoPickup = data.AllowAutoPickUp

        location += Vector3.new(
            RNG:NextInteger(-6, 6), 0, RNG:NextInteger(-6, 6)
        )
        location = ClientLib:FindGroundByRay(location)

        for _ = 1, data.ItemAmount do
            local itemSphere = effectsFolder.ItemDisplay:Clone() :: BasePart

            itemSphere.CFrame = CFrame.new(location) * CFrame.new(0, itemSphere.Size.Y / 2, 0)

            itemSphere:SetAttribute("HarukaUniqueId", data.ItemUniqueId)
            itemSphere:SetAttribute("AutoPickup", autoPickup)

            itemSphere:AddTag("ItemDisplayEntity")
            itemSphere.Anchored = true
            itemSphere.CanCollide = false

            local info = ItemBook:GetItemInfo(data.ItemId)
            if info == nil then
                warn(`Invalid item Id for item display: {data.ItemId}`)

                Debris:AddItem(itemSphere, 5)
                return
            end

            local color = AssetBook.ItemTierColors[tonumber(info.Tier)]
            itemSphere.Color = color
            itemSphere.Trail.Color = ColorSequence.new(color)
            itemSphere.BillboardGui.Icon.Image = info.Icon

            for _, child: Instance in itemSphere:QueryDescendants("ParticleEmitter") do
                child.Color = ColorSequence.new(color)
            end
            itemSphere.A0.Beam.Color = ColorSequence.new(color)
            itemSphere.A1.PointLight.Color = color
            itemSphere.Parent = itemDropsContainer
        end
    end)


    local function _destroyItemSphere(itemSphere: BasePart)
        if itemSphere:GetAttribute("IsDestroyed") then return end

        itemSphere:SetAttribute("IsDestroyed", true)
        itemSphere.Transparency = 1
        itemSphere.BillboardGui.Enabled = false

        HarukaLib:CreateTween(itemSphere.Trail, AssetBook.TweenInfos.one, { Lifetime = 0 }):Play()

        Debris:AddItem(itemSphere, 1)
    end
    local function _doItemSphere(itemSphere: BasePart)
        local hit = plr.Character.PrimaryPart :: BasePart

        Promise.delay(0.5):andThen(function()
            local timeout = 10

            repeat wait(0.1)
                timeout -= 0.1
            until timeout <= 0 or plr:DistanceFromCharacter(itemSphere.Position) <= 10 or itemSphere:GetAttribute("AutoPickup")


            Events.PickupItemDrops_C.Fire(itemSphere:GetAttribute("HarukaUniqueId") or "/")

            itemSphere.A0:Destroy()
            itemSphere.A1:Destroy()

            local angles = {
                CFrame.new(math.random(10, 20), 0, 0),
                CFrame.new(math.random(-20, -10), 0, 0),
                CFrame.new(0, math.random(5, 10), 0)
            }
            local start = itemSphere.CFrame
            local mid1 = (start:Lerp(hit.CFrame, 0.3) * angles[math.random(#angles)]).Position
            local mid2 = (start:Lerp(hit.CFrame, 0.6) * angles[math.random(#angles)]).Position
            local elapsed = 0


            while true do
                elapsed += RunService.RenderStepped:Wait() * 1.5

                local curvePos = BezierMath.CubicBezier(elapsed, start.Position, mid1, mid2, hit.Position)

                if elapsed >= 1 then
                    _destroyItemSphere(itemSphere)
                    break
                else
                    itemSphere.Position = curvePos
                end
            end
        end):catch(function()
            _destroyItemSphere(itemSphere)
        end)
    end
    CollectionService:GetInstanceAddedSignal("ItemDisplayEntity"):Connect(_doItemSphere)
end)


table.insert(ClientWorldLib.Funcs, function()
    Events.OpeningChest_S.On(function(chest)
        if not ClientLib:IsModelValid(chest) then return end

        SoundService.SFXs.ChestDrop:Play()

        HarukaLib:Tween(
            chest.Top,
            AssetBook.TweenInfos.twiceHalf,
            { Pivot = chest.Top.PrimaryPart.CFrame * CFrame.Angles(math.rad(50), 0, 0) }
        )
    end)
end)


table.insert(ClientWorldLib.Funcs, function()
    local windmillWings: { BasePart } = {}
    local galleons: { BasePart } = {}

    local function _handleWindmill(windmill: Model)
        repeat wait() until windmill and windmill.PrimaryPart

        wait()
        table.insert(windmillWings, windmill.PrimaryPart)
    end
    local function _handleGalleon(galleon: Model)
        repeat wait() until galleon and galleon.PrimaryPart

        wait()
        table.insert(galleons, galleon.PrimaryPart)
    end
    for _, wings: Model in CollectionService:GetTagged("WindmillWings") do
        _handleWindmill(wings)
    end
    for _, galleon: Model in CollectionService:GetTagged("SkyGalleon") do
        _handleGalleon(galleon)
    end
    CollectionService:GetInstanceAddedSignal("WindmillWings"):Connect(_handleWindmill)
    CollectionService:GetInstanceAddedSignal("SkyGalleon"):Connect(_handleGalleon)


    task.spawn(function()
        while wait(0.01) do
            for _, wing in windmillWings do
                wing.CFrame *= CFrame.Angles(math.rad(-1.7), 0, 0)
            end
        end
    end)
    task.spawn(function()
        while wait(0.01) do
            for i = 1, 100 do
                for _, galleon in galleons do
                    galleon.CFrame *= CFrame.new(0, 0.04 * (if i > 50 then -1 else 1), 0)
                end
                wait(0.01)
            end
        end
    end)
end)


table.insert(ClientWorldLib.Funcs, function()
    Bindables.PromptTriggered:Connect(function(prompt: ProximityPrompt)
        local adornee = prompt.Parent :: BasePart
        local char = plr.Character

        if not adornee:IsA("BasePart") then
            warn("Invalid adornee for proximity prompt")
            return
        end
        if not ClientLib:IsCharValid(char) then return end

        local distance = plr:DistanceFromCharacter(adornee.Position)
        if distance > prompt.MaxActivationDistance + 3 or distance < 0 then return end


        if plr:FindFirstChild("PromptTriggerCDClient") then return end

        local promptCDSymbol = Instance.new("BoolValue")
        promptCDSymbol.Value = true
        promptCDSymbol.Name = "PromptTriggerCDClient"
        promptCDSymbol.Parent = plr
        Debris:AddItem(promptCDSymbol, 0.3)


        if prompt.Name == "Slide" then
            Bindables.ActionSlide:Fire()
        end
    end)
end)



table.insert(ClientWorldLib.Funcs, function()
    Bindables.CloseExplorerUIs:Connect(function()
        Players.LocalPlayer:SetAttribute("CurrentUIGroup", "None")

        HarukaLib:FreezePlayerControls("Unfreeze")

        GuiService.SelectedObject = nil
    end)
end)




table.insert(ClientWorldLib.Funcs, function()
    --// party init
    local Components = require(ReplicatedStorage.HarukaShared.UIAtlas.HarukaComponents)

    local plr = Players.LocalPlayer
    local mouse = plr:GetMouse()

    local isInviting = false
    local isInvitingTo = false
    local isHovered = false


    local partyScope = Fusion.scoped()


    local function _targetCheck(target: BasePart) : Model | nil
        if isInviting then return end
        if not target then return end
        if not target.Parent then return end
        if not target.Parent.Parent then return end
        if target.Parent:FindFirstChildOfClass("Humanoid") then target = target.Parent end
        if target.Parent.Parent:FindFirstChildOfClass("Humanoid") then target = target.Parent.Parent end
        if target == plr.Character then return end
        if not ClientLib:IsCharValid(plr.Character) then return end


        local thatPlr = Players:GetPlayerFromCharacter(target)
        if not thatPlr then return end
        if not ClientLib:IsCharValid(thatPlr.Character) then return end

        local distance = thatPlr:DistanceFromCharacter(plr.Character.PrimaryPart.Position)
        if distance > 33 or distance <= 0 then return end

        return target
    end

    mouse.Button1Down:Connect(function()
        local char = plr.Character
        if not ClientLib:IsCharValid(char) then return end
        if char:GetAttribute("IsInCombat") then return end

        local target = mouse.Target

        target = _targetCheck(target)
        if not target then return end

        local thatPlr = Players:GetPlayerFromCharacter(target)

        Bindables.RToCreatePartyInvite:Fire(thatPlr)
    end)
    mouse.Move:Connect(function()
        local target = mouse.Target

        target = _targetCheck(target)
        if not target then
            if isHovered then
                local highlights = CollectionService:GetTagged("PartyHighlight")
                for _, highlight: Highlight in highlights do highlight:Destroy() end

                isHovered = false
                return
            end
            return
        end

        isHovered = true
        if target:FindFirstChild("PartyHighlight") then target.PartyHighlight:Destroy() end

        local partyHighlight = effectsFolder.PartyHighlight:Clone() :: Highlight
        partyHighlight.Adornee = target
        partyHighlight:AddTag("PartyHighlight")
        partyHighlight.Parent = target
    end)

    --- handling party invite
    Events.PartyInviteResult_S.On(function(data)
        local option, inviter = data.Option, data.PlayerName
        local char = plr.Character

        if option == "Invite" then
            if not ClientLib:IsCharValid(char) then return end
            if plr.PlayerGui:FindFirstChild("ConfirmPrompt") then return end


            local choice = Components:CreateConfirmPrompt(partyScope, {
                Hint = `Accept party invite from <yellow>{Players[inviter].DisplayName}</font>?`,
                ConfirmText = "YES",
                CancelText = "NO",
                ConfirmUniqueId = "ConfirmInviteAccept"..HarukaLib:GenerateUUID(),
            }):Wait()
            if choice == "YES" then
                Events.PartyInvite_C.Fire({ Option = "InviteAccept", PlayerName = inviter })
            elseif choice == "NO" then
                Events.PartyInvite_C.Fire({ Option = "InviteDecline", PlayerName = inviter })
            end
        end
    end)


    Bindables.RToCreatePartyInvite:Connect(function(player: Player)
        if player == Players.LocalPlayer then
            Bindables.CreateNotify:Fire("Can't invite yourself...")
            return
        end
        if isInvitingTo then return end
        local thatPlr = player

        local criRPGSettings = thatPlr:FindFirstChild("CriRPGSettings") :: Configuration
        if not criRPGSettings then return end

        local character = thatPlr.Character
        if not ClientLib:IsCharValid(character) then return end


        if criRPGSettings:FindFirstChild("AllowPartyInvites") then
            local boolean = criRPGSettings.AllowPartyInvites.Value
            if boolean == false then
                Bindables.CreateNotify:Fire("This player isn't accepting invites...")
                return
            end
        end
        if thatPlr:GetAttribute("IsInParty") then
            Bindables.CreateNotify:Fire("That player is already in a party...")
            return
        end
        if character:GetAttribute("IsInCombat") then
            Bindables.CreateNotify:Fire("That player is in the middle of a fight! Try again in a bit?")
            return
        end
        isInvitingTo = true

        local choice = Components:CreateConfirmPrompt(partyScope, {
            Hint = `Invite <yellow>{thatPlr.DisplayName}</font> to your party?`,
            ConfirmText = "YES",
            CancelText = "NO",
            ConfirmUniqueId = "ConfirmInvite"..HarukaLib:GenerateUUID(),
        }):Wait()

        isInvitingTo = false
        if choice ~= "YES" then return end

        Events.PartyInvite_C.Fire({ Option = "Invite", PlayerName = thatPlr.Name })
    end)
end)



table.insert(ClientWorldLib.Funcs, function()
    Events.SpawnEnemyTimer_S.On(function(data)
        local countdown = effectsFolder.RespawnTimer:Clone() :: BasePart
        countdown.Transparency = 1
        countdown.CFrame = data.CFrame
        countdown.Parent = workspace.MapComponents
        Debris:AddItem(countdown, data.RespawnTime)

        Promise.try(function()
            for i = data.RespawnTime, 1, -1 do
                if countdown == nil then break end

                countdown.BillboardGui.TextLabel.Text = tostring(i)
                wait(1)
            end
        end):catch(function() end)
    end)
end)



table.insert(ClientWorldLib.Funcs, function()
    Events.PlayVFXStatusToEntity_S.On(function(data)
        if not ClientLib:IsModelValid(data.Entity) then return end

        if VFXSceneLib[data.StatusId] then
            Promise.try(VFXSceneLib[data.StatusId], plr.Character, "EntityVFXStatusEvent"):catch(function(err)
                if RunService:IsStudio() then warn(tostring(err)) end
            end)
        end
    end)
end)


table.insert(ClientWorldLib.Funcs, function()
    Events.PlayVFXStatusToPlayer_S.On(function(data)
        if not ClientLib:IsCharValid(data.Character) then return end

        if VFXSceneLib[data.StatusId] then
            Promise.try(VFXSceneLib[data.StatusId], data.Character, "PlayerVFXStatusEvent"):catch(function(err)
                if RunService:IsStudio() then warn(tostring(err)) end
            end)
        end
    end)
end)



table.insert(ClientWorldLib.Funcs, function()
    Events.DoT_PlayVFXEff_S.On(function(data)
        if not ClientLib:IsModelValid(data.Target) then return end

        Promise.try(function()
            if data.StatusId == "Clear" then
                for _, particle: Instance in data.Target.PrimaryPart:GetChildren() do
                    if (particle:GetAttribute("HarukaUniqueId") or "/") == data.UniqueId then
                        particle:Destroy()
                    end
                end
                return
            end

            local effectParticle = effectsFolder.Status:FindFirstChild(data.StatusId, true) :: BasePart
            if effectParticle then
                effectParticle = effectParticle.Attachment:Clone()
                effectParticle:SetAttribute("HarukaUniqueId", data.UniqueId)

                effectParticle.Parent = data.Target.PrimaryPart

                Debris:AddItem(effectParticle, data.Duration)
            end
        end):catch(function(err)
            if RunService:IsStudio() then warn(tostring(err)) end
        end)
    end)
end)



table.insert(ClientWorldLib.Funcs, function()
    local function _handleNPC(npc: Model)
        if not npc or not npc.PrimaryPart then return end
        if npc.PrimaryPart.Anchored then return end

        local npcHumanoid = npc:FindFirstChildOfClass("Humanoid") or npc:FindFirstChildOfClass("AnimationController")
        if not npcHumanoid then return end

        if not npcHumanoid:FindFirstChildOfClass("Animator") then
            local animator = Instance.new("Animator")
            animator.Parent = npcHumanoid
        end

        local anim = npc:GetAttribute("IdleAnim") or "DefaultIdle"
        local animTrack = npcHumanoid.Animator:LoadAnimation(ReplicatedStorage.Packages.Anims.NPCAnims[anim]) :: AnimationTrack

        animTrack.Looped = true
        animTrack.Priority = Enum.AnimationPriority.Idle
        animTrack:Play()
    end
    for _, npc in CollectionService:GetTagged("NPCEntity") do
        _handleNPC(npc)
    end
    CollectionService:GetInstanceAddedSignal("NPCEntity"):Connect(_handleNPC)
end)



ClientWorldLib:Init()