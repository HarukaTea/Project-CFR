
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local AssetBook = require(ReplicatedStorage.HarukaShared.Library.AssetBook)
local ClientLib = require(ReplicatedStorage.HarukaShared.Library.ClientLib)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)
local ClassOrbSpawnAlgoLib = require(ServerScriptService.HarukaServer.Library.ClassOrbSpawnAlgoLib)
local ClassOrbCallbackLib = require(ServerScriptService.HarukaServer.Library.ClassOrbCallbackLib)

local ServerTable = require(ServerScriptService.HarukaServer.Library.ServerTable)

local ArtifactBook = require(ReplicatedStorage.HarukaShared.Library.ArtifactBook)
local ArtifactLib = require(ServerScriptService.HarukaServer.Library.ArtifactLib)
local ClassBook = require(ReplicatedStorage.HarukaShared.Library.ClassBook)
local FormulaBook = require(ReplicatedStorage.HarukaShared.Library.FormulaBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ItemBook = require(ReplicatedStorage.HarukaShared.Library.ItemBook)

local CharTemplate = require(ServerScriptService.HarukaServer.Library.CharTemplate)
local LocationBook = require(ReplicatedStorage.HarukaShared.Library.LocationBook)


local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)



local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait


repeat wait() until char:GetAttribute("Haruka_CharServerInited")

local Add, Empty = HarukaLib.Bin()



type CriRPGLibClass = {
    Funcs: { () -> nil },

    Init: (self: CriRPGLibClass) -> nil,
    Destroy: (self: CriRPGLibClass) -> nil,


    _SpawnToLastLocation: () -> nil,
    _InitAttrs: () -> nil,
    _AutoEquipItems: () -> nil,
}

local CriRPGLib = {} :: CriRPGLibClass
CriRPGLib.Funcs = {}


function CriRPGLib:Init()
    self:_SpawnToLastLocation()
    self:_InitAttrs()

    for _, func: () -> nil in self.Funcs do
        func()
    end

    self:_AutoEquipItems()

    char:SetAttribute("Haruka_CriRPGServerInited", true)
    char:AddTag("PlayerCharEntity")


    ClientLib:InitCharDeadTrackers({
        Char = char,
        Player = plr,
        Add = Add,
        Empty = function()
            self:Destroy()
        end
    })
end



function CriRPGLib:Destroy()
    Empty()
end



--// Private methods


function CriRPGLib:_SpawnToLastLocation()
    local lastLocation = plr:GetAttribute("LastSeen") :: string

    lastLocation = lastLocation or "UnknownBase"
    local map = workspace.Maps:FindFirstChild(lastLocation, true) :: Folder

    if map then
        local spawnPoints = map:FindFirstChild("SpawnPoints") :: Configuration
        if spawnPoints then
            local spawnPointChildern = spawnPoints:GetChildren()
            if #spawnPointChildern > 0 then
                local rSpawnPoint = spawnPointChildern[math.random(1, #spawnPointChildern)]

                char:PivotTo(rSpawnPoint.CFrame * CFrame.new(0, 5.99, 0))
                Events.RefreshCullingAsync_S.Fire(plr)
                return
            end
        end
    end
    local baseSpawn = workspace.Maps:FindFirstChildWhichIsA("SpawnLocation", true)

    char:PivotTo(baseSpawn.CFrame * CFrame.new(0, 5.99, 0))
    Events.RefreshCullingAsync_S.Fire(plr)
end


function CriRPGLib:_InitAttrs()
    for attr, val in HarukaLib.TableUtils.DeepCopy(CharTemplate) do
        if val == "_OBJECT" then
            local objVal = Instance.new("ObjectValue")
            objVal.Name = attr
            objVal.Value = nil
            objVal.Parent = char
            continue

        elseif val == "_FOLDER" then
            local folder = Instance.new("Folder")
            folder.Name = attr
            folder.Parent = char
            continue

        elseif val == "_EVENT" then
            local bindable = Instance.new("BindableEvent")
            bindable.Name = attr
            bindable.Parent = char
            continue
        end

        char:SetAttribute(attr, val)
    end
end


function CriRPGLib:_AutoEquipItems()
    for _, item: StringValue in plr.EquippingItems:GetChildren() do
        local itemSymbol = nil

        for _, thatItemSymbol: IntConstrainedValue in plr.Items:GetChildren() do
            if thatItemSymbol:GetAttribute("HarukaUniqueId") == item:GetAttribute("HarukaUniqueId") then
                itemSymbol = thatItemSymbol
                break
            end
        end
        if not itemSymbol then
            continue
        end
        if itemSymbol.Value <= 0 then
            item:Destroy()
            continue
        end

        local uniqueId = item:GetAttribute("HarukaUniqueId") :: string
        ServerLib:EquipItem(plr, uniqueId)
    end
    for _, item: IntConstrainedValue in plr.Items:GetChildren() do
        local itemInfo = ItemBook:GetItemInfo(item.Name)
        if not itemInfo then continue end

        if itemInfo.Type == "Passive" then
            ServerLib:EquipItem(plr, item:GetAttribute("HarukaUniqueId"))
        end
    end
end




table.insert(CriRPGLib.Funcs, function()
    local light = Instance.new("PointLight")
    light.Range = 28
    light.Brightness = 2.5
    light.Color = Color3.fromHex('#f1c40f')
    light.Shadows = false
    light.Parent = char.PrimaryPart

    Add(HarukaLib:Hydrate(char, {
        ["Attr-CanLight"] = function(state: boolean)
            light.Enabled = state or false
        end
    }))
end)


table.insert(CriRPGLib.Funcs, function()
	local function _equipWeapon()
		for _, weapon: Model in char:GetChildren() do
			if weapon:HasTag("ClassWeapon") then weapon:Destroy() end
		end

        local hasCosmetic = plr.EquippingItems:FindFirstChild("Cosmetic1") or plr.EquippingItems:FindFirstChild("Cosmetic2")
        if hasCosmetic and hasCosmetic.Value ~= "" then return end

        local combatState = char:GetAttribute("IsInCombat") or false
        local targetFolder = if combatState then "Combat" else "Overworld"
        local weaponId = plr.EquippingItems.Weapon1.Value :: string


        local weaponFolder = ReplicatedStorage.Packages.ClassWeapons:FindFirstChild(weaponId, true) :: Folder
        if not weaponFolder then return end
        if not weaponFolder:FindFirstChild(targetFolder) then return end


        for _, weapon: Model in char:GetChildren() do
			if weapon:HasTag("ClassWeapon") then weapon:Destroy() end
		end
		for _, weapon: Model in weaponFolder[targetFolder]:GetChildren() do
            task.defer(function()
                local weaponE = weapon:Clone()
			    weaponE:AddTag("ClassWeapon")

			    ServerLib:WeldWeapon(weaponE, char)
            end)
		end
	end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _equipWeapon
    }))
    Add(HarukaLib:Hydrate(plr.EquippingItems.Weapon1, {
        ["Prop-Value"] = _equipWeapon
    }))

    local function _equipArmor(item: StringValue)
        if string.find(item.Name, "Cosmetic") then
            ServerLib:EquipArmor(char, item.Value)
            _equipWeapon()
        end
    end
    Add(plr.EquippingItems.ChildAdded:Connect(_equipArmor))
    Add(plr.EquippingItems.ChildRemoved:Connect(function(item: StringValue)
        if string.find(item.Name, "Cosmetic") then
            ServerLib:UnequipArmor(char, item.Value)
            _equipWeapon()
        end
    end))

    for _, item: StringValue in plr.EquippingItems:GetChildren() do
        _equipArmor(item)
    end
end)



table.insert(CriRPGLib.Funcs, function()
    local orbResContainer = ReplicatedStorage.Packages.ClassAttacks :: Folder
    local charUniqueId = char:GetAttribute("HarukaUniqueId")

    ServerTable.OrbSymbols[charUniqueId] = {}


    local orbSpawnAdd, orbSpawnEmpty = HarukaLib.Bin()
    local function _spawnOrb_Callback(orbData: ClassOrbCallbackLib.ClassOrbData)
        local class = plr:GetAttribute("Class") or "Burst"

        if ClassOrbCallbackLib[class] then
            ClassOrbCallbackLib[class](orbData, char)
        end
    end
    local function _spawnOrb_done(orbName: string, extraProps: {
        Offset: Vector3?,
        ForceLocation: CFrame?,

        NeedCallback: boolean?
    }?)
        local enemy = char.TargetingEnemy.Value :: Model
        local extraProps = extraProps or {
            ForceLocation = nil,
            Offset = nil,

            NeedCallback = false
        }

        if ServerLib:IsCharValid(enemy) and char.Humanoid.Health > 0 then
            local orb = orbResContainer:FindFirstChild(orbName, true) :: Model
            if not orb then
                warn("Invalid Orb Id: "..orbName)
                return
            end

            local orbUniqueId = HttpService:GenerateGUID(false)
            local orbPos = extraProps.ForceLocation or ServerLib:GenerateOrbPos(char:GetAttribute("CombatLocation"))
            local orbFadeTime = char:GetAttribute("OrbFadeTime") or 12 :: number

            if extraProps.Offset then
                orbPos *= CFrame.new(extraProps.Offset)
            end

            local orbUniStyle = HarukaLib:RollLoot({
                ["Heal"] = 10,
                ["ATK"] = 5,
                ["Normal"] = 100 - 10 - 5
            })


            ServerTable.OrbSymbols[charUniqueId][orbUniqueId] = {
                UniqueId = orbUniqueId,
                OrbId = orb.Name,
                OrbStyle = orb:GetAttribute("Style"),
                OrbSubStyle = orb:GetAttribute("SubStyle"),
                OrbUniStyle = orbUniStyle,
                OrbDuration = orbFadeTime,
                OrbLocation = orbPos,
                Owner = char.Name,
                CreatedTimeMS = DateTime.now().UnixTimestampMillis
            }
            ServerTable:AddItem(ServerTable.OrbSymbols[charUniqueId], orbUniqueId, orbFadeTime)


            Events.PlaceOrb_S.Fire(plr, {
                OrbId = orb.Name,
                OrbUniqueId = orbUniqueId,
                OrbDuration = orbFadeTime,
                OrbLocationPos = orbPos.Position,
                OrbUniStyle = orbUniStyle
            })


            if extraProps.NeedCallback then
                _spawnOrb_Callback(ServerTable.OrbSymbols[charUniqueId][orbUniqueId])
            end
        end
    end
    local function _spawnOrb()
        local class = plr:GetAttribute("Class") or "Burst"

        if not ClassOrbSpawnAlgoLib[class] then
            warn("Invalid orb spawn algorithm for class: "..class)
            return
        end

        ClassOrbSpawnAlgoLib[class](_spawnOrb_done)
    end
    local function orbSpawnHandler(state: boolean)
        if state then
            orbSpawnEmpty()

            local orbSpawnTimesAtStart = char:GetAttribute("OrbSpawnTimesAtStart") or 1

            orbSpawnAdd(task.delay(1, function()
                for _ = 1, orbSpawnTimesAtStart do _spawnOrb() end
            end))
            orbSpawnAdd(task.spawn(function()
                while char:GetAttribute("IsInCombat") do
                    local orbSpawnTime = char:GetAttribute("OrbSpawnTime") or 3
                    local intensity = char:GetAttribute("Intensity") or 0
                    local reducedTime = orbSpawnTime * (intensity / 100)

                    orbSpawnTime -= reducedTime
                    orbSpawnTime = math.max(1, orbSpawnTime)

                    wait(orbSpawnTime)
                    if not char:GetAttribute("IsInCombat") then break end

                    _spawnOrb()
                end
            end))
        else
            orbSpawnEmpty()
        end
    end
    Add(orbSpawnEmpty)
    Add(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = orbSpawnHandler,
    }))


    Add(ServerBindables.RToSpawnOrb:Connect(function(charId: string, orbName: string, extraProps: {
        Offset: Vector3?,
        ForceLocation: CFrame?
    }?)
        if charId ~= char.Name then return end

        _spawnOrb_done(orbName, extraProps)
    end))

    orbSpawnEmpty()
end)



table.insert(CriRPGLib.Funcs, function()
    local charUniqueId = char:GetAttribute("HarukaUniqueId") :: string

    ServerTable.SkillProjectileSymbols[charUniqueId] = {}

    Add(ServerBindables.RToCreateProjectileSymbol:Connect(function(charId: string, props: ServerTable.SkillProjectileData)
        if charId ~= char.Name then return end

        props.Owner = char.Name
        ServerTable.SkillProjectileSymbols[charUniqueId][props.ProjectileUniqueId] = props

        ServerTable:AddItem(ServerTable.SkillProjectileSymbols[charUniqueId], props.ProjectileUniqueId, props.LifeTime)
    end))
end)



table.insert(CriRPGLib.Funcs, function()
    local function _handleEXP(exp: number, props: {
        LevelAttr: string,
        EXPAttr: string,
        Formula: string,
        MaxLevel: number,
        PerkPointAttr: string,
    })
        local level = plr:GetAttribute(props.LevelAttr) :: number
        if not level then return end

        local totalLevelShouldGive = 0
        local maxEXPGained = 0

        while exp >= maxEXPGained do
            maxEXPGained += FormulaBook[props.Formula]({
                Level = level + totalLevelShouldGive
            })

            if exp >= maxEXPGained then
                totalLevelShouldGive += 1
            else
                maxEXPGained -= FormulaBook[props.Formula]({
                    Level = level + totalLevelShouldGive
                })
                break
            end
            RunService.Stepped:Wait()
        end
        if totalLevelShouldGive > 0 then
            if plr:GetAttribute(props.LevelAttr) + totalLevelShouldGive > props.MaxLevel then
                totalLevelShouldGive = props.MaxLevel - plr:GetAttribute(props.LevelAttr)
            end
            if totalLevelShouldGive <= 0 then
                plr:SetAttribute(props.EXPAttr, 0)
                return
            end

            HarukaLib:AddAttr(plr, props.LevelAttr, totalLevelShouldGive)
            HarukaLib:AddAttr(plr, props.EXPAttr, -math.ceil(maxEXPGained))
            HarukaLib:AddAttr(plr, props.PerkPointAttr, FormulaBook.PLAYER_POINT_PER_LEVEL * totalLevelShouldGive)

            Events.PlaySound_S.Fire(plr, SoundService.SFXs.LevelUp)
            ServerLib:ShowText(char, "LEVEL UP!", Color3.fromHex('#ffeaa7'))

            Events.PlayVFXStatusToPlayer_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
                StatusId = "LevelUp",
                Character = char,
            })

            char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
    end
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-EXP"] = function(exp: number)
            _handleEXP(exp, {
                EXPAttr = "EXP",
                LevelAttr = "Level",
                Formula = "PlayerLevelCurveCal",
                MaxLevel = FormulaBook.PLAYER_MAX_LEVEL,
                PerkPointAttr = "PerkPoints"
            })
        end,
        ["Attr-Level"] = function(level: number)
            if level == nil then return end
            if level > FormulaBook.PLAYER_MAX_LEVEL then
                plr:SetAttribute("Level", FormulaBook.PLAYER_MAX_LEVEL)
                Events.CreateNotify_S.Fire(plr, "You've hit the level cap!")
            end
        end
    }))


    local classAdd, classEmpty = HarukaLib.Bin()
    Add(classEmpty)


    Add(HarukaLib:Hydrate(plr, {
        ["Attr-Class"] = function(class: string)
            classEmpty()
            class = class or "Chain"

            classAdd(HarukaLib:Hydrate(plr, {
                ["Attr-ClassEXP_"..class] = function(exp: number)
                    _handleEXP(exp, {
                        EXPAttr = "ClassEXP_"..class,
                        LevelAttr = "ClassLevel_"..class,
                        Formula = "PlayerClassLevelCurveCal",
                        MaxLevel = FormulaBook.PLAYER_MAX_CLASS_LEVEL,
                        PerkPointAttr = "ClassPerkPoint_"..class,
                    })
                end,
                ["Attr-ClassLevel_"..class] = function(level: number)
                    if level == nil then return end
                    if level > FormulaBook.PLAYER_MAX_CLASS_LEVEL then
                        plr:SetAttribute("ClassLevel_"..class, FormulaBook.PLAYER_MAX_CLASS_LEVEL)

                        Events.CreateNotify_S.Fire(plr, "You've hit the class level cap!")
                    end
                end
            }))
        end
    }))
end)




table.insert(CriRPGLib.Funcs, function()
    --- class base
    local function _updateClassBase(class: string)
        if not class then return end

        for attr, val in HarukaLib.TableUtils.DeepCopy(CharTemplate) do
            if string.find(attr, "Base") then
                char:SetAttribute(attr, val)
            end
        end

        local baseStats = ClassBook[class].BaseStats or {}
        for attr: string, val: any in baseStats do
            if not char:GetAttribute("Base"..attr) then
                warn("Invalid class base stat: "..attr)
                continue
            end

            char:SetAttribute("Base"..attr, val)
        end
    end
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-Class"] = _updateClassBase
    }))



    local function _updateSpeed()
        local speedBuff = char:GetAttribute("SpeedEx") :: number
        local speedExBuff = char:GetAttribute("SpeedExPower") :: number
        local finalSpeed = if char:GetAttribute("IsInCombat") then char:GetAttribute("BaseSpeedCombat") else char:GetAttribute("BaseSpeed")

        local final = math.ceil((finalSpeed + speedBuff) * speedExBuff)

        char.Humanoid.WalkSpeed = final
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseSpeed"] = _updateSpeed,
        ["Attr-BaseSpeedCombat"] = _updateSpeed,
        ["Attr-SpeedEx"] = _updateSpeed,
        ["Attr-SpeedExPower"] = _updateSpeed,
        ["Attr-IsInCombat"] = _updateSpeed
    }))



    local function _updateJump()
        local jumpBuff = char:GetAttribute("JumpEx") :: number
        local jumpExBuff = char:GetAttribute("JumpExPower") :: number
        local baseJump = char:GetAttribute("BaseJumpPower") :: number

        local final = math.ceil((baseJump + jumpBuff) * jumpExBuff)

        char.Humanoid.JumpPower = final
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseJumpPower"] = _updateJump,
        ["Attr-JumpEx"] = _updateJump,
        ["Attr-JumpExPower"] = _updateJump
    }))



    local function _updateMinDMG()
        local baseMinDMG = char:GetAttribute("BaseMinDMG") :: number
        local minDMGBuff = char:GetAttribute("MinDMGEx") :: number
        local minDMGExBuff = char:GetAttribute("MinDMGExPower") :: number

        local point = plr:GetAttribute("STRPoints") :: number

        baseMinDMG = FormulaBook.PlayerDMGCurveCal({
            BaseDMG = baseMinDMG,
            DMGPoints = point,
            ATKType = "Min"
        })

        local final = math.ceil((baseMinDMG + minDMGBuff) * minDMGExBuff)

        char:SetAttribute("MinDMG", final)
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseMinDMG"] = _updateMinDMG,
        ["Attr-MinDMGEx"] = _updateMinDMG,
        ["Attr-MinDMGExPower"] = _updateMinDMG,
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-STRPoints"] = _updateMinDMG,
    }))


    local function _updateMaxDMG()
        local baseMaxDMG = char:GetAttribute("BaseMaxDMG") :: number
        local maxDMGBuff = char:GetAttribute("MaxDMGEx") :: number
        local maxDMGExBuff = char:GetAttribute("MaxDMGExPower") :: number

        baseMaxDMG = FormulaBook.PlayerDMGCurveCal({
            BaseDMG = baseMaxDMG,
            DMGPoints = plr:GetAttribute("STRPoints"),

            ATKType = "Max"
        })

        local final = math.ceil((baseMaxDMG + maxDMGBuff) * maxDMGExBuff)

        char:SetAttribute("MaxDMG", final)
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseMaxDMG"] = _updateMaxDMG,
        ["Attr-MaxDMGEx"] = _updateMaxDMG,
        ["Attr-MaxDMGExPower"] = _updateMaxDMG,
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-STRPoints"] = _updateMaxDMG,
    }))


    local function _updateMagic()
        local baseMagic = char:GetAttribute("BaseMagic") :: number
        local magicBuff = char:GetAttribute("MagicEx") :: number
        local magicExBuff = char:GetAttribute("MagicExPower") :: number

        baseMagic = FormulaBook.PlayerMagicCurveCal({
            BaseMagic = baseMagic,
            MagicPoints = plr:GetAttribute("INTPoints")
        })

        local final = math.ceil((baseMagic + magicBuff) * magicExBuff)

        char:SetAttribute("Magic", final)
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseMagic"] = _updateMagic,
        ["Attr-MagicEx"] = _updateMagic,
        ["Attr-MagicExPower"] = _updateMagic,
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-INTPoints"] = _updateMagic,
    }))


    local function _updateHealth()
        local baseHealth = char:GetAttribute("BaseMaxHealth") :: number
        local healthBuff = char:GetAttribute("MaxHealthEx") :: number
        local healthExBuff = char:GetAttribute("MaxHealthExPower") :: number


        local base = FormulaBook.PlayerHealthCurveCal({
            BaseHealth = baseHealth,
            HealthPoints = plr:GetAttribute("VITPoints")
        })
        local final = math.ceil((base + healthBuff) * healthExBuff)


        char.Humanoid.MaxHealth = final


        if DateTime.now().UnixTimestamp - char:GetAttribute("SpawnClock") < 5 then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
        if char.Humanoid.Health > char.Humanoid.MaxHealth then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseMaxHealth"] = _updateHealth,
        ["Attr-MaxHealthEx"] = _updateHealth,
        ["Attr-MaxHealthExPower"] = _updateHealth,
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-VITPoints"] = _updateHealth,
    }))



    local function _updateShield()
        local baseShield = char:GetAttribute("BaseMaxShield") :: number
        local shieldBuff = char:GetAttribute("MaxShieldEx") :: number
        local shieldExBuff = char:GetAttribute("MaxShieldExPower") :: number


        local shield = baseShield

        local final = math.ceil((shield + shieldBuff) * shieldExBuff)

        char:SetAttribute("MaxShield", final)


        if DateTime.now().UnixTimestamp - char:GetAttribute("SpawnClock") < 5 then
            char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
        end
        if char:GetAttribute("Shield") > char:GetAttribute("MaxShield") then
            char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
        end
        if char:GetAttribute("Shield") < 0 then
            char:SetAttribute("Shield", 0)
        end
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseMaxShield"] = _updateShield,
        ["Attr-MaxShieldEx"] = _updateShield,
        ["Attr-MaxShieldExPower"] = _updateShield,
    }))


    local function _updateMana()
        local baseMana = char:GetAttribute("BaseMaxMana") :: number
        local manaBuff = char:GetAttribute("MaxManaEx") :: number
        local manaExBuff = char:GetAttribute("MaxManaExPower") :: number

        local final = math.ceil((baseMana + manaBuff) * manaExBuff)

        char:SetAttribute("MaxMana", final)


        if DateTime.now().UnixTimestamp - char:GetAttribute("SpawnClock") < 5 then
            char:SetAttribute("Mana", char:GetAttribute("MaxMana"))
        end
        if char:GetAttribute("Mana") > char:GetAttribute("MaxMana") then
            char:SetAttribute("Mana", char:GetAttribute("MaxMana"))
        end
        if char:GetAttribute("Mana") < 0 then
            char:SetAttribute("Mana", 0)
        end
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseMaxMana"] = _updateMana,
        ["Attr-MaxManaEx"] = _updateMana,
        ["Attr-MaxManaExPower"] = _updateMana,
    }))


    local function _hpCheck()
        if char.Humanoid.Health > char.Humanoid.MaxHealth then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
    end
    Add(HarukaLib:Hydrate(char.Humanoid, {
        ["Prop-Health"] = _hpCheck,
        ["Prop-MaxHealth"] = _hpCheck,
    }))


    local function _shieldCheck()
        if char:GetAttribute("Shield") > char:GetAttribute("MaxShield") then
            char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
        end
        if char:GetAttribute("Shield") < 0 then
            char:SetAttribute("Shield", 0)
        end
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-Shield"] = _shieldCheck,
        ["Attr-MaxShield"] = _shieldCheck,
    }))


    local function _manaCheck()
        if char:GetAttribute("Mana") > char:GetAttribute("MaxMana") then
            char:SetAttribute("Mana", char:GetAttribute("MaxMana"))
        end
        if char:GetAttribute("Mana") < 0 then
            char:SetAttribute("Mana", 0)
        end
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-Mana"] = _manaCheck,
        ["Attr-MaxMana"] = _manaCheck,
    }))


    local function _updateCriChance()
        local baseCritChance = char:GetAttribute("BaseCriChance") :: number
        local critChanceBuff = char:GetAttribute("CriChanceEx") :: number
        local critChanceExBuff = char:GetAttribute("CriChanceExPower") :: number

        local final = FormulaBook.PlayerCriChanceCurveCal({
            BaseCritChance = baseCritChance,
            DexPoints = plr:GetAttribute("DEXPoints")
        })

        final = math.floor((final + critChanceBuff) * critChanceExBuff)

        char:SetAttribute("CriChance", final)
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseCriChance"] = _updateCriChance,
        ["Attr-CriChanceEx"] = _updateCriChance,
        ["Attr-CriChanceExPower"] = _updateCriChance,
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-DEXPoints"] = _updateCriChance,
    }))



    --// track chance stats (clamp)
    local whiteList = { "Intensity", "Warding", "Luck" }
    for stat, _ in HarukaLib.TableUtils.DeepCopy(CharTemplate) do
        if not string.find(stat, "Chance") then continue end
        if string.find(stat, "Ex") then continue end
        if string.find(stat, "Base") then continue end

        local function __track()
            local chance = char:GetAttribute(stat)
            if chance < 0 then char:SetAttribute(stat, 0) end
            if chance > 100 then char:SetAttribute(stat, 100) end
        end
        Add(HarukaLib:Hydrate(char, {
            ["Attr-"..stat] = __track
        }))
    end
    for _, stat in whiteList do
        local function __track()
            local chance = char:GetAttribute(stat)
            if chance < 0 then char:SetAttribute(stat, 0) end
            if chance > 100 then char:SetAttribute(stat, 100) end
        end
        Add(HarukaLib:Hydrate(char, {
            ["Attr-"..stat] = __track
        }))
    end



    --// track rest stats
    local blackList = {
        "BaseMagic", "BaseMinDMG", "BaseMaxDMG", "BaseSpeed", "BaseSpeedCombat",
        "BaseJumpPower", "BaseMaxShield", "BaseCriChance", "BaseMaxMana"
    }
    for stat, _ in HarukaLib.TableUtils.DeepCopy(CharTemplate) do
        if table.find(blackList, stat) then continue end
        if not string.find(stat, "Base") then continue end
        if not char:GetAttribute(stat) then
            warn("Invalid base stat: "..stat)
            continue
        end

        local statWithoutBase = string.sub(stat, 5)
        local function __track()
            local base = char:GetAttribute(stat)
            local ex = char:GetAttribute(statWithoutBase.."Ex")
            local exPower = char:GetAttribute(statWithoutBase.."ExPower")

            local final = math.ceil((base + ex) * exPower)

            char:SetAttribute(statWithoutBase, final)
        end
        Add(HarukaLib:Hydrate(char, {
            ["Attr-"..stat] = __track,
            ["Attr-"..statWithoutBase.."Ex"] = __track,
            ["Attr-"..statWithoutBase.."ExPower"] = __track
        }))
    end
end)


table.insert(CriRPGLib.Funcs, function()
    local healAdd, healEmpty = HarukaLib.Bin()
    Add(healEmpty)


    local function _healthRecover()
        healEmpty()
        healAdd(task.spawn(function()
            local waitTime = char:GetAttribute("HealthRegenWaitTime") or 15

            wait(waitTime)
            while wait(0.35) do
                if char.Humanoid.Health <= 0
                    or char.Humanoid.Health >= char.Humanoid.MaxHealth
                    or char:FindFirstChild("AntiHeal") then
                    break
                end

                char.Humanoid.Health += math.ceil(char.Humanoid.MaxHealth * 0.01)
            end
        end))
    end
    Add(char.PlayerGotHit.Event:Connect(function(charId: string, _, part: string)
        if charId ~= char.Name then return end
        if part == "Health" then _healthRecover() end
    end))
    Add(HarukaLib:Hydrate(char.Humanoid, {
        ["Prop-MaxHealth"] = _healthRecover
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-VITPoints"] = _healthRecover,
    }))
end)


table.insert(CriRPGLib.Funcs, function()
    local repairAdd, repairEmpty = HarukaLib.Bin()
    Add(repairEmpty)


    local function _shieldRecover()
        repairEmpty()
        repairAdd(task.spawn(function()
            local waitTime = char:GetAttribute("ShieldRegenWaitTime") or 10

            wait(waitTime)
            while wait(0.15) do
                if char:GetAttribute("Shield") >= char:GetAttribute("MaxShield") then
                    break
                end

                HarukaLib:AddAttr(char, "Shield", math.ceil(char:GetAttribute("MaxShield") * 0.01))
            end
        end))
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-MaxShield"] = _shieldRecover,
    }))
    Add(char.PlayerGotHit.Event:Connect(function(charId: string, _, part: string)
        if charId ~= char.Name then return end
        if part == "Shield" then _shieldRecover() end
    end))
end)


table.insert(CriRPGLib.Funcs, function()
    Add(HarukaLib:Hydrate(plr.EquippingItems.Weapon1, {
        ["Prop-Value"] = function(weapon: string)
            weapon = weapon or ""

            if not ItemBook:GetItemInfo(weapon) then return end

            local itemUniqueId = plr.EquippingItems.Weapon1:GetAttribute("HarukaUniqueId") :: string
            local itemSymbol: IntConstrainedValue = nil
            for _, symbol: IntConstrainedValue in plr.Items:GetChildren() do
                if symbol:GetAttribute("HarukaUniqueId") == itemUniqueId then
                    itemSymbol = symbol
                    break
                end
            end
            if itemSymbol == nil then return end

            local itemStat = itemSymbol:GetAttribute("ItemStat") or ""
            local itemStats = ItemBook:ParseItemStat("Stat", string.split(itemStat, ","))

            local class = itemStats.ForClass :: string
            plr:SetAttribute("Class", class)
        end
    }))
end)


table.insert(CriRPGLib.Funcs, function()
    local function _handleItem(item: IntConstrainedValue, method: string)
        local itemInfo = ItemBook:GetItemInfo(item.Name)
        if not itemInfo then return end

        if itemInfo.Type == "Passive" then
            if method == "Equip" then
                ServerLib:EquipItem(plr, item:GetAttribute("HarukaUniqueId"))
            elseif method == "Unequip" then
                ServerLib:UnequipItem(plr, item:GetAttribute("HarukaUniqueId"))
            end
        end
    end
    Add(plr.Items.ChildAdded:Connect(function(item: IntConstrainedValue)
        _handleItem(item, "Equip")
    end))
    Add(plr.Items.ChildRemoved:Connect(function(item: IntConstrainedValue)
        _handleItem(item, "Unequip")
    end))
end)


table.insert(CriRPGLib.Funcs, function()
    local artifactContainer = Instance.new("Folder")
    artifactContainer.Name = "Artifacts"
    artifactContainer.Parent = char
    Add(artifactContainer)


    local setThreshold = { 2, 3 }

    local function applyArtifactEff(artifactId: string, pieceCount: number)
        local effName = artifactId..pieceCount
        local effFunc = ArtifactLib[effName]
        if not effFunc then return end

        effFunc(char, 1)

        local exScript = ReplicatedStorage.HarukaRes.Artifacts:FindFirstChild(effName) :: Script
        local node
        if exScript then
            node = exScript:Clone()
        else
            node = Instance.new("BoolValue")
            node.Value = true
        end
        node.Name = effName
        node.Parent = artifactContainer
    end
    local function removeArtifactEff(artifactId: string, pieceCount: number)
        local effName = artifactId..pieceCount
        local node = artifactContainer:FindFirstChild(effName)
        if not node then return end

        if node:GetAttribute("ReqDestroyingEvent") then
            local destroyFunc = ArtifactLib[effName.."Destroying"]
            if destroyFunc then destroyFunc(char, -1) end
        end

        node:Destroy()

        local effFunc = ArtifactLib[effName]
        if effFunc then effFunc(char, -1) end
    end
    local function updateArtifactSet()
        local artifactSetCount = {} :: {[string]: number}

        for _, artifactId: string in ArtifactBook:GetAllArtifactIds() do
            artifactSetCount[artifactId] = 0
        end

        for _, equipSymbol: StringValue in plr.EquippingItems:GetChildren() do
            local itemInfo = ItemBook:GetItemInfo(equipSymbol.Value)
            if not itemInfo then continue end

            local artifactInfo = ArtifactBook:GetArtifactInfo(itemInfo.ArtifactId)
            if not artifactInfo.ArtifactId then continue end

            artifactSetCount[artifactInfo.ArtifactId] += 1
        end

        for artifactId: string, count: number in artifactSetCount do
            local pastCount = char:GetAttribute("_ARTIFACT_"..artifactId.."_SetCount") or 0 :: number

            for _, threshold: number in setThreshold do
                local hasNow = count >= threshold
                local hasBefore = pastCount >= threshold

                if hasNow and not hasBefore then
                    applyArtifactEff(artifactId, threshold)
                elseif not hasNow and hasBefore then
                    removeArtifactEff(artifactId, threshold)
                end
            end

            char:SetAttribute("_ARTIFACT_"..artifactId.."_SetCount", count)
        end
    end
    Add(plr.EquippingItems.ChildAdded:Connect(updateArtifactSet))
    Add(plr.EquippingItems.ChildRemoved:Connect(updateArtifactSet))

    updateArtifactSet()
end)




table.insert(CriRPGLib.Funcs, function()
	local event = Instance.new("BindableEvent")
	event.Name = "EnemyGotHit"
	event.Parent = script

	local function _checkAndAward(badgeId: number)
		if not plr:GetAttribute("BADGE_"..badgeId) then
			plr:SetAttribute("BADGE_"..badgeId, true)

			ServerLib:GiveBadge(badgeId, plr)
		end
	end

	Add(HarukaLib:Hydrate(plr, {
		["Attr-Gold"] = function(val: number)
			val = val or 0

			if val >= 1000 then
				_checkAndAward(AssetBook.BadgeIds.GoldGatherer)
			end
			if val >= 1000 * 100 then
				_checkAndAward(AssetBook.BadgeIds.GoldCollector)
			end
		end,
		["Attr-CombatWonTimes"] = function(val: number)
			val = val or 0

			if val >= 100 then
				_checkAndAward(AssetBook.BadgeIds.Fighter)
			end
		end
	}))
	Add(AccessoryUniversal.RegisterEnemyOnHit(script, event, char, function(targeting: Model, attacker: Model, dmgProps: AccessoryUniversal.DMGPropsMetaData)
		if dmgProps.Attacker ~= "ClassAttacks" then return end

		if dmgProps.DMG >= 1000 then
			_checkAndAward(AssetBook.BadgeIds.StoneBreaker)
		end
	end))
	AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)
end)



table.insert(CriRPGLib.Funcs, function()
    local areaQueue = HarukaLib.Queue()
    Add(areaQueue)

    local function _changeLocation()
        if areaQueue:IsLocked() then return end
        if areaQueue:IsEmpty() then return end

        areaQueue:SpawnMutex(1.5)

        local location = areaQueue:Pop() :: string

        if location and location ~= "" and location ~= "None" and LocationBook[location] then
            --- apply character base stat
            char:SetAttribute("BaseSpeed", LocationBook[location].BaseSpeed or 40)
            char:SetAttribute("BaseJumpPower", LocationBook[location].BaseJumpPower or 50)
        end
    end
    areaQueue.ElementAdded:Connect(_changeLocation)
    areaQueue.MutexUnlocked:Connect(_changeLocation)

    Add(HarukaLib:Hydrate(char, {
        ["Attr-AreaIn"] = function(region: string)
            areaQueue:Push(region)
        end
    }))
end)



CriRPGLib:Init()


Add(char.TargetingList.ChildAdded:Connect(function(child: ObjectValue)
	char.PlayerTargetAdded:Fire(char.Name, child.Value)
end))
Add(HarukaLib.Clock(5, function()
    if not char:GetAttribute("IsInCombat") then return end


	for _, obj in char.TargetingList:GetChildren() do
		if not ServerLib:IsCharValid(obj.Value) then
			obj:Destroy()
		end
	end
    for _, obj: ObjectValue in char.TargetingList:GetChildren() do
		for _, anotherObj: ObjectValue in char.TargetingList:GetChildren() do
            if anotherObj == obj then continue end

            if obj.Value == anotherObj.Value then
                obj:Destroy()
            end
        end
	end

	local targetingEnemy = char.TargetingEnemy.Value
	if not ServerLib:IsCharValid(targetingEnemy) then
		char.TargetingEnemy.Value = nil
    end
    if char.TargetingEnemy.Value == nil then
		if #char.TargetingList:GetChildren() > 0 then
			char.TargetingEnemy.Value = char.TargetingList:FindFirstChildOfClass("ObjectValue").Value
		end
	end
    if char.TargetingEnemy.Value == nil then
		char.PlayerCombatEnded:Fire(char.Name)
	end
end, true))
Add(char.PlayerCombatEnded.Event:Connect(function(charId: string)
    if charId ~= char.Name then return end

    char.TargetingEnemy.Value = nil

    char:SetAttribute("CombatLocation", nil)
    char:SetAttribute("IsInCombat", false)

    local cooldown = Instance.new("BoolValue")
    cooldown.Name = "CombatCooldown"
    cooldown.Value = true
    cooldown.Parent = char
    Debris:AddItem(cooldown, 1)
end))
Add(function()
    for _, cdSymbol: StringValue in workspace.MapComponents.ItemCDSymbolContainer:GetChildren() do
        if cdSymbol.Name == plr.Name then
            cdSymbol:Destroy()
        end
    end
end)
