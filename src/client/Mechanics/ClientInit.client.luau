
repeat task.wait() until workspace:GetAttribute("Haruka_PlayerClientInited")


local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")


local ClientLib = require(ReplicatedStorage.HarukaShared.Library.ClientLib)
local Bindables = require(ReplicatedStorage.HarukaShared.Library.Bindables)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local ComplexVFXLib = require(ReplicatedStorage.HarukaShared.Library.ComplexVFXLib)
local Bezier = require(ReplicatedStorage.HarukaShared.Library.BezierAlgoBook)
local Events = require(ReplicatedStorage.HarukaShared.Library.Events)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)


local wait = task.wait
local plr = Players.LocalPlayer


local ClientWorldLib = {}
ClientWorldLib.Funcs = {}


local focusRenderDistance = 486
HarukaLib:Hydrate(workspace, {
    ["Attr-FocusRenderDistance"] = function(val: number)
        val = val or 486

        focusRenderDistance = val
    end
})


function ClientWorldLib:Init()
    for _, func: () -> nil in ClientWorldLib.Funcs do
        task.spawn(func)
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
            if HarukaLib:IsBasePartType(obj) then
                local distance = plr:DistanceFromCharacter(obj.Position)
                if distance <= 0 or distance > focusRenderDistance then
                    continue
                end
            end
            if obj:IsA("Model") then
                local pos = obj.WorldPivot.Position
                if obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                end

                local distance = plr:DistanceFromCharacter(pos)
                if distance <= 0 or distance > focusRenderDistance then
                    continue
                end
            end


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
    Events.PlayClientTween.On(playTween)



    local function playSound(sound: Sound, timePos: number?)
        if not sound then return end
        if sound.Name == "ResetSound" then
            for _, music: Sound in SoundService:GetDescendants() do
                if music:IsA("Sound") then
                    if music:IsDescendantOf(SoundService.Environment) then continue end
                    if music:IsDescendantOf(SoundService.FS_SFXs) then continue end

                    music:Stop()
                end
            end
            return
        end


        sound:Play()
        if timePos then sound.TimePosition = timePos end
    end
    Events.PlaySound.On(playSound)
    Bindables.PlaySound:Connect(playSound)



    local function playCameraScene(part: BasePart)
        if not part then return end

        local camera = workspace.CurrentCamera
        if part.Name == "ResetCamera" then
            camera.CameraType = Enum.CameraType.Custom

            if not ClientLib.IsCharValid(plr.Character) then return end
            camera.CameraSubject = plr.Character.Humanoid
            return
        end


        camera.CameraType = Enum.CameraType.Scriptable
        camera.CameraSubject = part
        camera.CFrame = part.CFrame
    end
    Events.PlayCameraCutscene.On(playCameraScene)
    Bindables.PlayCameraCutscene:Connect(playCameraScene)


    local function updateCameraCFrame(cframe: CFrame)
        workspace.CurrentCamera.CFrame = cframe
    end
    Events.UpdateCameraCFrame.On(updateCameraCFrame)
    Bindables.UpdateCameraCFrame:Connect(updateCameraCFrame)
end)



table.insert(ClientWorldLib.Funcs, function()
    for _, chest: Model in CollectionService:GetTagged("ChestEntity") do
        local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt then continue end

        prompt.Enabled = false

        local itemInfo = ItemBook:GetItemInfo(chest.Name)
        if itemInfo == nil then continue end

        prompt.Enabled = true

        local blackList = { "Consumable" }
        if table.find(blackList, itemInfo.Type) then continue end

        local items = plr.Items :: Folder

        if items:FindFirstChild(itemInfo.ItemId) then
            chest.Top:PivotTo(chest.Top.PrimaryPart.CFrame * CFrame.Angles(math.rad(50), 0, 0))
            prompt.Enabled = false
        end
    end
end)



table.insert(ClientWorldLib.Funcs, function()
    local function _updateBorder(border: Model)
        if not border:IsDescendantOf(workspace) then return end

        Promise.new(function(resolve)
            repeat wait() until border and border.PrimaryPart
            repeat wait() until border:FindFirstChild("Border")
            repeat wait() until border.Border:FindFirstChild("Owner")

            local distance = plr:DistanceFromCharacter(border.PrimaryPart.Position)
            if distance <= 0 or distance > focusRenderDistance then
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
                if not ClientLib.IsModelValid(orb) then return end

                local countdown = ReplicatedStorage.Packages.Effects.RespawnTimer:Clone() :: BasePart
                countdown.Transparency = 1
                countdown.BillboardGui.TextLabel.TextColor3 = Color3.fromHex('#ffffff')
                countdown.CFrame = orb.PrimaryPart.CFrame
                countdown.Parent = orb
                Debris:AddItem(countdown, 5)

                Promise.try(function()
                    for i = 5, 1, -1 do
                        if not ClientLib.IsModelValid(orb) then break end
                        if countdown == nil then break end

                        countdown.BillboardGui.TextLabel.Text = tostring(i)
                        wait(1)
                    end
                end):catch(function() end)

            end):catch(function() end)
            Promise.delay(lifeTime - 0.5):andThen(function()
                if not ClientLib.IsModelValid(orb) then return end

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
    local function _spawnDMGNumber(entity: Model, text: string, color: Color3)
        if not ClientLib.IsModelValid(entity) then return end
        if not entity:IsDescendantOf(workspace) then return end

        local distance = plr:DistanceFromCharacter(entity.PrimaryPart.Position)
        if distance <= 0 or distance > focusRenderDistance then return end

        local pos = entity.PrimaryPart.Position
        local random = Random.new()

        if text == "0" then text = "MISS" end

        Promise.try(function()
            local BCF, Bsize = entity:GetBoundingBox()
            pos += Vector3.new(
                random:NextNumber(-2, 2),
                0,
                random:NextNumber(-2, 2)
            )
            if pos.Y <= BCF.Position.Y + (Bsize.Y / 2) then
                pos = Vector3.new(
                    pos.X,
                    BCF.Position.Y + (Bsize.Y / 2) + random:NextNumber(0,0.5),
                    pos.Z
                )
            end
            local part = ReplicatedStorage.Packages.Effects.DMGNumber:Clone() :: BasePart
            part.Transparency = 1
            part.CFrame = CFrame.new(pos)
            part.Parent = workspace.Terrain
            Debris:AddItem(part, 5)

            RunService.Heartbeat:Wait()

            local ui = part.BillboardGui.Number :: TextLabel
            ui.Text = text
            ui.TextColor3 = color or Color3.new(1, 1, 1)

            part.BillboardGui.Size = UDim2.fromScale(12 * 2, 12 * 2)

            HarukaLib:CreateTween(part.BillboardGui, AssetBook.TweenInfos.half, {
                Size = UDim2.fromScale(3, 3)
            }):Play()

            Promise.delay(1.5):andThen(function()
                HarukaLib:CreateTween(ui, AssetBook.TweenInfos.half, { TextTransparency = 1 }):Play()
                HarukaLib:CreateTween(ui.UIStroke, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()

            end):catch(function() end)

            random = nil

        end):catch(function() end)
    end
    Events.ShowDMGNumber.On(function(data)
        _spawnDMGNumber(data.DMGTarget, data.DMGNumber, data.DMGColor)
    end)
end)


table.insert(ClientWorldLib.Funcs, function()
    local function _spawnText(entity: Model, text: string, color: Color3)
        if not ClientLib.IsModelValid(entity) then return end
        if not entity:IsDescendantOf(workspace) then return end

        local distance = plr:DistanceFromCharacter(entity.PrimaryPart.Position)
        if distance <= 0 or distance > focusRenderDistance then return end

        local pos = entity.PrimaryPart.Position
        local random = Random.new()


        Promise.try(function()
            local BCF, Bsize = entity:GetBoundingBox()
            pos += Vector3.new(
                random:NextNumber(-2, 2),
                0,
                random:NextNumber(-2, 2)
            )
            if pos.Y <= BCF.Position.Y + (Bsize.Y / 2) then
                pos = Vector3.new(
                    pos.X,
                    BCF.Position.Y + (Bsize.Y / 2) + random:NextNumber(0,0.5),
                    pos.Z
                )
            end
            local part = ReplicatedStorage.Packages.Effects.Text:Clone() :: BasePart
            part.Transparency = 1
            part.CFrame = CFrame.new(pos)
            part.Parent = workspace.Terrain
            Debris:AddItem(part, 5)

            RunService.Heartbeat:Wait()

            local ui = part.BillboardGui.Label :: TextLabel
            ui.Text = text
            ui.TextColor3 = color or Color3.new(1, 1, 1)


            Promise.delay(1.5):andThen(function()
                HarukaLib:CreateTween(ui, AssetBook.TweenInfos.half, { TextTransparency = 1 }):Play()
                HarukaLib:CreateTween(ui.UIStroke, AssetBook.TweenInfos.twiceHalf, { Transparency = 1 }):Play()

            end):catch(function() end)

            random = nil

        end):catch(function() end)
    end
    Events.ShowText.On(function(data)
        _spawnText(data.Target, data.Text, data.TextColor)
    end)
end)



table.insert(ClientWorldLib.Funcs, function()
    local function _onHit(entity: Model)
        if not ClientLib.IsModelValid(entity) then return end
        if not entity:IsDescendantOf(workspace) then return end

        local distance = plr:DistanceFromCharacter(entity.PrimaryPart.Position)
        if distance <= 0 or distance > focusRenderDistance then return end


        Promise.try(function()
            local hitHighlight = ReplicatedStorage.Packages.Effects.HitHighlight:Clone() :: Highlight
            hitHighlight.Adornee = entity
            hitHighlight.Parent = entity

            Debris:AddItem(hitHighlight, 1)

            HarukaLib:CreateTween(hitHighlight, AssetBook.TweenInfos.one, {
                FillTransparency = 1,
                OutlineTransparency = 1
            }):Play()


            local hitEff = ReplicatedStorage.Packages.Effects.HitEffect.BillboardGui:Clone() :: BillboardGui
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
    Events.PlayHitStatusVFX.On(function(data)
        _onHit(data.Target)
    end)
end)



table.insert(ClientWorldLib.Funcs, function()
    local function _doSimpleVFXEntity(holder: BasePart)
        if not holder:IsDescendantOf(workspace) then return end

        local distance = plr:DistanceFromCharacter(holder.Position)
        if distance <= 0 or distance > focusRenderDistance then return end

        HarukaLib:EmitParticles(holder)
    end
    CollectionService:GetInstanceAddedSignal("VFXEntity"):Connect(_doSimpleVFXEntity)


    local function _doComplexVFXEntity(holder: BasePart)
        if not holder:IsDescendantOf(workspace) then return end

        local distance = plr:DistanceFromCharacter(holder.Position)
        if distance <= 0 or distance > focusRenderDistance then return end

        if not ComplexVFXLib[holder.Name] then
            warn("Invalid Complex VFX ID: ".. holder.Name)
            return
        end

        Promise.try(ComplexVFXLib[holder.Name], holder):catch(function(err)
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
    local itemDisplayContainer = Instance.new("Folder")
    itemDisplayContainer.Name = "ItemDisplayContainer"
    itemDisplayContainer.Parent = workspace.MapComponents

    local RNG = Random.new()

    Events.SpawnItemDrop.On(function(data)
        local location = data.ItemDropLocationPos :: Vector3
        local autoPickup = data.AllowAutoPickUp

        location += Vector3.new(
            RNG:NextInteger(-6, 6), 0, RNG:NextInteger(-6, 6)
        )
        location = ClientLib.FindGroundByRay(location)

        for _ = 1, data.ItemAmount do
            local itemSphere = ReplicatedStorage.Packages.Effects.ItemDisplay:Clone() :: BasePart

            itemSphere.CFrame = CFrame.new(location) * CFrame.new(0, itemSphere.Size.Y / 2, 0)
            itemSphere:SetAttribute("HarukaUniqueId", data.ItemUniqueId)
            itemSphere:AddTag("ItemDisplayEntity")
            itemSphere.Anchored = true
            itemSphere.CanCollide = false

            itemSphere:SetAttribute("AutoPickup", data.AllowAutoPickUp)

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

            for _, child: Instance in itemSphere:GetDescendants() do
                if child:IsA("ParticleEmitter") then
                    child.Color = ColorSequence.new(color)
                end
            end
            itemSphere.A0.Beam.Color = ColorSequence.new(color)
            itemSphere.A1.PointLight.Color = color
            itemSphere.Parent = itemDisplayContainer
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


            Events.RequestToPickupItemDrops.Fire({
                ItemUniqueId = itemSphere:GetAttribute("HarukaUniqueId") or "nil"
            })

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

                local curvePos = Bezier.CubicBezier(elapsed, start.Position, mid1, mid2, hit.Position)

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
    Events.OpenChestClientTween.On(function(data)
        local chest = data.Chest :: Model
        if not ClientLib.IsModelValid(chest) then return end

        SoundService.SFXs.ChestDrop:Play()

        HarukaLib:Tween(
            chest.Top,
            AssetBook.TweenInfos.twiceHalf,
            { Pivot = chest.Top.PrimaryPart.CFrame * CFrame.Angles(math.rad(50), 0, 0) }
        )
    end)
end)


table.insert(ClientWorldLib.Funcs, function()
    local clientObjContainerAFK = Instance.new("Folder")
    clientObjContainerAFK.Name = "ClientObjsContainerAFK"
    clientObjContainerAFK.Parent = game:GetService("ServerStorage")

    local clientObjContainer = Instance.new("Folder")
    clientObjContainer.Name = "ClientObjsContainer"
    clientObjContainer.Parent = workspace.MapComponents


    local windmillWings = {}
    local galleons = {}


    local function _handleWindmill(windmill: Model)
        repeat wait() until windmill and windmill.PrimaryPart

        wait()
        table.insert(windmillWings, windmill)
    end
    local function _handleGalleon(galleon: Model)
        repeat wait() until galleon and galleon.PrimaryPart

        wait()
        table.insert(galleons, galleon)
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
            for _, wing: Model in windmillWings do
                pcall(function()
                    wing.PrimaryPart.CFrame *= CFrame.Angles(math.rad(-1.7), 0, 0)
                end)
            end
        end
    end)
    task.spawn(function()
        while wait(0.01) do
            for _ = 1, 50 do
                for _, galleon: Model in galleons do
                    pcall(function()
                        galleon.PrimaryPart.CFrame *= CFrame.new(0, 0.04, 0)
                    end)
                end
                wait(0.01)
            end
            for _ = 1, 50 do
                for _, galleon: Model in galleons do
                    pcall(function()
                        galleon.PrimaryPart.CFrame *= CFrame.new(0, -0.04, 0)
                    end)
                end
                wait(0.01)
            end
        end
    end)


    HarukaLib.Clock(2, function()
        for _, wing: Model in windmillWings do
            pcall(function()
                local distance = plr:DistanceFromCharacter(wing.PrimaryPart.Position)
                if distance <= 0 or distance > focusRenderDistance then
                    wing.Parent = clientObjContainerAFK
                else
                    wing.Parent = clientObjContainer
                end
            end)
        end
    end)
end)


table.insert(ClientWorldLib.Funcs, function()
    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, player: Player)
        if plr ~= player then return end

        local adornee = prompt.Parent :: BasePart
        local char = plr.Character

        if not adornee:IsA("BasePart") then
            warn("Invalid adornee for proximity prompt")
            return
        end
        if not ClientLib.IsCharValid(char) then return end

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


ClientWorldLib:Init()