
local BadgeService = game:GetService("BadgeService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")

local AssetBook = require(RepS.HarukaShared.Library.AssetBook)
local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local ClassAttackLib = require(SSS.HarukaServer.Library.ClassAttackLib)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)
local CastItemLib = require(SSS.HarukaServer.Library.CastItemLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemBook = require(RepS.HarukaShared.Library.ItemBook)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local DoTLib = require(SSS.HarukaServer.Services.DoTLib)
local PartyLib = require(SSS.HarukaServer.Services.PartyLib)
local QuestLib = require(SSS.HarukaServer.Services.QuestLib)
local ServerTable = require(SSS.HarukaServer.Library.ServerTable)
local StatusLib = require(SSS.HarukaServer.Library.StatusLib)
local RankBook = require(RepS.HarukaShared.Library.RankBook)

type Dict = { [string]: any }

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
        func()
    end
end

--// Private Methods

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.ForceResetPlayer_C.SetCallback(function(plr: Player)
        local char = plr.Character

        if not plr.Character then return end

        if char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = -1
        end
    end)

    Events.RejoinGame_C.SetCallback(function(plr: Player)
        local worldId = workspace:GetAttribute("WorldId") :: string

        if worldId and worldId == "InitusWorld" then
            TeleportService:TeleportAsync(game.PlaceId, { plr })
        end
    end)

    -- handle server hop
    Events.ServerHop_C.SetCallback(function(plr: Player, jobId: string?)
        if not jobId then return end

        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions.ServerInstanceId = jobId

        Events.CreateNotify_S.Fire(plr, "Server hopping, please wait...")

        wait(1.5)
        TeleportService:TeleportAsync(game.PlaceId, { plr }, teleportOptions)
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    ServerBindables.RToSpawnChar.Event:Connect(function(plr: Player)
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

        plr:LoadCharacterAsync()

        local r6Char = plr.Character :: Model
        local r6Humanoid = r6Char.Humanoid :: Humanoid

        r6Char.Archivable = true
        r6Char:PivotTo(CFrame.new(Vector3.yAxis * 159))
        r6Char.ModelStreamingMode = Enum.ModelStreamingMode.Persistent

        r6Humanoid.DisplayName = plr.DisplayName
        r6Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        r6Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        r6Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)

        if r6Char:FindFirstChild("Animate") then
            r6Char.Animate:Destroy()
        end
        if r6Char:FindFirstChild("Health") then
            r6Char.Health:Destroy()
        end
        r6Char.PrimaryPart = r6Humanoid.RootPart

        r6Char:SetAttribute("HarukaUniqueId", HttpService:GenerateGUID(false))

        local cfRootNodeAtt = Instance.new("Attachment")
        cfRootNodeAtt.Name = "CF_RootNode"
        cfRootNodeAtt.Parent = r6Char.PrimaryPart

        HarukaLib:SetCollisionGroup(r6Char, "PlayerBodyPart")

        --// clear collision box
        for _, part: BasePart in r6Char:GetChildren() do
            if not HarukaLib:IsBasePartType(part) then continue end
            if part == r6Char.PrimaryPart then continue end

            part.EnableFluidForces = false
            part.CanCollide = false
        end

        r6Char:SetAttribute("SpawnClock", DateTime.now().UnixTimestamp)
        r6Char.Parent = workspace.EntitiesPlayerChar
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    local function _sitGalleon(galleon: Model, plr: Player)
        local seat = galleon:FindFirstChildOfClass("Seat")
        if not seat then return end

        galleon.PrimaryPart.Anchored = false
        galleon.PrimaryPart.AssemblyLinearVelocity = Vector3.zero

        seat:Sit(plr.Character.Humanoid)
        seat:GetPropertyChangedSignal("Occupant"):Connect(function()
            local occupant = seat.Occupant
            if occupant == nil then
                if not ServerLib:IsModelValid(galleon) then return end

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
    end

    Events.PromptTriggered_C.On(function(plr: Player, prompt: ProximityPrompt)
        if prompt == nil then return end
        if prompt.Parent == nil then return end
        if prompt.Enabled == false then return end

        local adornee = prompt.Parent :: BasePart
        local char = plr.Character

        if plr == nil then return end
        if not adornee:IsA("BasePart") then
            warn("Invalid adornee for proximity prompt")
            return
        end

        if not ServerLib:IsCharValid(char) then return end

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

            if not ServerLib:IsCharValid(char) then return end
            if char:GetAttribute("IsInCombat") then
                Events.CreateNotify_S.Fire(plr, "Can't talk to NPCs in combat")
                return
            end
            if char:GetAttribute("IsChatting") then
                Events.CreateNotify_S.Fire(plr, "Already in a conversation")
                return
            end

            char:SetAttribute("IsChatting", true)

            Events.EnterNPCChat_S.Fire(plr, npc)

        elseif prompt.Name == "Chest" then
            local chest = prompt:FindFirstAncestorOfClass("Model")

            if not ItemBook:GetItemInfo(chest.Name) then return end
            if chest:GetAttribute("Receiver_"..plr.Name) then
                Events.CreateNotify_S.Fire(plr, "Already opened")
                return
            end

            chest:SetAttribute("Receiver_"..plr.Name, true)

            Events.OpeningChest_S.Fire(plr, chest)

            ServerLib:GiveItemDrop(plr, chest.Name, chest:GetAttribute("Amount") or 1)

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

            local currencyId = "Gold"
            if adornee:GetAttribute("CurrencyId") then
                currencyId = adornee:GetAttribute("CurrencyId")
            end

            Events.OpenMarketUI_S.Fire(plr, {
                Products = products,
                CurrencyId = currencyId
            })

        elseif prompt.Name == "Crafting" then
            adornee:AddTag("CraftingPromptEntity")

            Events.OpenCraftingUI_S.Fire(plr)

        elseif prompt.Name == "AbyssView" then
            Events.OpenAbyssUI_S.Fire(plr)

        elseif prompt.Name == "Portal" then
            char:PivotTo(prompt.Destination.Value.CFrame)
            Events.RefreshCullingAsync_S.Fire(plr)

        elseif prompt.Name == "Class" then
            local statue = prompt:FindFirstAncestorOfClass("Model")

            local items = plr.Items :: Folder
            if not items:FindFirstChild(statue.Weapon.Value) then
                ServerLib:GiveItemDrop(plr, statue.Weapon.Value, 1)
            else
                Events.CreateNotify_S.Fire(plr, "Already blessed")
            end

        elseif prompt.Name == "PurchaseTicket" then
            local merchantId = adornee.Name
            local price = adornee:GetAttribute("Price") :: number

            Events.OpenTravelTicketUI_S.Fire(plr, {
                MerchantId = merchantId,
                Price = price
            })

        elseif prompt.Name == "Material" then
            local material = prompt:FindFirstAncestorOfClass("Model")
            local itemInfo = ItemBook:GetItemInfo(material.Name)

            if itemInfo == nil then return end
            if not prompt:IsDescendantOf(workspace) then return end
            if not ServerLib:IsCharValid(char) then return end

            if material:GetAttribute("Profession") then
                if not char:GetAttribute(material:GetAttribute("Profession")) then
                    Events.CreateNotify_S.Fire(plr, "Tool required")
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

            ServerLib:GiveItemDrop(plr, finalMaterial, amount)

            Promise.delay(math.random(60, 100)):andThen(function()
                material.Parent = workspace.MapComponents.Materials

                prompt.Enabled = true
            end)

        elseif prompt.Name == "BoatSummon" then
            for _, galleon: Model in CollectionService:GetTagged("SkyDriveGalleon") do
                if not galleon:FindFirstChild("Owner") then galleon:Destroy() continue end

                if galleon.Owner.Value == plr then
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
            galleon.Parent = workspace.MapComponents.SkyGalleonsContainer

            Promise.new(function()
                while galleon and galleon.Parent do
                    wait(30)
                    if galleon.Seat.Occupant == nil then
                        galleon:Destroy()
                        break
                    end
                end
            end):catch(function() end)

            _sitGalleon(galleon, plr)

        elseif prompt.Name == "BoatEnter" then
            local galleon = prompt:FindFirstAncestorOfClass("Model")
            if not galleon then return end

            _sitGalleon(galleon, plr)
        end
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.DMGPlayer_C.SetCallback(function(plr: Player, data)
        if data.ProjectileUniqueId == nil then return end
        if data.IsPierce == nil then return end
        if data.DoTStatus == nil then return end

        local projectileUniqueId = data.ProjectileUniqueId
        local projectileData = ServerTable.EnemyProjectileSymbols[projectileUniqueId]

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end
        if not projectileData then return end
        if not char:GetAttribute("IsInCombat") then return end

        local projectileDMG = projectileData.ProjectileDMG
        local owner = projectileData.Owner
        if not ServerLib:IsCharValid(owner) then return end

        if char:FindFirstChild("IFrameSymbol") then return end

        Promise.new(function(resolve)
            local dodgeChance = char:GetAttribute("DodgeChance") or 0 :: number
            local result = HarukaLib:RollLoot({
                Dodge = dodgeChance,
                None = 100 - dodgeChance
            })
            if result == "Dodge" then
                projectileDMG = 0

                ServerLib:ShowText(char, "DODGE!", Color3.fromHex('#ffffff'))
            end
            resolve()

        end):catch(function() end):await()

        if projectileDMG <= 0 then return end

        ServerLib:ShowNumber(char, projectileDMG, Color3.fromRGB(255, 0, 0))
        ServerLib:ApplyHitStatus(char)

        if char:GetAttribute("Shield") > 0 and not data.IsPierce then
            local afterShield = math.ceil(char:GetAttribute("Shield") - projectileDMG)

            afterShield = math.clamp(afterShield, 0, 1599 * 40 * 40)

            char:SetAttribute("Shield", afterShield)
            char.PlayerGotHit:Fire(char.Name, projectileDMG, "Shield")

            Events.PlaySound_S.Fire(plr, SoundService.SFXs.ShieldAbsorb)

            if afterShield <= 0 then
                Events.PlaySound_S.Fire(plr, SoundService.SFXs.ShieldBroken)

                local exceededDMG = projectileDMG
                if exceededDMG > 0 then
                    exceededDMG = math.ceil(exceededDMG / 1.599)
                    char.Humanoid:TakeDamage(exceededDMG)

                    Events.PlayGotHitScreenFX_S.Fire(plr)

                    char.PlayerGotHit:Fire(char.Name, exceededDMG, "Health")
                end
            end
        else
            if data.IsPierce then
                ServerLib:ShowText(char, "PIERCE!", Color3.fromRGB(255, 255, 255))
            end

            char.Humanoid:TakeDamage(projectileDMG)
            char.PlayerGotHit:Fire(char.Name, projectileDMG, "Health")

            Events.PlayGotHitScreenFX_S.Fire(plr)
        end

        if data.DoTStatus or projectileData.DoTStatus then
            local DoTStatus = projectileData.DoTStatus or data.DoTStatus
            if DoTStatus == nil then return end
            if DoTStatus == "Normal" then return end

            local dotList = DoTLib:GetEffectsByTarget(char, DoTStatus)
            if #dotList > 1 then return end

            local warding = char:GetAttribute("Warding") or 0
            if warding > 0 then
                local isImmune = HarukaLib:RollLoot({
                    ["Immune"] = warding,
                    ["None"] = 100 - warding
                })
                if isImmune == "Immune" then
                    ServerLib:ShowText(char, "IMMUNE!")
                    return
                end
            end

            local DoTObj = DoTLib.new({
                Target = char,
                Type = DoTStatus,
                Creator = owner,
                Power = 0.5,
                Duration = 3
            })
            DoTObj:Activate()
        end
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.DMGEnemy_C.SetCallback(function(plr: Player, orbUniqueId)
        if orbUniqueId == nil then return end

        local char = plr.Character
        local charUniqueId = char:GetAttribute("HarukaUniqueId") :: string
        if not ServerLib:IsCharValid(char) then return end

        if not ServerTable.OrbSymbols[charUniqueId][orbUniqueId] then return end

        local orbData = ServerTable.OrbSymbols[charUniqueId][orbUniqueId]
        if orbData.Owner ~= char.Name then return end

        local thatOrbStyle = orbData.OrbStyle
        local thatOrbSubStyle = orbData.OrbSubStyle
        local thatOrbUniStyle = orbData.OrbUniStyle
        local orbLocation = orbData.OrbLocation

        local check = true

        Promise.new(function(resolve, reject)
            local nowTime = DateTime.now().UnixTimestampMillis
            local orbTime = orbData.CreatedTimeMS
            if nowTime - orbTime <= 200 then
                reject("Timestamp")
            end

            local DISTANCE = 28
            local distance1 = plr:DistanceFromCharacter(orbLocation.Position)
            local distance2 = plr:DistanceFromCharacter(orbLocation.Position + Vector3.yAxis * DISTANCE)
            local distance3 = plr:DistanceFromCharacter(orbLocation.Position - Vector3.yAxis * DISTANCE)
            local networkPing = plr:GetNetworkPing() * 2
            local walkSpeed = char.Humanoid.WalkSpeed :: number
            local maxAllowedDist = DISTANCE + (walkSpeed * networkPing) + 5
            local minDistance = math.min(distance1, distance2, distance3)

            if distance1 <= 0 or distance2 <= 0 or distance3 <= 0 then reject("Distance") end
            if minDistance > maxAllowedDist then reject("Distance") end

            local class = plr:GetAttribute("Class") :: string
            if class ~= thatOrbStyle then reject("ClassId") end

            resolve(true)

        end):catch(function(reason: string)
            check = false

            reason = tostring(reason)
            if reason == "ClassId" then
                warn("Invalid ClassId for orb")

            elseif reason == "Timestamp" then
                warn("[HarukaAC] Timestamp check failed for orb")

            elseif reason == "Distance" then
                warn("[HarukaAC] Distance check failed for orb")
            end
        end):await()
        if not check then return end

        Promise.new(function()
            if thatOrbSubStyle then
                thatOrbStyle ..= "_"..thatOrbSubStyle
            end
            if not ClassAttackLib[thatOrbStyle] then
                warn(`[Error]: ClassAttackLib Func for {thatOrbStyle} not found`)
                return
            end

            ClassAttackLib[thatOrbStyle](plr, orbData)

        end):catch(function(err)
            warn(tostring(err))
        end)
        Promise.new(function()
            if thatOrbUniStyle == "Heal" then
                StatusLib:HealPercentage(char, 10)

            elseif thatOrbUniStyle == "ATK" then
                local class = plr:GetAttribute("Class") or "Chain"
                local dmgType = ClassBook[class].Type

                if dmgType == "DMG" then
                    StatusLib:ATKBoost(char, {
                        DMGPower = 1.5,
                        Duration = 4
                    })

                elseif dmgType == "Magic" then
                    StatusLib:Boost("Magic", char, {
                        Power = 1.5,
                        Duration = 4
                    })
                end
            end
        end):catch(function(err)
            warn(tostring(err))
        end)

        ServerTable.OrbSymbols[charUniqueId][orbUniqueId] = nil
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.CastItem_C_Request.SetCallback(function(plr: Player, slotId)
        if slotId == nil then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        local equippingItems = plr.EquippingItems :: Folder
        local equippingInfo = equippingItems:FindFirstChild(slotId) :: StringValue

        if not equippingInfo then return end

        local itemInfo = ItemBook:GetItemInfo(equippingInfo.Value)
        if not itemInfo then return end

        local items = plr.Items :: Folder
        local itemSymbol = items:FindFirstChild(equippingInfo.Value) :: IntConstrainedValue

        if not itemSymbol then return end

        local amount = items[equippingInfo.Value].Value or 0 :: number
        if amount <= 0 then return end

        local inCDCheck = false
        for _, cdSymbol: StringValue in workspace.MapComponents.ItemCDSymbolContainer:GetChildren() do
            if cdSymbol.Name == plr.Name and cdSymbol.Value == itemInfo.ItemId then
                inCDCheck = true
                break
            end
        end
        if inCDCheck then
            Events.CreateNotify_S.Fire(plr, "Still on cooldown")
            return
        end

        local realCD = tonumber(itemInfo.ExtraStatInfoDesync.CD)
        if not realCD then return end

        if itemInfo.Type == "Consumable" then
            itemSymbol.Value -= 1

            --// item run out
            if itemSymbol.Value <= 0 then
                itemSymbol:Destroy()
                equippingInfo:Destroy()
            end
        end
        if not CastItemLib[itemInfo.ItemId] then
            warn(`Invalid CastItemLib function for: {itemInfo.ItemId}`)
            return
        end

        local badStatus = false
        Promise.try(function()
            local statusCode = CastItemLib[itemInfo.ItemId](plr, char, {
                CostManaFunc = function(char: Model)
                    local manaCost = itemInfo.ExtraStatInfoDesync.Mana or 0
                    if manaCost <= 0 then return true end

                    local curMana = char:GetAttribute("Mana") or 0
                    if curMana < manaCost then
                        Events.CreateNotify_S.Fire(plr, "Not enough Mana")
                        return false
                    end

                    HarukaLib:AddAttr(char, "Mana", -manaCost)
                    return true
                end
            }) :: number?

            if statusCode and statusCode == 0 then
                badStatus = true
            end
        end):catch(function(err)
            warn(tostring(err))
        end)
        if badStatus then
            if RunService:IsStudio() then
                Events.CreateNotify_S.Fire(plr, "[Error] Invalid Function Status Code (Studio DEBUG)")
            end
            return
        end

        local itemCDSymbol = Instance.new("StringValue")
        itemCDSymbol.Value = itemInfo.ItemId
        itemCDSymbol.Name = plr.Name
        itemCDSymbol.Parent = workspace.MapComponents.ItemCDSymbolContainer
        Debris:AddItem(itemCDSymbol, realCD)

        Events.CastItem_S_Response.Fire(plr, {
            SlotId = slotId,
            CooldownTime = realCD
        })
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.PickupItemDrops_C.SetCallback(function(plr: Player, itemUniqueId)
        if itemUniqueId == nil then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        local itemSymbolData = ServerTable.ItemDropSymbols[itemUniqueId]
        if not itemSymbolData then return end

        if itemSymbolData.Receiver ~= plr then return end
        if itemSymbolData.Amount <= 0 then return end

        itemSymbolData.Amount -= 1
        ServerLib:GiveItemDrop(plr, itemSymbolData.ItemId, 1)

        if itemSymbolData.Amount <= 0 then
            ServerTable.ItemDropSymbols[itemUniqueId] = nil
        end
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.CastClassUlt_C.SetCallback(function(plr: Player)
        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end
        if not char:GetAttribute("IsInCombat") then return end

        --// cast Ult if req meets
        local class = plr:GetAttribute("Class") :: string
        if char:GetAttribute("ClassUltProgress") >= char:GetAttribute("MaxClassUltProgress") then
            char:SetAttribute("ClassUltProgress", 0)

            Promise.new(function()
                if not ClassAttackLib[class.."_Ult"] then
                    warn(`ClassAttackLib ult Func for {class} not found`)
                    return
                end
                ClassAttackLib[class.."_Ult"](plr)

            end):catch(function(err)
                warn(tostring(err))
            end)
        end
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.FinishNPCChat_C.SetCallback(function(plr: Player, data)
        if data.NPCModel == nil then return end
        if data.QuestId == nil then return end

        local npcModel: Model? = data.NPCModel
        if not npcModel then return end

        local distance = plr:DistanceFromCharacter(npcModel.PrimaryPart.Position)
        if distance <= 0 or distance > 40 then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        char:SetAttribute("IsChatting", nil)

        local dialogues = npcModel.Dialogues :: Configuration

        --// do signal
        local extra = require(dialogues.Main).Extra
        local bindableId = extra[data.QuestId] :: string?

        if bindableId then
            ServerBindables.NPCChatFinished:Fire(bindableId, plr)
        end

        local quests = npcModel:FindFirstChild("Quests")
        if quests then
            for _, questVal: StringValue in quests:GetChildren() do
                if questVal.Value == "Complete" then
                    QuestLib:CompleteQuest(plr, questVal.Name)
                end
            end
            for _, questVal: BoolValue in quests:GetChildren() do
                if questVal.Value == "Give" then
                    local required = questVal:GetAttributes()
                    local isAllCompleted = true

                    for attr: string, questId: string in required do
                        if not string.find(attr, "Required") then continue end
                        if not plr.Quests:FindFirstChild(questId) then
                            isAllCompleted = false
                            break
                        end
                        if not plr.Quests[questId].Value then
                            isAllCompleted = false
                            break
                        end
                    end
                    if isAllCompleted then
                        QuestLib:GiveQuest(plr, questVal.Name)
                    end
                end
            end
        end
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.EquipItem_C.SetCallback(function(plr: Player, data)
        if data.ItemId == nil then return end
        if data.ItemUniqueId == nil then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify_S.Fire(plr, "Cannot equip in combat")
            return
        end

        local itemInfo = ItemBook:GetItemInfo(data.ItemId)
        if not itemInfo then return end

        local items = plr.Items :: Folder
        local itemSymbol = items:FindFirstChild(data.ItemId) :: IntConstrainedValue

        if itemSymbol == nil then return end

        local amount = itemSymbol.Value or 0 :: number
        if amount <= 0 then return end

        local level = itemInfo.Level
        if level > plr:GetAttribute("Level") then
            Events.CreateNotify_S.Fire(plr, "Level requirement not met")
            return
        end

        local whiteList = { "Accessory", "Active", "Consumable", "Weapon", "Cosmetic", "Title" }
        if not table.find(whiteList, itemInfo.Type) then
            Events.CreateNotify_S.Fire(plr, "Invalid item type")
            return
        end

        if itemInfo.Type == "Title" then
            local title = RankBook.PlayerTitles[itemInfo.ItemId]
            if not title then return end

            plr:SetAttribute("Title", title)

            Events.CreateNotify_S.Fire(plr, "Title equipped")
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
            ServerLib:ChangeWeapon(plr, data.ItemId, data.ItemUniqueId)
            return
        end

        local equipping = plr.EquippingItems :: Folder

        --// whether it's equipped or not
        local equipCheck = true
        for _, symbol: StringValue in equipping:GetChildren() do
            if symbol:GetAttribute("HarukaUniqueId") == data.ItemUniqueId then
                equipCheck = false

                symbol:Destroy()
                ServerLib:UnequipItem(plr, data.ItemUniqueId)

                Events.PlaySound_S.Fire(plr, SoundService.SFXs.EquipItem)
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
            Events.CreateNotify_S.Fire(plr, "Already equipped")
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
                ServerLib:EquipItem(plr, data.ItemUniqueId)

                Events.PlaySound_S.Fire(plr, SoundService.SFXs.EquipItem)
                break
            end
        end
        if not check then
            Events.CreateNotify_S.Fire(plr, "No free equipment slots")
            return
        end
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.BuyItem_C.SetCallback(function(plr: Player, data)
        local product, purchaseAmount = data.ProductId, data.PurchaseAmount
        local currency = data.CurrencyId
        if product == nil then return end
        if data.ProductUniqueId == nil then return end
        if purchaseAmount == nil then return end
        if currency == nil then return end

        if purchaseAmount > 999 then
            Events.CreateNotify_S.Fire(plr, "Purchase limit is 999 at a time")
            return
        end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify_S.Fire(plr, "Cannot purchase during combat")
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
            Events.CreateNotify_S.Fire(plr, "Too far from the market")
            return
        end

        local itemInfo = ItemBook:GetItemInfo(product)
        if not itemInfo then return end

        if table.find(itemInfo.TagsDesync, "EventLimited") and currency == "Gold" then
            Events.CreateNotify_S.Fire(plr, "Cannot be purchased with Gold")
            return
        end

        local totalPrice = itemInfo.Price * purchaseAmount
        local curGold = plr:GetAttribute(currency) :: number

        if curGold < totalPrice then
            Events.CreateNotify_S.Fire(plr, `Not enough {currency}`)
            return
        end

        Events.CreateNotify_S.Fire(plr, "Purchase successful")

        HarukaLib:AddAttr(plr, currency, -totalPrice)
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.Buy)

        ServerLib:GiveItemDrop(plr, product, purchaseAmount)
    end)
    Events.SellItem_C.SetCallback(function(plr: Player, data)
        local item, sellAmount = data.ItemId, data.SellAmount
        if item == nil then return end
        if data.ItemUniqueId == nil then return end
        if sellAmount == nil then return end

        --// cant sell more than 999 items at once
        if sellAmount > 999 then
            Events.CreateNotify_S.Fire(plr, "Can't sell more than 999 at a time")
            return
        end

        --// cant sell items in combat
        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify_S.Fire(plr, "Cannot sell items in combat")
            return
        end

        --// cant sell items obtained from chests / nil
        local itemInfo = ItemBook:GetItemInfo(item)
        if not itemInfo then return end

        local blacklist = { "Passive", "Quest", "Cosmetic", "Title" }
        if table.find(blacklist, itemInfo.Type) then
            Events.CreateNotify_S.Fire(plr, "Cannot sell this item")
            return
        end

        --// found in statue
        if table.find(itemInfo.TagsDesync, "Statue") then
            Events.CreateNotify_S.Fire(plr, "Cannot sell items obtained from Statues")
            return
        end

        --// found in chest
        local foundInChest = false
        for _, chest in CollectionService:GetTagged("ChestEntity") do
            if chest.Name == itemInfo.ItemId then
                foundInChest = true
                break
            end
        end
        if table.find(itemInfo.TagsDesync, "Chest") then
            foundInChest = true
        end
        if foundInChest then
            Events.CreateNotify_S.Fire(plr, "Cannot sell items obtained from Chests")
            return
        end

        --// cant sell items that is not existed

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
            Events.CreateNotify_S.Fire(plr, "Cannot sell equipped item")
            return
        end

        --// cant sell locked item
        if itemSymbol:GetAttribute("IsLocked") then
            Events.CreateNotify_S.Fire(plr, "Cannot sell locked item, unlock it first")
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

        Events.PlaySound_S.Fire(plr, SoundService.SFXs.Buy)
        Events.CreateNotify_S.Fire(plr, "Sell successful!")

        HarukaLib:AddAttr(plr, "Gold", totalPrice)
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.AddStatPoint_C.SetCallback(function(plr: Player, data)
        if data.PointId == nil then return end
        if data.PointAmount == nil then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify_S.Fire(plr, "Cannot adjust points in combat")
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

                    Events.CreateNotify_S.Fire(plr, "DEX is maxed out")
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

                    Events.CreateNotify_S.Fire(plr, "DEX is maxed out")
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
    Events.ResetStatPoint_C.SetCallback(function(plr: Player)
        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify_S.Fire(plr, "Cannot adjust points in combat")
            return
        end

        local level = plr:GetAttribute("Level") :: number
        if not level then return end

        plr:SetAttribute("PerkPoints", FormulaBook.PLAYER_POINT_PER_LEVEL * level)
        plr:SetAttribute("STRPoints", 0)
        plr:SetAttribute("DEXPoints", 0)
        plr:SetAttribute("INTPoints", 0)
        plr:SetAttribute("VITPoints", 0)
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    --// TODO: Revamp the anti-cheat of this part

    Events.DMGEnemyBySkills_C.SetCallback(function(plr: Player, data)
        local projectileId = data.ProjectileUniqueId
        if projectileId == nil then return end
        if data.Entity == nil then return end

        local entity = data.Entity

        local char = plr.Character
        local charUniqueId = char:GetAttribute("HarukaUniqueId") :: string
        if not ServerLib:IsCharValid(char) then return end
        if not ServerLib:IsCharValid(entity) then return end

        local projectileData = ServerTable.SkillProjectileSymbols[charUniqueId][projectileId]
        if not projectileData then return end

        local style = projectileData.DMGType
        if projectileData.Owner ~= char.Name then return end

        local projectileDoTType = projectileData.DoTType
        local isClassUlt = projectileData.IsClassUlt

        local trueDMGStyle = "DMG"
        if style == "Magic" then
            trueDMGStyle = "Magic"
        end

        local trueDMGBonus = projectileData.DMGBonus
        local attacker = "SkillProjectile"
        if isClassUlt then
            attacker = "ClassUltProjectile"
        end

        ClassAttackLib:DealDamageToEnemy(char, entity, {
            DMG = math.ceil(ClassAttackLib:CalDMG(style, char, {
                ForceMaxDMG = true
            }) * trueDMGBonus),
            Attacker = attacker,
            DMGType = trueDMGStyle
        })
        if projectileDoTType ~= "None" then
            local debuffObj = DoTLib.new({
                Target = entity,
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
    Events.CraftItem_C.SetCallback(function(plr: Player, data)
        local item, itemUniqueId = data.ItemId, data.ItemUniqueId
        if item == nil then return end
        if itemUniqueId == nil then return end

        local amount = data.CraftAmount
        if not amount then return end
        if amount <= 0 then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify_S.Fire(plr, "Cannot craft items in combat")
            return
        end

        local itemInfo = ItemBook:GetItemInfo(item)
        if not itemInfo then return end
        if HarukaLib.TableUtils.IsEmpty(itemInfo.RecipeDesync) then return end

        local gold = plr:GetAttribute("Gold") :: number
        if gold < itemInfo.Price * amount then
            Events.CreateNotify_S.Fire(plr, "Not enough Gold")
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
            Events.CreateNotify_S.Fire(plr, "Too far from the crafting station")
            return
        end

        local materialCheck = true

        for material: string, materialAmount: number in itemInfo.RecipeDesync do
            local items = plr.Items :: Folder
            local itemSymbol = items:FindFirstChild(material) :: IntConstrainedValue
            local materialInfo = ItemBook:GetItemInfo(material)

            if not materialInfo then
                materialCheck = false
                break
            end
            if not itemSymbol then
                materialCheck = false
                break
            end
            if itemSymbol.Value < materialAmount * amount then
                materialCheck = false
                break
            end

            local blackList = { "Passive", "Accessory", "Quest" }
            if table.find(blackList, materialInfo.Type) then
                materialCheck = false
                break
            end
        end
        if not materialCheck then
            Events.CreateNotify_S.Fire(plr, "Insufficient materials")
            return
        end

        for material: string, materialAmount: number in itemInfo.RecipeDesync do
            local symbol = plr.Items:FindFirstChild(material) :: IntConstrainedValue
            symbol.Value -= materialAmount * amount

            if symbol.Value <= 0 then
                ServerLib:UnequipItem(plr, symbol:GetAttribute("HarukaUniqueId"))
                symbol:Destroy()
            end
        end
        HarukaLib:AddAttr(plr, "Gold", -itemInfo.Price * amount)

        Events.PlaySound_S.Fire(plr, SoundService.SFXs.AnvilUse)
        Events.CreateNotify_S.Fire(plr, "Craft successful!")

        ServerLib:GiveItemDrop(plr, item, amount)
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    local function partyInvite(plr: Player, option: string, newMember: string)
        local target = Players:FindFirstChild(newMember)
        if not target then return end

        if option == "Invite" then
            PartyLib:Invite(plr, target)

        elseif option == "InviteAccept" then
            --- target is inviter here
            PartyLib:Accept(target, plr)

        elseif option == "InviteDecline" then
            --- target is inviter here
            PartyLib:Decline(target, plr)

        elseif option == "PartyKick" then
            PartyLib:Kick(plr, target)

        elseif option == "PartyLeave" then
            PartyLib:Leave(plr)
        end
    end
    Events.PartyInvite_C.SetCallback(function(plr: Player, data)
        local option, newMember = data.Option, data.PlayerName

        partyInvite(plr, option, newMember)
    end)
    ServerBindables.PartyInvite.Event:Connect(partyInvite)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    local function _challengeAbyss(plr: Player, data: {
        AbyssId: number,
        Modifiers: { string },
        Players: { Player }
    })
        if not data.AbyssId then return end
        if not data.Modifiers then return end
        if not data.Players then return end

        local abyssPlaceId = AssetBook.PlaceIds[tostring(game.GameId)].AbyssLevel
        local code: string, privateServerId: string = TeleportService:ReserveServerAsync(abyssPlaceId)

        local abyssHashMap = MemoryStoreService:GetHashMap("_AbyssTeleportData_V2")
        pcall(function()
            privateServerId = string.sub(privateServerId, 1, 8)

            local jsonData = {
                AbyssId = data.AbyssId,
                Modifiers = data.Modifiers,
            }
            abyssHashMap:SetAsync(privateServerId, jsonData, 600)
        end)

        local slotChosen = {}
        for _, player: Player in data.Players do
            slotChosen[player.Name] = player:GetAttribute("SlotChosen") or "Slot1"
        end
        local teleportOptions = Instance.new("TeleportOptions")
        teleportOptions:SetTeleportData({
            ToAbyss = true,
            SlotChosen = slotChosen
        })
        teleportOptions.ReservedServerAccessCode = code

        TeleportService:TeleportAsync(abyssPlaceId, data.Players, teleportOptions)

        Events.CreateFSNotify_S.FireList(data.Players, "Teleporting to Abyss...", 15)
    end
    Events.StartAbyss_C.SetCallback(function(plr: Player, data)
        local partyObj = PartyLib:GetParty(plr)
        if partyObj == nil then
            data.Players = { plr }
            _challengeAbyss(plr, data)
        else
            if partyObj.Leader ~= plr then
                Events.CreateNotify_S.Fire(plr, "Only the leader can create the room")
                return
            end

            Events.PlaySound_S.FireList(partyObj:GetAllMembers(), SoundService.SFXs.EXP)
            Events.CreateNotify_S.FireList(partyObj:GetAllMembers(), "Leader requested to challenge the Abyss!")
            wait(2)
            Events.CreateNotify_S.FireList(partyObj:GetAllMembers(), "Teleporting in 3 seconds...")
            wait(3)
            data.Players = partyObj:GetAllMembers()
            _challengeAbyss(plr, data)
        end

        QuestLib:CompleteQuest(plr, "AbyssStarting2")
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.SaveSettings_C.SetCallback(function(plr: Player, data)
        if data.SettingId == nil then return end
        if data.SettingValue == nil then return end

        local id, val = data.SettingId, data.SettingValue
        if id == "HideUI" then return end

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
    Events.FavOrLockItem_C.SetCallback(function(plr: Player, data)
        if not data.ActionId then return end
        if not data.ItemSymbol then return end

        local symbol = data.ItemSymbol :: IntConstrainedValue
        if not symbol:IsDescendantOf(plr) then return end

        local state: boolean
        if data.ActionId == "Fav" then
            state = symbol:GetAttribute("IsFav")
        elseif data.ActionId == "Lock" then
            state = symbol:GetAttribute("IsLocked")
        end

        state = state or false
        state = not state

        if data.ActionId == "Fav" then
            symbol:SetAttribute("IsFav", state)
        elseif data.ActionId == "Lock" then
            symbol:SetAttribute("IsLocked", state)
        end
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.SetServerCharAttr_C.SetCallback(function(plr: Player, data)
        if not data.AttrId then return end
        if data.State == nil then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        char:SetAttribute(data.AttrId, data.State)
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.BuyTicket_C.SetCallback(function(plr: Player, merchantId)
        if not merchantId then return end

        local merchant = workspace.MapComponents.TravelTickets:FindFirstChild(merchantId)
        if not merchant then return end

        local goldNeeded = merchant:GetAttribute("Price") :: number

        local goldAmount = plr:GetAttribute("Gold")
        if goldAmount < goldNeeded then
            Events.CreateNotify_S.Fire(plr, "Not enough Gold")
            return
        end

        HarukaLib:AddAttr(plr, "Gold", -goldNeeded)

        Events.CreateCircularFade_S.Fire(plr, 2)
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.Buy)

        wait(1)
        local char = plr.Character :: Model
        if not ServerLib:IsCharValid(char) then return end

        char:PivotTo(merchant.Destination.Value.CFrame)
        Events.RefreshCullingAsync_S.Fire(plr)
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.SwitchTargetEnemy_C.SetCallback(function(plr: Player, target: Model)
        if not target then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        char.TargetingEnemy.Value = target
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    Events.ClaimBadgeReward_C.SetCallback(function(plr: Player)
        local badgeCompletes = plr:GetAttributes()

        local count = 0
        for badgeId, val in badgeCompletes do
            if string.find(badgeId, "BADGE_") and val then
                count += 1
            end
        end
        if count < 6 then return end

        if plr.Items:FindFirstChild("FuriosoFist") then
            Events.CreateNotify_S.Fire(plr, "Reward already claimed")
            return
        end
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.ChestDrop)

        ServerLib:GiveItemDrop(plr, "FuriosoFist", 1)
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    ServerBindables.RToSendMsgToDiscord.Event:Connect(function(msg: string)
        if RunService:IsStudio() then return end

        Promise.try(function()
            local WEBHOOK_URL = "http://rainyleaf.xyz:1599/roblox-message-std"
            local JSONData = {
                message = msg,
                secretKey = "1599mkk40_fallen_forever"
            }
            local JSONBody = HttpService:JSONEncode(JSONData)

            local success, response = pcall(function()
                return HttpService:PostAsync(WEBHOOK_URL, JSONBody, Enum.HttpContentType.ApplicationJson, false)
            end)
            if not success then
                warn("Failed to send message to webhook: "..tostring(response))
            end
        end)
    end)
end)

table.insert(GlobalCriRPGLib.Funcs, function()
    ServerBindables.RToCheckPlayerBadges.Event:Connect(function(player: Player)
        if not player then return end

        pcall(function()
            local allBadges = HarukaLib.TableUtils.Values(AssetBook.BadgeIds)
            local badgesPlayerOwned = BadgeService:CheckUserBadgesAsync(player.UserId, allBadges)

            for _, badgeId: number in badgesPlayerOwned do
                player:SetAttribute("BADGE_"..badgeId, true)
            end
        end)
    end)

    HarukaLib.Clock(60, function()
        for _, player: Player in CollectionService:GetTagged("PlayerEntity") do
            ServerBindables.RToCheckPlayerBadges:Fire(player)
        end
    end)
end)

return GlobalCriRPGLib