
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
local TeleportService = game:GetService("TeleportService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassAttackLib = require(SSS.HarukaServer.Library.ClassAttackLib)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)
local CastItemLib = require(SSS.HarukaServer.Library.CastItemLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local QuestBindables = require(RepS.HarukaShared.Library.QuestBindables)
local DoTLib = require(SSS.HarukaServer.Services.DoTLib)



export type GlobalCriRPGLibClass = {
    Funcs: { () -> nil },

    Init: (self: GlobalCriRPGLibClass) -> nil
}




local GlobalCriRPGLib = {} :: GlobalCriRPGLibClass
GlobalCriRPGLib.Funcs = {}

local wait = task.wait


--// Constructor

function GlobalCriRPGLib:Init()
    for _, func: () -> nil in GlobalCriRPGLib.Funcs do
        task.spawn(func)
    end
end


--// Private Methods


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToForceReset.SetCallback(function(plr: Player)
        local char = plr.Character

        if not plr.Character then return end

        if char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = -1
        end
    end)


    Events.RequestToRejoinGame.SetCallback(function(plr: Player)
        local worldId = workspace:GetAttribute("WorldId") :: string

        if worldId and worldId == "InitusWorld" then
            TeleportService:Teleport(game.PlaceId, plr)
        end
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    ServerBindables.RToSpawnChar:Connect(function(plr: Player)
        if not plr then return end
        if not plr:IsDescendantOf(Players) then return end
        if plr:GetAttribute("IsLeaving") then return end


        if plr.Character then
            wait(Players.RespawnTime)
            if plr.Character then
                plr.Character:Destroy()
                plr.Character = nil
            end
        end


        if not plr then return end
        if not plr:IsDescendantOf(Players) then return end
        if plr:GetAttribute("IsLeaving") then return end

        local r6Char: Model

        Promise.new(function(resolve)
            local humanoidDesc = Players:GetHumanoidDescriptionFromUserId(plr.UserId)
            r6Char = Players:CreateHumanoidModelFromDescription(humanoidDesc, Enum.HumanoidRigType.R6)
            r6Char.Name = plr.Name

            resolve("Completed")

        end):timeout(5):catch(function()

            r6Char = RepS.Packages.Unloads.DummyH:Clone() :: Model
        end):await()

        --- keep retrying
        if r6Char.Name == "DummyH" then
            Promise.retryWithDelay(function()
                return Promise.new(function(resolve)
                    local humanoidDesc = Players:GetHumanoidDescriptionFromUserId(plr.UserId)

                    resolve(humanoidDesc)

                end):timeout(5):catch(function()

                end)

            end, 3, 6):andThen(function(humanoidDesc: HumanoidDescription)
                local r6Char = r6Char :: Model
                local r6Humanoid = r6Char.Humanoid :: Humanoid

                r6Humanoid:ApplyDescription(humanoidDesc)

            end):catch(function()

            end)
        end

        local r6Char = r6Char :: Model
        local r6Humanoid = r6Char.Humanoid :: Humanoid

        r6Char.Archivable = true
        r6Char.Name = plr.Name
        r6Char:PivotTo(CFrame.new(Vector3.yAxis * 159))

        r6Humanoid.DisplayName = plr.DisplayName
        r6Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        r6Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        r6Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)

        r6Char.Animate:Destroy()
        r6Char.PrimaryPart = r6Humanoid.RootPart

        r6Char:SetAttribute("HarukaUniqueId", HttpService:GenerateGUID(false))

        local alignMoverAtt = Instance.new("Attachment")
        alignMoverAtt.Name = "AlignMoverAttachment"
        alignMoverAtt.Parent = r6Char.PrimaryPart

        HarukaLib:SetCollisionGroup(r6Char, "PlayerBodyPart")

        plr.Character = r6Char


        --// clear collision box
        for _, part: BasePart in r6Char:GetChildren() do
            if not HarukaLib:IsBasePartType(part) then continue end
            if part == r6Char.PrimaryPart then continue end

            part.EnableFluidForces = false
            part.CanCollide = false
            part.Material = Enum.Material.SmoothPlastic
        end


        r6Char:SetAttribute("SpawnClock", DateTime.now().UnixTimestamp)
        r6Char.Parent = workspace.EntitiesPlayerChar


        for _, thatScript: Instance in StarterPlayer.StarterCharacterScripts:GetChildren() do
            thatScript:Clone().Parent = r6Char
        end
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    local function _sitGalleon(galleon: Model, plr: Player)
        local seat = galleon:FindFirstChildOfClass("Seat")
        if not seat then return end

        local galleon = galleon

        galleon.PrimaryPart.Anchored = false
        galleon.PrimaryPart.AssemblyLinearVelocity = Vector3.zero


        seat:Sit((plr.Character :: any).Humanoid)
        seat:GetPropertyChangedSignal("Occupant"):Connect(function()
            local occupant = seat.Occupant
            if occupant == nil then
                if not ServerLib.IsModelValid(galleon) then return end

                if galleon.PrimaryPart:FindFirstChild("AlignPosition") then
                    galleon.PrimaryPart:FindFirstChild("AlignPosition"):Destroy()
                end
                galleon.PrimaryPart.Anchored = true
                galleon.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
            end
        end)


        if galleon.PrimaryPart:FindFirstChild("AlignPosition") then
            galleon.PrimaryPart:FindFirstChild("AlignPosition"):Destroy()
        end

        local alignPos = Instance.new("AlignPosition")
        alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
        alignPos.Attachment0 = Instance.new("Attachment", galleon.PrimaryPart)
        alignPos.ForceLimitMode = Enum.ForceLimitMode.PerAxis
        alignPos.ForceRelativeTo = Enum.ActuatorRelativeTo.Attachment0
        alignPos.MaxAxesForce = Vector3.one * 5000000
        alignPos.Responsiveness = 15
        alignPos.Position = galleon.PrimaryPart.Position
        alignPos.Parent = galleon.PrimaryPart


        pcall(function()
            galleon.PrimaryPart:SetNetworkOwner(nil)
        end)
        Events.SetSkyGalleon.Fire(plr, {
            Galleon = galleon
        })
    end
    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, plr: Player)
        if prompt.Enabled == false then return end

        local adornee = prompt.Parent :: BasePart
        local char = plr.Character

        if plr == nil then return end
        if not adornee:IsA("BasePart") then
            warn("Invalid adornee for proximity prompt")
            return
        end

        if not ServerLib.IsCharValid(char) then return end

        local distance = plr:DistanceFromCharacter(adornee.Position)
        if distance > prompt.MaxActivationDistance + 3 or distance < 0 then return end


        if plr:FindFirstChild("PromptTriggerCD") then return end

        local promptCDSymbol = Instance.new("BoolValue")
        promptCDSymbol.Value = true
        promptCDSymbol.Name = "PromptTriggerCD"
        promptCDSymbol.Parent = plr
        Debris:AddItem(promptCDSymbol, 0.3)


        if prompt.Name == "Chat" then
            local npc = prompt:FindFirstAncestorOfClass("Model")
            if not npc then return end
            if not npc:FindFirstChild("Dialogues") then return end

            if not ServerLib.IsCharValid(char) then return end
            if char:GetAttribute("IsInCombat") then
                Events.CreateNotify.Fire(plr, "You can't talk to NPCs while in combat!")
                return
            end

            if char:GetAttribute("IsChatting") then
                Events.CreateNotify.Fire(plr, "You are already in a chat with another NPC!")
                return
            end

            char:SetAttribute("IsChatting", true)

            Events.EnterNPCChat.Fire(plr, {
                NPCModel = npc
            })

        elseif prompt.Name == "Chest" then
            local chest = prompt:FindFirstAncestorOfClass("Model")

            if not ItemBook:GetItemInfo(chest.Name) then
                Events.CreateNotify.Fire(plr, "[Error] Invalid Chest")
                return
            end
            if chest:GetAttribute("Receiver_"..plr.Name) then
                Events.CreateNotify.Fire(plr, "You have already opened this treasure chest!")
                return
            end

            chest:SetAttribute("Receiver_"..plr.Name, true)

            Events.OpenChestClientTween.Fire(plr, {
                Chest = chest
            })

            ServerLib.GiveItemDrop(plr, chest.Name, chest:GetAttribute("Amount") or 1)

        elseif prompt.Name == "Market" then
            local products = {}
            local market = prompt:FindFirstAncestorOfClass("Model")
            local productsFolder = market.Products :: Folder


            for _, product: Instance in productsFolder:GetChildren() do
                if ItemBook:GetItemInfo(product.Name) then
                    table.insert(products, {
                        ProductId = product.Name,
                        ProductUniqueId = product:GetAttribute("HarukaUniqueId")
                    })
                end
            end

            Events.OpenMarketUI.Fire(plr, {
                Products = products
            })

        elseif prompt.Name == "Crafting" then
            adornee:AddTag("CraftingPromptEntity")

            Events.OpenCraftingUI.Fire(plr)


        elseif prompt.Name == "AbyssView" then
            Events.OpenAbyssUI.Fire(plr)


        elseif prompt.Name == "BoatSummon" then
            for _, galleon: Model in CollectionService:GetTagged("SkyDriveGalleon") do
                if not galleon:FindFirstChild("Owner") then galleon:Destroy() continue end

                if (galleon :: any).Owner.Value == plr then
                    galleon:Destroy()
                    continue
                end
            end

            local galleon = RepS.Packages.Unloads.SkyDriveGalleon:Clone() :: Model
            galleon:PivotTo(adornee._DOCK.CFrame * CFrame.new(0, 10, 0))


            HarukaLib:SetCollisionGroup(galleon, "EnemyProjectile")
            galleon.PrimaryPart.CustomPhysicalProperties = PhysicalProperties.new(Enum.Material.Wood)
            galleon.Humanoid.WalkSpeed = 80


            local owner = Instance.new("ObjectValue")
            owner.Name = "Owner"
            owner.Value = plr
            owner.Parent = galleon


            galleon:AddTag("SkyDriveGalleon")
            galleon.PrimaryPart.Anchored = false
            galleon.PrimaryPart.Massless = false
            galleon.Parent = workspace


            _sitGalleon(galleon, plr)

        elseif prompt.Name == "BoatEnter" then
            local galleon = prompt:FindFirstAncestorOfClass("Model")
            if not galleon then return end

            _sitGalleon(galleon, plr)


        elseif prompt.Name == "DungeonPortal" then
            char:PivotTo((prompt :: any).Destination.Value.CFrame)


        elseif prompt.Name == "Class" then
            local statue = prompt:FindFirstAncestorOfClass("Model")

            local plr = plr
            local items = plr.Items :: Folder
            if not items:FindFirstChild(statue.Weapon.Value) then
                ServerLib.GiveItemDrop(plr, statue.Weapon.Value, 1)
            else
                Events.CreateNotify.Fire(plr, " You've already received the Goddess's blessing!")
            end


        elseif prompt.Name == "PurchaseTicket" then
            local merchantId = adornee.Name

            Events.OpenTicketPurchaseUI.Fire(plr, {
                MerchantId = merchantId
            })

        elseif prompt.Name == "Material" then
            local material = prompt:FindFirstAncestorOfClass("Model")
            local itemInfo = ItemBook:GetItemInfo(material.Name)


            if itemInfo == nil then return end
            if not prompt:IsDescendantOf(workspace) then return end
            if not ServerLib.IsCharValid(char) then return end


            if material:GetAttribute("Profession") then
                if not char:GetAttribute(material:GetAttribute("Profession")) then
                    Events.CreateNotify.Fire(plr, "You cannot gather this material. Maybe you need a tool.")
                    return
                end
            end
            prompt.Enabled = false


            local finalMaterial = material.Name
            if material:GetAttribute("Rare") then
                finalMaterial = HarukaLib:RollLoot({
                    [material:GetAttribute("Rare")] = 35,
                    [material.Name] = 65
                })
            end
            material.Parent = game:GetService("ServerStorage")


            local amount = #material.Collectables:GetChildren()
            amount += math.random(-1, 1)
            amount /= 2
            amount = math.floor(amount)


            local tempModel = HarukaLib:CreateMockModel()
            tempModel:PivotTo(CFrame.new(adornee.Position + Vector3.yAxis * 3))
            tempModel.Parent = workspace
            Debris:AddItem(tempModel, 5)


            Events.PlayHitStatusVFX.FireList(ServerLib.GetNearbyPlayers(adornee.Position), {
                Target = tempModel,
            })
            ServerLib.PlaceItemDropPart(plr, finalMaterial, amount, adornee.Position + Vector3.new(
                math.random(-8, 8), 0, math.random(-8, 8)
            ), true)

            Promise.delay(math.random(60, 100)):andThen(function()
                material.Parent = workspace.MapComponents.Materials

                prompt.Enabled = true
            end)
        end
    end)
end)



table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToDMGPlayer.SetCallback(function(plr: Player, data)
        if data.ProjectileUniqueId == nil then return end
        if data.IsPierce == nil then return end
        if data.DoTStatus == nil then return end


        local projectileUniqueId = data.ProjectileUniqueId
        local projectileList = ServerStorage.ProjectileSymbolContainer :: Folder

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end
        if not projectileList:FindFirstChild(projectileUniqueId) then return end
        if not char:GetAttribute("IsInCombat") then return end


        local symbol = projectileList[projectileUniqueId]
        local projectileDMG = symbol:GetAttribute("Damage") :: number

        local owner = symbol.Owner.Value :: Model
        if not ServerLib.IsCharValid(owner) then return end


        Promise.new(function(resolve)
            local result, _, _ = HarukaLib:RollLoot({
                Dodge = char:GetAttribute("DodgeChance"),
                None = 100 - char:GetAttribute("DodgeChance")
            })
            if result == "Dodge" then
                projectileDMG = 0

                ServerLib.ShowText(char, "DODGE!", Color3.fromHex('#ffffff'))
            end
            resolve()

        end):catch(function() end):await()


        if projectileDMG <= 0 then return end


        ServerLib.ShowNumber(char, projectileDMG, Color3.fromRGB(255, 0, 0))
        ServerLib.ApplyHitStatus(char)


        if char:GetAttribute("Shield") > 0 and not data.IsPierce then
            local afterShield = math.ceil(char:GetAttribute("Shield") - projectileDMG)

            afterShield = math.clamp(afterShield, 0, 1599 * 40 * 40)

            char:SetAttribute("Shield", afterShield)
            char.PlayerGotHit:Fire(char.Name, projectileDMG, "Shield")

            Events.PlaySound.Fire(plr, SoundService.SFXs.ShieldAbsorb)

            if afterShield <= 0 then
                Events.PlaySound.Fire(plr, SoundService.SFXs.ShieldBroken)

                local exceededDMG = projectileDMG
                if exceededDMG > 0 then
                    exceededDMG = math.ceil(exceededDMG / 1.599)
                    char.Humanoid:TakeDamage(exceededDMG)

                    Events.PlayGotHitScreenFX.Fire(plr)

                    char.PlayerGotHit:Fire(char.Name, exceededDMG, "Health")
                end
            end
        else
            if data.IsPierce then
                ServerLib.ShowText(char, "PIERCE!", Color3.fromRGB(255, 255, 255))
            end

            char.Humanoid:TakeDamage(projectileDMG)
            char.PlayerGotHit:Fire(char.Name, projectileDMG, "Health")

            Events.PlayGotHitScreenFX.Fire(plr)
        end
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToDMGEnemy.SetCallback(function(plr: Player, data)
        local orbUniqueId = data.OrbUniqueId
        if orbUniqueId == nil then return end

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Character")
            return
        end
        if not ServerStorage.OrbSymbolContainer:FindFirstChild(orbUniqueId, true) then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Orb Identity")
            warn("Invalid orb identity")
            return
        end

        local symbol = ServerStorage.OrbSymbolContainer:FindFirstChild(orbUniqueId, true) :: CFrameValue
        if symbol:GetAttribute("Owner") ~= char.Name then return end

        local thatOrbStyle = symbol:GetAttribute("OrbStyle") :: string
        local thatOrbSubStyle = symbol:GetAttribute("OrbSubStyle") :: string

        local orbPos = symbol.Value :: CFrame
        symbol:Destroy()


        local check = true
        local whiteList = { "HEAL_ATTACK" }

        Promise.new(function(resolve, reject)
            local DISTANCE = 25

            local distance1 = plr:DistanceFromCharacter(orbPos.Position)
            local distance2 = plr:DistanceFromCharacter(orbPos.Position + Vector3.yAxis * DISTANCE)
            local distance3 = plr:DistanceFromCharacter(orbPos.Position - Vector3.yAxis * DISTANCE)

            local minDistance = math.min(distance1, distance2, distance3)

            if distance1 < DISTANCE or distance2 < DISTANCE or distance3 < DISTANCE then
                resolve()
            else
                reject("Distance")
            end
            if distance1 <= 0 or distance2 <= 0 or distance3 <= 0 then reject("Distance") end
            if minDistance > DISTANCE * math.clamp(plr:GetNetworkPing() / 150, 1, 2) then reject("Distance") end

            if not table.find(whiteList, thatOrbStyle) then
                local class = plr:GetAttribute("Class") :: string

                if class ~= thatOrbStyle then reject("ClassId") end
            end

        end):catch(function(reason: string)
            check = false

            if tostring(reason) == "Distance" then Events.CreateNotify.Fire(plr, "You are too far away from orb!") end
            if tostring(reason) == "ClassId" then
                warn("Invalid ClassId for orb")
            end
        end)
        if not check then return end


        Promise.new(function()
            if table.find(whiteList, thatOrbStyle) then
                local class = plr:GetAttribute("Class") :: string

                thatOrbStyle ..= "_"..class
            end
            if thatOrbSubStyle then
                thatOrbStyle ..= "_"..thatOrbSubStyle
            end
            if not ClassAttackLib[thatOrbStyle] then
                warn(`[Error]: ClassAttackLib Func for {thatOrbStyle} not found`)
                return
            end


            ClassAttackLib[thatOrbStyle](plr)

        end):catch(function(err)
            warn(tostring(err))
        end)
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToCastItem_Request.SetCallback(function(plr: Player, data)
        local slotId = data.SlotId
        if slotId == nil then return end


        local char = plr.Character
        if not ServerLib.IsCharValid(char) then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Character")
            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end

        local plr = plr
        local equippingItems = plr.EquippingItems :: Folder
        local equippingInfo = equippingItems:FindFirstChild(slotId) :: StringValue

        if not equippingInfo then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Equip Info")
            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end

        local itemInfo = ItemBook:GetItemInfo(equippingInfo.Value)
        if not itemInfo then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Item Info")
            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end

        local items = plr.Items :: Folder
        local itemSymbol = items:FindFirstChild(equippingInfo.Value) :: IntConstrainedValue

        if not itemSymbol then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Item")
            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end

        local amount = items[equippingInfo.Value].Value or 0 :: number
        if amount <= 0 then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Amount")
            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end


        local inCDCheck = false
        for _, cdSymbol: BoolValue in CollectionService:GetTagged("ItemCDSymbol") do
            if cdSymbol.Name == plr.UserId and cdSymbol:GetAttribute("ItemId") == itemInfo.ItemId then
                inCDCheck = true
                break
            end
        end
        if inCDCheck then
            Events.CreateNotify.Fire(plr, "The item is still on cooldown!")
            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end

        local realCD = tonumber(itemInfo.ExtraStatInfoDesync.CD)
        if not realCD then
            warn("Invalid CD for item")

            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end

        --// intensity
        local intensity = char:GetAttribute("Intensity") or 0

        local reduce = realCD * (intensity / 100)
        realCD -= reduce
        realCD = math.ceil(realCD)
        realCD = math.max(0, realCD)


        if itemInfo.Type == "Consumable" then
            itemSymbol.Value -= 1

            --// item run out
            if itemSymbol.Value <= 0 then
                itemSymbol:Destroy()
                equippingInfo:Destroy()
            end
        end
        if not CastItemLib[itemInfo.ItemId] then
            warn("Invalid CastItemLib function")

            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end



        local badStatus = false
        Promise.try(function()
            local statusCode = CastItemLib[itemInfo.ItemId](plr, char, {}) :: number?

            if statusCode and statusCode == 0 then
                badStatus = true
            end
        end):catch(function(err)
            warn(tostring(err))
        end)
        if badStatus then
            if RunService:IsStudio() then
                Events.CreateNotify.Fire(plr, "[Error] Invalid Function Status Code")
            end

            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end


        local itemCDSymbol = Instance.new("BoolValue")
        itemCDSymbol.Value = true
        itemCDSymbol.Name = plr.UserId
        itemCDSymbol:SetAttribute("ItemId", itemInfo.ItemId)
        itemCDSymbol:AddTag("ItemCDSymbol")
        itemCDSymbol.Parent = ServerStorage.ItemCDSymbolContainer
        Debris:AddItem(itemCDSymbol, realCD)

        Events.RequestToCastItem_Response.Fire(plr, {
            SlotId = slotId,
            CooldownTime = realCD
        })
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToPickupItemDrops.SetCallback(function(plr: Player, data)
        local itemUniqueId = data.ItemUniqueId
        if itemUniqueId == nil then return end

        local itemSymbol = ServerStorage.ItemSphereSymbolContainer:FindFirstChild(itemUniqueId) :: IntValue?

        if not itemSymbol then return end
        if itemSymbol:GetAttribute("Receiver") ~= plr.Name then return end
        if itemSymbol.Value <= 0 then return end


        itemSymbol.Value -= 1
        ServerLib.GiveItemDrop(plr, itemSymbol:GetAttribute("ItemId"), 1)


        if itemSymbol.Value <= 0 then itemSymbol:Destroy() end
    end)
end)



table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToCastClassUlt.SetCallback(function(plr: Player)
        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end
        if not char:GetAttribute("IsInCombat") then return end


        --// cast Ult if req meets
        local class = plr:GetAttribute("Class") :: string
        local variant = plr:GetAttribute("ClassVariant") :: string

        if char:GetAttribute("ClassUltProgress") >= char:GetAttribute("MaxClassUltProgress") then
            char:SetAttribute("ClassUltProgress", 0)

            Promise.new(function()
                if not ClassAttackLib[class.."_Ult_"..variant] then
                    warn(`ClassAttackLib ult Func for {class} not found`)

                    Events.CreateNotify.Fire(plr, "[Error] Missing ult Func, please contact the developer!")
                    return
                end

                ClassAttackLib[class.."_Ult_"..variant](plr)

            end):catch(function(err)
                warn(tostring(err))
            end)
        end
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToEndNPCChat.SetCallback(function(plr: Player, data)
        if data.NPCId == nil then return end
        if data.SeriesId == nil then return end


        local npcModel: Model? = nil
        for _, npc: Model in CollectionService:GetTagged("NPCEntity") do
            if npc.Name == data.NPCId then
                npcModel = npc
                break
            end
        end
        if not npcModel then return end

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        char:SetAttribute("IsChatting", nil)


        local npcModel = npcModel
        local dialogues = npcModel.Dialogues :: Configuration

        --// do signal
        local extra = require(dialogues.Main).Extra
        local bindableId = extra[data.SeriesId] :: string?

        if bindableId then
            if QuestBindables[bindableId] then
                QuestBindables[bindableId]:Fire(plr)
            end
        end
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToEquipItem.SetCallback(function(plr: Player, data)
        if data.ItemId == nil then return end
        if data.ItemUniqueId == nil then return end

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't equip item in combat!")
            return
        end

        local itemInfo = ItemBook:GetItemInfo(data.ItemId)
        if not itemInfo then return end

        local plr = plr
        local items = plr.Items :: Folder
        local itemSymbol = items:FindFirstChild(data.ItemId) :: IntConstrainedValue

        if itemSymbol == nil then return end

        local amount = itemSymbol.Value or 0 :: number
        if amount <= 0 then return end

        local level = itemInfo.Level
        if level > plr:GetAttribute("Level") then
            Events.CreateNotify.Fire(plr, "You don't meet the level requirement to equip this item!")
            return
        end


        local whiteList = { "Accessory", "Active", "Consumable", "Weapon" }
        if not table.find(whiteList, itemInfo.Type) then
            Events.CreateNotify.Fire(plr, "You can't equip this item! Invalid Item Type")
            return
        end


        local function _refresh()
            local refreshSymbol = Instance.new("StringValue")
            refreshSymbol.Name = "_NULL"
            refreshSymbol.Value = "_NULL"
            refreshSymbol:SetAttribute("HarukaUniqueId", "1599mkk40")
            refreshSymbol.Parent = plr.EquippingItems
            Debris:AddItem(refreshSymbol, 1)
        end


        --// equip weapon
        if itemInfo.Type == "Weapon" then
            local weapon1Symbol = plr.EquippingItems:FindFirstChild("Weapon1") :: StringValue
            if not weapon1Symbol then
                weapon1Symbol = Instance.new("StringValue")
                weapon1Symbol.Name = "Weapon1"
            end

            ServerLib.UnequipItem(plr, weapon1Symbol:GetAttribute("HarukaUniqueId"))

            weapon1Symbol:SetAttribute("HarukaUniqueId", data.ItemUniqueId)
            weapon1Symbol.Value = data.ItemId
            weapon1Symbol.Parent = plr.EquippingItems

            _refresh()
            ServerLib.EquipItem(plr, data.ItemUniqueId)

            Events.PlaySound.Fire(plr, SoundService.SFXs.EXP)
            return
        end


        local equipping = plr.EquippingItems :: Folder

        --// whether it's equipped or not
        local equipCheck = true
        for _, symbol: StringValue in equipping:GetChildren() do
            if symbol:GetAttribute("HarukaUniqueId") == data.ItemUniqueId then
                equipCheck = false

                symbol:Destroy()
                ServerLib.UnequipItem(plr, data.ItemUniqueId)

                Events.PlaySound.Fire(plr, SoundService.SFXs.EquipItem)
                break
            end
        end
        if not equipCheck then return end



        --// already equipped same item id? (Crimson1 != Crimson2)
        local sameItemCheck = false
        for _, symbol: StringValue in equipping:GetChildren() do
            if symbol.Value == data.ItemId then
                sameItemCheck = true
                break
            end
            if string.match(symbol.Value, "^(%w+)%d*$") == string.match(data.ItemId, "^(%w+)%d*$") then
                sameItemCheck = true
                break
            end
        end
        if sameItemCheck then
            Events.CreateNotify.Fire(plr, "You have already equipped this item!")
            return
        end


        --// check available slot
        local check = false

        for i = 1, 3 do
            local goalType = itemInfo.Type
            if goalType == "Consumable" then
                goalType = "Active"
            end
            if goalType == "Passive" then
                goalType = "Accessory"
            end

            if equipping:FindFirstChild(goalType..tostring(i)) == nil then
                check = true

                local itemVal = Instance.new("StringValue")
                itemVal.Name = goalType..tostring(i)
                itemVal.Value = data.ItemId

                itemVal:SetAttribute("HarukaUniqueId", data.ItemUniqueId)
                itemVal.Parent = plr.EquippingItems

                _refresh()
                ServerLib.EquipItem(plr, data.ItemUniqueId)


                Events.PlaySound.Fire(plr, SoundService.SFXs.EquipItem)
                break
            end
        end
        if not check then
            Events.CreateNotify.Fire(plr, "You don't have enough slots to equip more items!")
            return
        end
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToPurchaseItem.SetCallback(function(plr: Player, data)
        local product, purchaseAmount = data.ProductId, data.PurchaseAmount
        if product == nil then return end
        if data.ProductUniqueId == nil then return end
        if purchaseAmount == nil then return end

        if purchaseAmount > 99 then
            Events.CreateNotify.Fire(plr, "You can't purchase more than 99 items at once!")
            return
        end

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't purchase items in combat!")
            return
        end

        local distanceCheck = false
        for _, market: Model in CollectionService:GetTagged("MarketEntity") do
            local distance = plr:DistanceFromCharacter(market.WorldPivot.Position)
            if distance > 0 and distance <= 45 then
                distanceCheck = true
                break
            end
        end
        if not distanceCheck then
            Events.CreateNotify.Fire(plr, "You are too far from the Market!")
            return
        end


        local itemInfo = ItemBook:GetItemInfo(product)
        if not itemInfo then return end


        local totalPrice = itemInfo.Price * purchaseAmount
        local curGold = plr:GetAttribute("Gold") :: number

        if curGold < totalPrice then
            Events.CreateNotify.Fire(plr, "You don't have enough Gold to purchase this item!")
            return
        end

        Events.CreateNotify.Fire(plr, "Purchase successful! Welcome back!")

        HarukaLib:AddAttr(plr, "Gold", -totalPrice)
        Events.PlaySound.Fire(plr, SoundService.SFXs.Buy)

        ServerLib.GiveItemDrop(plr, product, purchaseAmount)
    end)
    Events.RequestToSellItem.SetCallback(function(plr: Player, data)
        local item, sellAmount = data.ItemId, data.SellAmount
        if item == nil then return end
        if data.ItemUniqueId == nil then return end
        if sellAmount == nil then return end

        --// cant sell more than 999 items at once
        if sellAmount > 999 then
            Events.CreateNotify.Fire(plr, "You can't sell more than 999 items at once!")
            return
        end


        --// cant sell items in combat
        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't sell items in combat!")
            return
        end


        local distanceCheck = false
        for _, market: Model in CollectionService:GetTagged("MarketEntity") do
            local distance = plr:DistanceFromCharacter(market.WorldPivot.Position)
            if distance > 0 and distance <= 45 then
                distanceCheck = true
                break
            end
        end
        if not distanceCheck then
            Events.CreateNotify.Fire(plr, "You are too far from the Market!")
            return
        end


        --// cant sell items obtained from chests / nil
        local itemInfo = ItemBook:GetItemInfo(item)
        if not itemInfo then return end


        if itemInfo.Type == "Passive" then
            Events.CreateNotify.Fire(plr, "You can't sell your Passive items!")
            return
        end
        if itemInfo.Type == "Quest" then
            Events.CreateNotify.Fire(plr, "You can't sell your Quest items!")
            return
        end
        local foundInChest = false
        for _, chest in CollectionService:GetTagged("ChestEntity") do
            if chest.Name == itemInfo.ItemId then
                foundInChest = true
                break
            end
        end
        if foundInChest then
            Events.CreateNotify.Fire(plr, "You cannot sell items obtained from Overworld Chests!")
            return
        end


        --// cant sell items that is not existed
        local plr = plr
        local items = plr.Items :: Folder
        local itemSymbol = items:FindFirstChild(item) :: IntConstrainedValue
        if itemSymbol == nil then return end

        itemSymbol = nil
        for _, symbol: IntConstrainedValue in items:GetChildren() do
            if symbol:GetAttribute("HarukaUniqueId") == data.ItemUniqueId then
                itemSymbol = symbol
                break
            end
        end
        if not itemSymbol then return end


        --// cant sell equipped item
        local equipping: StringValue = nil
        for _, symbol: StringValue in plr.EquippingItems:GetChildren() do
            if symbol:GetAttribute("HarukaUniqueId") == data.ItemUniqueId then
                equipping = symbol
                break
            end
        end
        if equipping then
            Events.CreateNotify.Fire(plr, "You can't sell your equipped item!")
            return
        end

        --// cant sell locked item
        if itemSymbol:GetAttribute("IsLocked") then
            Events.CreateNotify.Fire(plr, "You can't sell locked item!")
            return
        end


        local totalItemHas = itemSymbol.Value or 0 :: number
        if totalItemHas < sellAmount then
            sellAmount = totalItemHas
        end

        itemSymbol.Value -= sellAmount
        if itemSymbol.Value <= 0 then
            itemSymbol:Destroy()
        end


        local totalPrice = itemInfo.SellPrice * sellAmount

        Events.PlaySound.Fire(plr, SoundService.SFXs.Buy)
        Events.CreateNotify.Fire(plr, "Sell successful! Welcome back!")


        HarukaLib:AddAttr(plr, "Gold", totalPrice)
    end)
    Events.RequestToSellAllItems.SetCallback(function(plr: Player, data)
        if not data.ItemId then return end

        local item = data.ItemId

        --// cant not sell nil items
        local itemInfo = ItemBook:GetItemInfo(item)
        if not itemInfo then return end


        --// cant sell passive items
        if itemInfo.Type == "Passive" then
            Events.CreateNotify.Fire(plr, "You can't sell your Passive items!")
            return
        end
        if itemInfo.Type == "Quest" then
            Events.CreateNotify.Fire(plr, "You can't sell your Quest items!")
            return
        end

        --// cant sell items in combat
        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't purchase items in combat!")
            return
        end


        local distanceCheck = false
        for _, market: Model in CollectionService:GetTagged("MarketEntity") do
            local distance = plr:DistanceFromCharacter(market.WorldPivot.Position)
            if distance > 0 and distance <= 45 then
                distanceCheck = true
                break
            end
        end
        if not distanceCheck then
            Events.CreateNotify.Fire(plr, "You are too far from the Market!")
            return
        end


        --// cant sell items obtained from chests / nil
        local foundInChest = false
        for _, chest in CollectionService:GetTagged("ChestEntity") do
            if chest.Name == itemInfo.ItemId then
                foundInChest = true
                break
            end
        end
        if foundInChest then
            Events.CreateNotify.Fire(plr, "You cannot sell items obtained from Overworld Chests!")
            return
        end

        --// found in statue
        if itemInfo.TagsDesync.Statue then
            if item == "Crescendo" then
                local amount = 0
                local plr = plr
                local items = plr.Items :: Folder

                for _, itemSymbol in items:GetChildren() do
                    if itemSymbol.Name == "Crescendo" then
                        amount += 1
                    end
                end
                if amount == 1 then
                    Events.CreateNotify.Fire(plr, "You can't sell your weapons obtained from Statues!")
                    return
                end
            else
                Events.CreateNotify.Fire(plr, "You can't sell your weapons obtained from Statues!")
                return
            end
        end


        --// cant sell items that is not existed
        local plr = plr
        local items = plr.Items :: Folder
        local itemSymbol = items:FindFirstChild(item) :: IntConstrainedValue
        if itemSymbol == nil then return end


        local itemsWithThisId = {}
        for _, symbol: IntConstrainedValue in items:GetChildren() do
            if symbol.Name == item and symbol:GetAttribute("IsLocked") == false then
                table.insert(itemsWithThisId, symbol)
            end
        end
        if #itemsWithThisId <= 0 then return end


        local hasEquipping, equipUniqueId = false, nil
        for _, symbol: StringValue in plr.EquippingItems:GetChildren() do
            if symbol.Value == item then
                hasEquipping = true
                equipUniqueId = symbol:GetAttribute("HarukaUniqueId")
                break
            end
        end

        if hasEquipping then
            local eIndex = 0
            for index: number, symbol: StringValue in itemsWithThisId do
                if symbol:GetAttribute("HarukaUniqueId") == equipUniqueId then
                    eIndex = index
                    break
                end
            end
            table.remove(itemsWithThisId, eIndex)
        else
            local eIndex = math.random(1, #itemsWithThisId)
            table.remove(itemsWithThisId, eIndex)
        end
        if #itemsWithThisId <= 0 then return end


        local totalGold = 0
        for _, symbol: IntConstrainedValue in itemsWithThisId do
            totalGold += itemInfo.SellPrice * symbol.Value
            symbol:Destroy()
        end

        Events.PlaySound.Fire(plr, SoundService.SFXs.Buy)
        Events.CreateNotify.Fire(plr, "Sell successful! Welcome back!")

        HarukaLib:AddAttr(plr, "Gold", totalGold)
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToAddPoint.SetCallback(function(plr: Player, data)
        if data.PointId == nil then return end
        if data.PointAmount == nil then return end

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't change your skill points in combat!")
            return
        end

        local pointAdd = data.PointAmount :: number
        local availablePoint = plr:GetAttribute("PerkPoints") :: number

        if pointAdd == 0 then return end

        if pointAdd > 0 then
            if availablePoint < pointAdd then
                pointAdd = availablePoint
            end

            if data.PointId == "DEX" then
                local dexPoints = plr:GetAttribute("DEXPoints") :: number

                if dexPoints >= FormulaBook.PLAYER_MAX_DEX_POINTS then
                    plr:SetAttribute("DEXPoints", FormulaBook.PLAYER_MAX_DEX_POINTS)

                    Events.CreateNotify.Fire(plr, "DEX points have reached their limit!")
                    return
                end
            end

            HarukaLib:AddAttr(plr, "PerkPoints", -pointAdd)
            HarukaLib:AddAttr(plr, data.PointId.."Points", pointAdd)


            if data.PointId == "DEX" then
                local dexPoints = plr:GetAttribute("DEXPoints") :: number

                if dexPoints >= FormulaBook.PLAYER_MAX_DEX_POINTS then
                    local maxOut = plr:GetAttribute("DEXPoints") - FormulaBook.PLAYER_MAX_DEX_POINTS
                    HarukaLib:AddAttr(plr, "PerkPoints", maxOut)

                    plr:SetAttribute("DEXPoints", FormulaBook.PLAYER_MAX_DEX_POINTS)

                    Events.CreateNotify.Fire(plr, "DEX points have reached their limit!")
                end
            end

        elseif pointAdd < 0 then
            local thatPoints = plr:GetAttribute(data.PointId.."Points") :: number

            if thatPoints <= 0 then return end

            local pointHave = plr:GetAttribute(data.PointId.."Points") :: number
            if pointAdd < -pointHave then
                pointAdd = -pointHave
            end

            HarukaLib:AddAttr(plr, "PerkPoints", -pointAdd)
            HarukaLib:AddAttr(plr, data.PointId.."Points", pointAdd)
        end
    end)
    Events.RequestToResetPoint.SetCallback(function(plr: Player)
        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't change your skill points in combat!")
            return
        end

        local level = plr:GetAttribute("Level") :: number
        if not level then return end

        plr:SetAttribute("PerkPoints", FormulaBook.PLAYER_POINT_PER_LEVEL * level)
        plr:SetAttribute("STRPoints", 0)
        plr:SetAttribute("DEXPoints", 0)
        plr:SetAttribute("INTPoints", 0)
        plr:SetAttribute("VITPoints", 0)
        plr:SetAttribute("DEFPoints", 0)
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToDMGEnemyBySkillProjectile.SetCallback(function(plr: Player, data)
        local projectileId = data.ProjectileUniqueId
        if projectileId == nil then return end
        if data.EnemyEntity == nil then return end

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end
        if not ServerLib.IsCharValid(data.EnemyEntity) then return end

        local projectileList = ServerStorage.SkillProjectileContainer:FindFirstChild("SkillProjectiles_"..char:GetAttribute("HarukaUniqueId")) :: Folder?

        if not projectileList then return end
        if not projectileList:FindFirstChild(projectileId) then return end

        local symbol = projectileList:FindFirstChild(projectileId) :: StringValue
        local style = symbol:GetAttribute("DMGType") :: string

        if symbol:GetAttribute("Owner") ~= char.Name then return end


        local projectileType = symbol:GetAttribute("ProjectileType") :: string
        local projectileDoTType = symbol:GetAttribute("DoTType") :: string
        local isClassUlt = symbol:GetAttribute("IsClassUlt") :: boolean
        local enemyUniqueId = data.EnemyEntity:GetAttribute("HarukaUniqueId") :: string
        if symbol:FindFirstChild(enemyUniqueId) then return end

        local enemySymbol = Instance.new("BoolValue")
        enemySymbol.Name = enemyUniqueId
        enemySymbol.Value = true
        enemySymbol.Parent = symbol

        if projectileType == "OneTime" then
        elseif projectileType == "OverTime" then
            Debris:AddItem(enemySymbol, 1.599)
        end


        local trueDMGStyle = "Physical"
        if style == "Magic" then
            trueDMGStyle = "Magic"
        end

        local trueDMGBonus = symbol:GetAttribute("DMGBonus") or 1
        local attacker = "SkillProjectile"
        if isClassUlt then
            attacker = "ClassUltProjectile"
        end


        ClassAttackLib._DealDamageToEnemy(char, data.EnemyEntity, {
            DMG = math.ceil(ClassAttackLib._CalDMG(style, char, {
                ForceMaxDMG = true
            }) * trueDMGBonus),
            Attacker = attacker,
            DMGType = trueDMGStyle
        })
        if projectileDoTType ~= "None" then
            local debuffObj = DoTLib.new({
                Target = data.EnemyEntity,
                Type = projectileDoTType,
                Duration = 5,
                Creator = char,
                Power = 1,
            })
            debuffObj:Activate()
        end
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToCraftItem.SetCallback(function(plr: Player, data)
        local item, itemUniqueId = data.ItemId, data.ItemUniqueId
        if item == nil then return end
        if itemUniqueId == nil then return end

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't craft items in combat!")
            return
        end

        local itemInfo = ItemBook:GetItemInfo(item)
        if not itemInfo then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Item Id")
            return
        end
        if HarukaLib.TableUtils.IsEmpty(itemInfo.RecipeDesync) then
            Events.CreateNotify.Fire(plr, "This item cannot be crafted!")
            return
        end


        local gold = plr:GetAttribute("Gold") :: number
        if gold < itemInfo.Price then
            Events.CreateNotify.Fire(plr, "You don't have enough Gold to craft this item!")
            return
        end


        local distanceCheck = false
        for _, adornee: BasePart in CollectionService:GetTagged("CraftingPromptEntity") do
            if plr:DistanceFromCharacter(adornee.Position) <= 25 then
                distanceCheck = true
                break
            end
        end
        if not distanceCheck then
            Events.CreateNotify.Fire(plr, "You are too far from the Crafting Station!")
            return
        end


        local materialCheck = true
        local plr = plr
        for material: string, amount: number in itemInfo.RecipeDesync do
            local items = plr.Items :: Folder
            local itemSymbol = items:FindFirstChild(material) :: IntConstrainedValue
            local materialInfo = ItemBook:GetItemInfo(material)

            if not materialInfo then
                materialCheck = false
                Events.CreateNotify.Fire(plr, "Invalid material id, please contact the developer!")
                break
            end
            if not itemSymbol then
                materialCheck = false
                break
            end
            if itemSymbol.Value < amount then
                materialCheck = false
                break
            end

            local isEquipping = false
            for _, symbol: StringValue in plr.EquippingItems:GetChildren() do
                if symbol.Value == material then
                    isEquipping = true
                    materialCheck = false
                    break
                end
            end
            if isEquipping then
                materialCheck = false

                Events.CreateNotify.Fire(plr, "You can't craft this item while you have equipped one of the materials!")
                break
            end

            if materialInfo.Type == "Passive" then
                materialCheck = false
                Events.CreateNotify.Fire(plr, "Invalid item recipe, please contact the developer!")
                break
            end
            if materialInfo.Type == "Accessory" then
                materialCheck = false
                Events.CreateNotify.Fire(plr, "Invalid item recipe, please contact the developer!")
                break
            end
            if materialInfo.Type == "Quest" then
                materialCheck = false
                Events.CreateNotify.Fire(plr, "Invalid item recipe, please contact the developer!")
                break
            end
        end
        if not materialCheck then
            Events.CreateNotify.Fire(plr, "You don't have enough materials to craft this item!")
            return
        end


        for material: string, amount: number in itemInfo.RecipeDesync do
            local symbol = plr.Items:FindFirstChild(material) :: IntConstrainedValue

            symbol.Value -= amount

            if symbol.Value <= 0 then
                symbol:Destroy()
            end
        end
        HarukaLib:AddAttr(plr, "Gold", -itemInfo.Price)


        Events.PlaySound.Fire(plr, SoundService.SFXs.AnvilUse)
        Events.CreateNotify.Fire(plr, "Craft successful! Welcome back!")


        ServerLib.GiveItemDrop(plr, item, 1)
    end)
end)



table.insert(GlobalCriRPGLib.Funcs, function()
    local function partyInvite(plr: Player, option: string, newMember: string)
        if option == "Invite" then
            --- check character exists
            local char = workspace.EntitiesPlayerChar:FindFirstChild(newMember) :: Model?
            if not char then Events.CreateNotify.Fire(plr, "Failed to invite!") return end

            --- check valid player
            local player = Players:GetPlayerFromCharacter(char)
            if not player then Events.CreateNotify.Fire(plr, "Failed to invite!") return end

            --- check if player already have a party
            local pass = true
            for _, child in workspace.MapComponents.PartyHolder:GetDescendants() do
                if child:IsA("ObjectValue") and child.Name == player.Name then
                    pass = false
                elseif child:IsA("ObjectValue") and child.Name == plr.Name then
                    if child.Parent.Name ~= plr.Name then pass = false end
                end
            end
            if not pass then Events.CreateNotify.Fire(plr, "Player already has a party!") return end

            --- check if player is in a request
            local foundTicket = false
            for _, child in char:GetChildren() do
                if child.Name == "PartyInviteTicket" and child.Value == plr.Character then foundTicket = true break end
            end
            if foundTicket then Events.CreateNotify.Fire(plr, "Player already has an invitation!") return end

            local ticket = Instance.new("ObjectValue")
            ticket.Name = "PartyInviteTicket"
            ticket.Value = plr.Character
            ticket.Parent = char

            Events.PartyInviteResult.Fire(player, { Option = "Invite", PlayerName = plr.Name })
            Events.PlaySound.Fire(player, SoundService.SFXs.ChestDrop)

        elseif option == "InviteAccept" or option == "InviteDecline" then
            --- check if player is already in a party
            local pass = true
            for _, child: Instance in workspace.MapComponents.PartyHolder:GetDescendants() do
                if child:IsA("ObjectValue") and child.Name == plr.Name then pass = false break end
            end
            if not pass then Events.CreateNotify.Fire(plr, "You are already in a party!") return end

            --- check valid player
            local char = plr.Character
            if not char then Events.CreateNotify.Fire(plr, "Failed to do so!") return end

            local inviterChar = workspace.EntitiesPlayerChar:FindFirstChild(newMember) :: Model?
            if not inviterChar then Events.CreateNotify.Fire(plr, "Failed to join/leave the party!") return end

            --- check valid player
            local player = Players:GetPlayerFromCharacter(char)
            if not player then return end

            local inviter = Players:GetPlayerFromCharacter(inviterChar)
            if not inviter then Events.CreateNotify.Fire(plr, "Failed to join/leave the party!") return end

            --- get ticket
            local ticket: ObjectValue? = nil
            for _, child in char:GetChildren() do
                if child.Name == "PartyInviteTicket" and child.Value == inviterChar then ticket = child break end
            end
            if ticket == nil then Events.CreateNotify.Fire(plr, "Failed to join/leave the party!") return end

            --- join party
            if option == "InviteAccept" then
                if not workspace.MapComponents.PartyHolder:FindFirstChild(inviter.Name) then
                    local partyFolder = Instance.new("Folder")
                    partyFolder.Name = inviter.Name
                    partyFolder.Parent = workspace.MapComponents.PartyHolder

                    local leaderSymbol = Instance.new("ObjectValue")
                    leaderSymbol.Name = inviter.Name
                    leaderSymbol.Value = inviterChar
                    leaderSymbol.Parent = partyFolder

                    local memberSymbol = Instance.new("ObjectValue")
                    memberSymbol.Name = plr.Name
                    memberSymbol.Value = char
                    memberSymbol.Parent = partyFolder

                    plr:SetAttribute("IsInParty", true)
                    inviter:SetAttribute("IsInParty", true)

                    ticket:Destroy()

                elseif workspace.MapComponents.PartyHolder:FindFirstChild(inviter.Name) then
                    local count = 0
                    for _, symbol: ObjectValue in workspace.MapComponents.PartyHolder[inviter.Name]:GetChildren() do
                        if symbol:IsA("ObjectValue") then count += 1 end
                    end
                    if count >= 6 then
                        Events.CreateNotify.Fire(plr, "Party is full!")
                        Events.CreateNotify.Fire(inviter, "Party is full!")

                        ticket:Destroy()
                        return
                    end

                    local memberSymbol = Instance.new("ObjectValue")
                    memberSymbol.Name = plr.Name
                    memberSymbol.Value = char
                    memberSymbol.Parent = workspace.MapComponents.PartyHolder[inviter.Name]

                    plr:SetAttribute("IsInParty", true)

                    ticket:Destroy()
                end
            elseif option == "InviteDecline" then
                ticket:Destroy()

                Events.CreateNotify.Fire(inviter, plr.DisplayName.." declined your invitation!")
            end

        elseif option == "PartyKick" then
            if not workspace.MapComponents.PartyHolder:FindFirstChild(plr.Name) then
                Events.CreateNotify.Fire(plr, "You are not a leader!")
                return
            end
            if not workspace.MapComponents.PartyHolder[plr.Name]:FindFirstChild(newMember) then
                Events.CreateNotify.Fire(plr, "Player is not in your party!")
                return
            end

            workspace.MapComponents.PartyHolder[plr.Name][newMember]:Destroy()

            if not Players[newMember] then return end
            Players[newMember]:SetAttribute("IsInParty", false)

        elseif option == "PartyLeave" then
            local function _disbandPartyAction(partyFolder: Folder)
                for _, symbol in partyFolder:GetChildren() do
                    if symbol:IsA("ObjectValue") and symbol.Value then
                        local memeber = Players:GetPlayerFromCharacter(symbol.Value)
                        if not memeber then continue end

                        memeber:SetAttribute("IsInParty", false)

                        Events.CreateNotify.Fire(memeber, "Party has been disbanded!")
                    end
                end
            end

            local partyFolder: Folder? = nil
            for _, child in workspace.MapComponents.PartyHolder:GetDescendants() do
                if child:IsA("ObjectValue") and child.Name == plr.Name then
                    partyFolder = child.Parent
                    child:Destroy()

                    local thatPartyFolder = partyFolder :: Folder

                    plr:SetAttribute("IsInParty", false)
                    for _, symbol in thatPartyFolder:GetChildren() do
                        if symbol:IsA("ObjectValue") and symbol.Value then
                            local memeber = Players:GetPlayerFromCharacter(symbol.Value)
                            if not memeber then continue end

                            Events.CreateNotify.Fire(memeber, `{plr.DisplayName} has left the party!`)
                        end
                    end

                    if thatPartyFolder.Name == plr.Name then
                        _disbandPartyAction(thatPartyFolder)

                        thatPartyFolder:Destroy()
                    end
                    break
                end
            end
            if not partyFolder then return end

            local count = 0
            for _, symbol in partyFolder:GetChildren() do
                if symbol:IsA("ObjectValue") then count += 1 end
            end
            if count <= 0 then
                _disbandPartyAction(partyFolder)

                partyFolder:Destroy()
            end
        end
    end
    Events.RequestToPartyInvite.SetCallback(function(plr: Player, data)
        local option, newMember = data.Option, data.PlayerName

        partyInvite(plr, option, newMember)
    end)
    ServerBindables.PartyInvite:Connect(partyInvite)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    local function _challengeAbyss(plr: Player, data: {
        AbyssId: number?
    })
        if not data.AbyssId then return end


        local abyssSortedMap = MemoryStoreService:GetSortedMap("AbyssTeleportData")
        pcall(function()
            abyssSortedMap:SetAsync("AbyssChallenge_"..plr.UserId, data.AbyssId, 60 * 5)
        end)

        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions:SetTeleportData({
            ToAbyss = true,
            SlotId = plr:GetAttribute("SlotChosen")
        })

        local code = TeleportService:ReserveServer(AssetBook.PlaceIds[tostring(game.GameId)].AbyssLevel)
        teleportOptions.ReservedServerAccessCode = code

        TeleportService:TeleportAsync(AssetBook.PlaceIds[tostring(game.GameId)].AbyssLevel, { plr }, teleportOptions)


        Events.CreateFSNotify.Fire(plr, "Teleporting to Abyss...", 15)
    end
    Events.RequestToChallengeAbyss.SetCallback(_challengeAbyss)
    ServerBindables.RToChallengeAbyss:Connect(_challengeAbyss)
end)



table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToSetSkyGalleonPos.SetCallback(function(plr: Player, data)
        if not data.Galleon then return end
        if not data.Position then return end
        if not data.Rotation then return end


        local galleon, pos, rotation = data.Galleon, data.Position, data.Rotation
        if not galleon:FindFirstChild("Owner") then return end
        if galleon.Owner.Value ~= plr then return end
        if not ServerLib.IsModelValid(galleon) then return end
        if not galleon.PrimaryPart:FindFirstChild("AlignPosition") then return end

        if not galleon.PrimaryPart.Position:FuzzyEq(pos) then
            galleon.PrimaryPart.AlignPosition.Position = pos
        end

        local targetDirection = galleon.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(rotation), 0)
        local targetPoint = galleon.PrimaryPart.Position + targetDirection.LookVector.Unit * 159

        galleon.Humanoid:MoveTo(targetPoint)
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToSaveSettings.SetCallback(function(plr: Player, data)
        if data.SettingId == nil then return end
        if data.SettingValue == nil then return end

        local id, val = data.SettingId, data.SettingValue
        if id == "HideUI" then return end

        local plr = plr
        local criSettings = plr.CriRPGSettings :: Configuration

        local valueSymbol = criSettings:FindFirstChild(id)
        if not valueSymbol then
            if type(val) == "number" then
                valueSymbol = Instance.new("NumberValue")
            elseif type(val) == "boolean" then
                valueSymbol = Instance.new("BoolValue")
            elseif type(val) == "string" then
                valueSymbol = Instance.new("StringValue")
            end

            valueSymbol.Name = id
            valueSymbol.Value = val
            valueSymbol.Parent = criSettings
        end

        valueSymbol.Value = val
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToPlayTutorial.SetCallback(function(plr: Player)
        local teleportOptions = Instance.new("TeleportOptions")

        local code = TeleportService:ReserveServer(AssetBook.PlaceIds[tostring(game.GameId)].Tutorial)
        teleportOptions.ReservedServerAccessCode = code

        TeleportService:TeleportAsync(AssetBook.PlaceIds[tostring(game.GameId)].Tutorial, { plr }, teleportOptions)
    end)
end)


table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToFavItem.SetCallback(function(plr: Player, data)
        if not data.ItemSymbol then return end

        local symbol = data.ItemSymbol :: IntConstrainedValue
        if not symbol:IsDescendantOf(plr) then return end

        local state = symbol:GetAttribute("IsFav")
        state = state or false
        state = not state

        symbol:SetAttribute("IsFav", state)
    end)

    Events.RequestToLockItem.SetCallback(function(plr: Player, data)
        if not data.ItemSymbol then return end

        local symbol = data.ItemSymbol :: IntConstrainedValue
        if not symbol:IsDescendantOf(plr) then return end

        local state = symbol:GetAttribute("IsLocked")
        state = state or false
        state = not state

        symbol:SetAttribute("IsLocked", state)
    end)
end)



table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToEnterClimbingState.SetCallback(function(plr: Player, data)
        if not data.State then return end

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        char:SetAttribute("IsClimbing", data.State)
    end)
    Events.RequestToEnterSwimmingState.SetCallback(function(plr: Player, data)
        if not data.State then return end

        local char = plr.Character
        if not ServerLib.IsCharValid(char) then return end

        char:SetAttribute("IsSwimming", data.State)
    end)
end)



table.insert(GlobalCriRPGLib.Funcs, function()
    Events.RequestToPurchaseTicket.SetCallback(function(plr: Player, data)
        if not data.MerchantId then return end

        local merchant = workspace.MapComponents.TravelTickets:FindFirstChild(data.MerchantId)
        if not merchant then return end

        local goldAmount = plr:GetAttribute("Gold")
        if goldAmount < 599 then
            Events.CreateNotify.Fire(plr, "You don't have enough gold to purchase a ticket!")
            return
        end

        HarukaLib:AddAttr(plr, "Gold", -599)

        Events.CreateNotify.Fire(plr, "Have a safe journey!")
        Events.CreateCircularFade.Fire(plr, 2)
        Events.PlaySound.Fire(plr, SoundService.SFXs.Buy)

        wait(1)
        local char = plr.Character :: Model
        if not ServerLib.IsCharValid(char) then return end


        char:PivotTo(merchant.Destination.Value.CFrame)
    end)
end)



return GlobalCriRPGLib