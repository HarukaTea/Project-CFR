--!nocheck

local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")
local TeleportService = game:GetService("TeleportService")

local ClassAttackLib = require(SSS.HarukaServer.Library.ClassAttackLib)
local FormulaBook = require(RepS.HarukaShared.Library.FormulaBook)
local CastItemLib = require(SSS.HarukaServer.Library.CastItemLib)
local DialogueBook = require(RepS.HarukaShared.Library.DialogueBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ItemLib = require(RepS.HarukaShared.Library.ItemLib)
local EntityLib = require(SSS.HarukaServer.Services.EntityLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local QuestBindables = require(RepS.HarukaShared.Library.QuestBindables)


local GlobalCriRPGLib = {}

local wait = task.wait


--// Constructor

function GlobalCriRPGLib:Init()
    for funcId: string, func: (self) -> nil in GlobalCriRPGLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            Promise.try(func, self)
        end
    end
end


--// Private Methods


function GlobalCriRPGLib:_ListenDefaultEventsTracker()
    Events.RequestToForceReset.SetCallback(function(plr: Player)
        local char = plr.Character

        if not plr.Character then return end

        if char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = -1
        end
    end)


    Events.RequestToRejoinGame.SetCallback(function(plr: Player)
        TeleportService:Teleport(game.PlaceId, plr)
    end)
end


function GlobalCriRPGLib:_ListenCharSpawnTracker()
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
                r6Char.Humanoid:ApplyDescription(humanoidDesc)

            end):catch(function()

            end)
        end

        r6Char.Archivable = true
        r6Char.Name = plr.Name
        r6Char:PivotTo(CFrame.new(Vector3.yAxis * 159))
        r6Char.Humanoid.DisplayName = plr.DisplayName
        r6Char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        r6Char.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        r6Char.Animate:Destroy()
        r6Char.PrimaryPart = r6Char.Humanoid.RootPart

        r6Char:SetAttribute("HarukaUniqueId", HttpService:GenerateGUID(false))

        local alignMoverAtt = Instance.new("Attachment")
        alignMoverAtt.Name = "AlignMoverAttachment"
        alignMoverAtt.Parent = r6Char.PrimaryPart

        HarukaLib:SetCollisionGroup(r6Char, "PlayerBodyPart")

        plr.Character = r6Char


        local enumState = {
            Enum.HumanoidStateType.StrafingNoPhysics,
            Enum.HumanoidStateType.Swimming,
            Enum.HumanoidStateType.RunningNoPhysics,
        }
        for _, state: Enum.HumanoidStateType in enumState do
            r6Char.Humanoid:SetStateEnabled(state, false)
        end


        --// clear collision box
        for _, part: BasePart in r6Char:GetDescendants() do
            if not HarukaLib:IsBasePartType(part) then continue end
            if part == r6Char.PrimaryPart then continue end

            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.EnableFluidForces = false
            part.Material = Enum.Material.SmoothPlastic
        end


        r6Char:SetAttribute("SpawnClock", DateTime.now().UnixTimestamp)
        r6Char.Parent = workspace.EntitiesPlayerChar


        for _, thatScript: Script in StarterPlayer.StarterCharacterScripts.HarukaChar:GetChildren() do
            thatScript:Clone().Parent = r6Char
        end
    end)
end


function GlobalCriRPGLib:_ListenPromptRequestsTracker()
    ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt, plr: Player)
        local adornee = prompt.Parent :: BasePart

        if not adornee:IsA("BasePart") then
            warn("Invalid adornee for proximity prompt")
            return
        end

        local distance = plr:DistanceFromCharacter(adornee.Position)
        if distance > prompt.MaxActivationDistance + 1.599 or distance < 0 then return end


        if plr:FindFirstChild("PromptTriggerCD") then return end

        local promptCDSymbol = Instance.new("BoolValue")
        promptCDSymbol.Value = true
        promptCDSymbol.Name = "PromptTriggerCD"
        promptCDSymbol.Parent = plr
        Debris:AddItem(promptCDSymbol, 0.3)


        if prompt.Name == "Chat" then
            local npc = prompt:FindFirstAncestorOfClass("Model")
            if not npc then return end

            local char = plr.Character
            if not ServerLib:IsCharValid(char) then return end

            if char:GetAttribute("IsChatting") then
               Events.CreateNotify.Fire(plr, "You are already in a conversation with another NPC!")
               return
            end

            char:SetAttribute("IsChatting", true)

            Events.EnterNPCChat.Fire(plr, {
                NPCId = npc.Name
            })

        elseif prompt.Name == "Chest" then
            local chest = prompt:FindFirstAncestorOfClass("Model")

            if not ItemLib:GetItemInfo(chest.Name) then
                Events.CreateNotify.Fire(plr, "[Error] Invalid Chest")
                return
            end
            if chest:GetAttribute(plr.Name) then
                Events.CreateNotify.Fire(plr, "You have already opened this treasure chest!")
                return
            end

            chest:SetAttribute(plr.Name, true)

            Events.OpenChestClientTween.Fire(plr, {
                Chest = chest
            })

            ServerLib:GiveItemDrop(plr, chest.Name, chest:GetAttribute("Amount") or 1)

        elseif prompt.Name == "Market" then
            local products = {}
            for _, product: Instance in prompt:FindFirstAncestorOfClass("Model").Products:GetChildren() do
                if ItemLib:GetItemInfo(product.Name) then
                    table.insert(products, {
                        ProductId = product.Name,
                        ProductUniqueId = product:GetAttribute("HarukaUniqueId")
                    })
                end
            end

            Events.OpenMarketUI.Fire(plr, {
                Products = products
            })


        elseif prompt.Name == "Class" then
            local statue = prompt:FindFirstAncestorOfClass("Model")

            local items = plr.Items :: Folder
            if not items:FindFirstChild(statue.Weapon.Value) then
                Events.ChangeClassVFX.Fire(plr, {
                    ClassId = statue.Name
                })

                ServerLib:GiveItemDrop(plr, statue.Weapon.Value, 1)
            else
                Events.CreateNotify.Fire(plr, " You've already received the Goddess's blessing!")
            end

        elseif prompt.Name == "Material" then
            local material = prompt:FindFirstAncestorOfClass("Model")
            local itemInfo = ItemLib:GetItemInfo(material.Name)


            if itemInfo == nil then return end
            if plr:FindFirstChild("MaterialCD") then return end
            if not prompt:IsDescendantOf(workspace) then return end


            local cdSymbol = Instance.new("BoolValue")
            cdSymbol.Value = true
            cdSymbol.Name = "MaterialCD"
            cdSymbol.Parent = plr
            Debris:AddItem(cdSymbol, 1)

            local char = plr.Character
            if not ServerLib:IsCharValid(char) then return end


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
                    [material:GetAttribute("Rare")] = 30,
                    [material.Name] = 70
                })
            end
            material.Parent = game:GetService("ServerStorage")


            local amount = #material.Collectables:GetChildren() :: number
            amount += math.random(-1, 1)
            amount /= 2
            amount = math.floor(amount)


            ServerLib:GiveItemDrop(plr, finalMaterial, amount)


            task.delay(120, function()
                material.Parent = workspace.MapComponents.Materials

                prompt.Enabled = true
            end)
        end
    end)
end



function GlobalCriRPGLib:_ListenEnemyDMGTracker()
    Events.RequestToDMGPlayer.SetCallback(function(plr: Player, data)
        if data.ProjectileUniqueId == nil then return end
        if data.IsPierce == nil then return end
        if data.DoTStatus == nil then return end


        local projectileUniqueId = data.ProjectileUniqueId
        local projectileList = ServerStorage.ProjectileSymbolContainer :: Folder

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end
        if not projectileList:FindFirstChild(projectileUniqueId) then return end
        if not char:GetAttribute("IsInCombat") then return end


        local symbol = projectileList[projectileUniqueId]
        local projectileDMG = symbol:GetAttribute("Damage") :: number


        Promise.new(function(resolve)
            local result, _, _ = HarukaLib:RollLoot({
                Dodge = char:GetAttribute("DodgeChance"),
                None = 100 - char:GetAttribute("DodgeChance")
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

            ServerBindables.PlayerGotHit:Fire(char.Name, projectileDMG, "Shield")

            Events.PlaySound.Fire(plr, SoundService.SFXs.ShieldAbsorb)

            if afterShield <= 0 then
                Events.PlaySound.Fire(plr, SoundService.SFXs.ShieldBroken)

                local exceededDMG = projectileDMG
                if exceededDMG > 0 then
                    exceededDMG = math.ceil(exceededDMG / 1.599)
                    char.Humanoid:TakeDamage(exceededDMG)

                    Events.PlayGotHitScreenFX.Fire(plr)

                    ServerBindables.PlayerGotHit:Fire(char.Name, exceededDMG, "Health")
                end
            end
        else
            char.Humanoid:TakeDamage(projectileDMG)

            Events.PlayGotHitScreenFX.Fire(plr)

            ServerBindables.PlayerGotHit:Fire(char.Name, projectileDMG, "Health")
        end
    end)
end

function GlobalCriRPGLib:_ListenPlayerDMGTracker()
    Events.RequestToDMGEnemy.SetCallback(function(plr: Player, data)
        local orbUniqueId = data.OrbUniqueId
        if orbUniqueId == nil then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Character")
            return
        end

        local orbList = ServerStorage.OrbSymbolContainer:FindFirstChild("OrbSymbols_"..char:GetAttribute("HarukaUniqueId")) :: Folder?

        if not orbList then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Orb List")
            warn("Invalid orb list")
            return
        end
        if not orbList:FindFirstChild(orbUniqueId) then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Orb Identity")
            warn("Invalid orb identity")
            return
        end

        local symbol = orbList[orbUniqueId] :: CFrameValue
        if symbol:GetAttribute("Owner") ~= char.Name then return end

        local thatOrbStyle = symbol:GetAttribute("OrbStyle") :: string
        local thatOrbSubStyle = symbol:GetAttribute("OrbSubStyle") :: string

        local orbPos = symbol.Value :: CFrame
        symbol:Destroy()


        local check = true
        local whiteList = { "HEAL_ATTACK" }

        Promise.new(function(resolve, reject)
            local DISTANCE = 15

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
end


function GlobalCriRPGLib:_ListenCastItemRequestsTracker()
    Events.RequestToCastItem_Request.SetCallback(function(plr: Player, data)
        local slotId = data.SlotId
        if slotId == nil then return end


        local char = plr.Character
        if not ServerLib:IsCharValid(char) then
            Events.CreateNotify.Fire(plr, "[Error] Invalid Character")
            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end

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

        local itemInfo = ItemLib:GetItemInfo(equippingInfo.Value)
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
            if cdSymbol.Name == plr.Name and cdSymbol:GetAttribute("ItemId") == itemInfo.ItemId then
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

        local realCD = tonumber(itemInfo.ExtraInfoDesync.CD)
        if not realCD then
            warn("Invalid CD for item")

            Events.RequestToCastItem_Response.Fire(plr, {
                SlotId = slotId,
                CooldownTime = 0
            })
            return
        end


        if itemInfo.Type == "Consumable" then
            itemSymbol.Value -= 1

            --// item run out
            if itemSymbol.Value <= 0 then
                itemSymbol:Destroy()
                equippingInfo:Destroy()
            end
        end
        if itemInfo.ExtraInfoDesync.Mana then
            local curMana = char:GetAttribute("Mana") :: number

            if curMana < itemInfo.ExtraInfoDesync.Mana then
                Events.CreateNotify.Fire(plr, "You do not have enough Mana to cast this skill!")
                Events.RequestToCastItem_Response.Fire(plr, {
                    SlotId = slotId,
                    CooldownTime = 0
                })
                return
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
            local statusCode = CastItemLib[itemInfo.ItemId](plr, char, {
                CostManaFunc = function()
                    HarukaLib:AddAttr(char, "Mana", -itemInfo.ExtraInfoDesync.Mana)
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
        itemCDSymbol.Name = plr.Name
        itemCDSymbol:SetAttribute("ItemId", itemInfo.ItemId)
        itemCDSymbol:AddTag("ItemCDSymbol")
        itemCDSymbol.Parent = ServerStorage.ItemCDSymbolContainer
        Debris:AddItem(itemCDSymbol, realCD)

        Events.RequestToCastItem_Response.Fire(plr, {
            SlotId = slotId,
            CooldownTime = realCD
        })
    end)
end


function GlobalCriRPGLib:_ListenPickupItemRequestsTracker()
    Events.RequestToPickupItemDrops.SetCallback(function(plr: Player, data)
        local itemUniqueId = data.ItemUniqueId
        if itemUniqueId == nil then return end

        local itemSymbol = ServerStorage.ItemSphereSymbolContainer:FindFirstChild(itemUniqueId) :: IntValue?

        if not itemSymbol then return end
        if itemSymbol:GetAttribute("Receiver") ~= plr.Name then return end
        if itemSymbol.Value <= 0 then return end


        itemSymbol.Value -= 1
        ServerLib:GiveItemDrop(plr, itemSymbol:GetAttribute("ItemId"), 1)


        if itemSymbol.Value <= 0 then itemSymbol:Destroy() end
    end)
end



function GlobalCriRPGLib:_ListenCastClassUltRequestsTracker()
    Events.RequestToCastClassUlt.SetCallback(function(plr: Player)
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
end


function GlobalCriRPGLib:_ListenNPCChatEndedTracker()
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
        if not ServerLib:IsCharValid(char) then return end

        char:SetAttribute("IsChatting", nil)


        --// do signal
        local extra = DialogueBook[data.NPCId].Extra
        local bindableId = extra[data.SeriesId] :: string?

        if bindableId then
            if QuestBindables[bindableId] then
                QuestBindables[bindableId]:Fire(plr)
            end
        end
    end)
end


function GlobalCriRPGLib:_ListenPlayerItemEquipRequestsTracker()
    Events.RequestToEquipItem.SetCallback(function(plr: Player, data)
        if data.ItemId == nil then return end
        if data.ItemUniqueId == nil then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't equip item in combat!")
            return
        end

        local itemInfo = ItemLib:GetItemInfo(data.ItemId)
        if not itemInfo then return end

        local items = plr.Items :: Folder
        local itemSymbol = items:FindFirstChild(data.ItemId) :: IntConstrainedValue

        if itemSymbol == nil then return end

        local amount = itemSymbol.Value or 0 :: number
        if amount <= 0 then return end

        local level = itemSymbol:GetAttribute("Level") or 999 :: number
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

            ServerLib:EquipItem(plr, weapon1Symbol:GetAttribute("HarukaUniqueId"), "Unequip")

            weapon1Symbol:SetAttribute("HarukaUniqueId", data.ItemUniqueId)
            weapon1Symbol.Value = data.ItemId
            weapon1Symbol.Parent = plr.EquippingItems

            _refresh()
            ServerLib:EquipItem(plr, data.ItemUniqueId)

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
                ServerLib:UnequipItem(plr, data.ItemUniqueId)

                Events.PlaySound.Fire(plr, SoundService.SFXs.EquipItem)
                break
            end
        end
        if not equipCheck then return end



        --// already equipped same item id?
        local sameItemCheck = true
        for _, symbol: StringValue in equipping:GetChildren() do
            if symbol.Value == data.ItemId then
                sameItemCheck = false
                break
            end
        end
        if not sameItemCheck then
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
                ServerLib:EquipItem(plr, data.ItemUniqueId)


                Events.PlaySound.Fire(plr, SoundService.SFXs.EquipItem)
                break
            end
        end
        if not check then
            Events.CreateNotify.Fire(plr, "You don't have enough slots to equip more items!")
            return
        end
    end)
end


function GlobalCriRPGLib:_ListenPlayerPurchaseAndSellItemRequestsTracker()
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
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't purchase items in combat!")
            return
        end
        --// TODO: distance checks


        local itemInfo = ItemLib:GetItemInfo(product)
        if not itemInfo then return end


        local totalPrice = itemInfo.Price * purchaseAmount
        if plr:GetAttribute("Gold") < totalPrice then
            Events.CreateNotify.Fire(plr, "You don't have enough Gold to purchase this item!")
            return
        end

        Events.CreateNotify.Fire(plr, "Purchase successful! Welcome back!")

        HarukaLib:AddAttr(plr, "Gold", -totalPrice)
        Events.PlaySound.Fire(plr, SoundService.SFXs.Buy)

        ServerLib:GiveItemDrop(plr, product, purchaseAmount)
    end)
    Events.RequestToSellItem.SetCallback(function(plr: Player, data)
        local item, sellAmount = data.ItemId, data.SellAmount
        if item == nil then return end
        if data.ItemUniqueId == nil then return end
        if sellAmount == nil then return end

        if sellAmount > 999 then
            Events.CreateNotify.Fire(plr, "You can't sell more than 999 items at once!")
            return
        end


        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't purchase items in combat!")
            return
        end
        --// TODO: distance checks


        local itemInfo = ItemLib:GetItemInfo(item)
        if not itemInfo then return end


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


        local items = plr.Items :: Folder
        local itemSymbol = items:FindFirstChild(item) :: IntConstrainedValue
        if itemSymbol == nil then return end


        local equipping: StringValue = nil
        for _, symbol: StringValue in plr.EquippingItems:GetChildren() do
            if symbol:GetAttribute("HarukaUniqueId") == data.ItemUniqueId then
                equipping = symbol
                break
            end
        end
        if equipping == "Weapon1" then
            Events.CreateNotify.Fire(plr, "You can't sell your equipped weapon!")
            return
        end


        local totalItemHas = itemSymbol.Value or 0 :: number
        if totalItemHas < sellAmount then
            sellAmount = totalItemHas
        end

        itemSymbol.Value -= sellAmount
        if itemSymbol.Value <= 0 then
            itemSymbol:Destroy()

            if equipping then
                equipping:Destroy()
            end
        end


        local totalPrice = itemInfo.Price * sellAmount

        Events.PlaySound.Fire(plr, SoundService.SFXs.Buy)
        Events.CreateNotify.Fire(plr, "Sell successful! Welcome back!")


        HarukaLib:AddAttr(plr, "Gold", totalPrice)
    end)
    Events.RequestToSellAllItems.SetCallback(function(plr: Player, data)
        if not data.ItemId then return end

        local item = data.ItemId

        local itemInfo = ItemLib:GetItemInfo(item)
        if not itemInfo then return end


        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't purchase items in combat!")
            return
        end
        --// TODO: distance checks


        local items = plr.Items :: Folder
        local itemSymbol = items:FindFirstChild(item) :: IntConstrainedValue
        if itemSymbol == nil then return end


        local itemsWithThisId = {}
        for _, symbol: IntConstrainedValue in items:GetChildren() do
            if symbol.Name == item then
                table.insert(itemsWithThisId, symbol)
            end
        end
        if #itemsWithThisId <= 1 then return end


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


        local totalGold = 0
        for _, symbol: IntConstrainedValue in itemsWithThisId do
            totalGold += itemInfo.Price * symbol.Value
            symbol:Destroy()
        end

        Events.PlaySound.Fire(plr, SoundService.SFXs.Buy)
        Events.CreateNotify.Fire(plr, "Sell successful! Welcome back!")

        HarukaLib:AddAttr(plr, "Gold", totalGold)
    end)
end


function GlobalCriRPGLib:_ListenPlayerAddPointRequestsTracker()
    Events.RequestToAddPoint.SetCallback(function(plr: Player, data)
        if data.PointId == nil then return end
        if data.PointAmount == nil then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't change your perk in combat!")
            return
        end

        local pointAdd = data.PointAmount :: number
        local availablePoint = plr:GetAttribute("PerkPoints") :: number

        if availablePoint < pointAdd then
            pointAdd = availablePoint
        end
        if pointAdd == 0 then return end
        if plr:GetAttribute(data.PointId.."Points") <= 0 and pointAdd <= 0 then return end


        if data.PointId == "DEX" and pointAdd > 0 then
            if plr:GetAttribute("DEXPoints") >= FormulaBook.PLAYER_MAX_DEX_POINTS then
                Events.CreateNotify.Fire(plr, "DEX points have reached their limit!")
                return
            end
        end

        HarukaLib:AddAttr(plr, "PerkPoints", -pointAdd)
        HarukaLib:AddAttr(plr, data.PointId.."Points", pointAdd)
    end)
    Events.RequestToResetPoint.SetCallback(function(plr: Player)
        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end

        if char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(plr, "You can't change your perk in combat!")
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
end


function GlobalCriRPGLib:_ListenPlayerDMGBySkillProjectileTracker()
    Events.RequestToDMGEnemyBySkillProjectile.SetCallback(function(plr: Player, data)
        local projectileId = data.ProjectileUniqueId
        if projectileId == nil then return end
        if data.EnemyEntity == nil then return end

        local char = plr.Character
        if not ServerLib:IsCharValid(char) then return end
        if not ServerLib:IsCharValid(data.EnemyEntity) then return end

        local projectileList = ServerStorage.SkillProjectileContainer:FindFirstChild("SkillProjectiles_"..char:GetAttribute("HarukaUniqueId")) :: Folder?

        if not projectileList then return end
        if not projectileList:FindFirstChild(projectileId) then return end

        local symbol = projectileList:FindFirstChild(projectileId) :: StringValue
        local style = symbol:GetAttribute("DMGType") :: string

        if symbol:GetAttribute("Owner") ~= char.Name then return end


        local projectileType = symbol:GetAttribute("ProjectileType") :: string
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


        ClassAttackLib:_DealDamageToEnemy(char, data.EnemyEntity, {
            DMG = ClassAttackLib:_CalDMG(style, char, {
                ForceMaxDMG = true
            })
        })
    end)
end


GlobalCriRPGLib:Init()


return true
