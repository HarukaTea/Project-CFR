local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local CriRPGLib = {}


local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)
local ClassOrbSpawnAlgoLib = require(ServerScriptService.HarukaServer.Library.ClassOrbSpawnAlgoLib)

local ClassBook = require(ReplicatedStorage.HarukaShared.Library.ClassBook)
local FormulaBook = require(ReplicatedStorage.HarukaShared.Library.FormulaBook)
local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local ItemLib = require(ReplicatedStorage.HarukaShared.Library.ItemLib)
local Maid = require(ReplicatedStorage.HarukaShared.Shared.Maid)
local PerkBook = require(ReplicatedStorage.HarukaShared.Library.PerkBook)
local PerkLib = require(ServerScriptService.HarukaServer.Library.PerkLib)


local CharTemplate = require(ServerScriptService.HarukaServer.Library.CharTemplate)
local CharLimitsTemplate = require(ServerScriptService.HarukaServer.Library.CharLimitsTemplate)


local char = script:FindFirstAncestorOfClass("Model")
local plr = Players:GetPlayerFromCharacter(char)

local wait = task.wait


repeat wait() until char:GetAttribute("Haruka_CharServerInited")

local Add, Empty = HarukaLib.Bin()


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		CriRPGLib:Destroy()
	end
end))
Add(script.Destroying:Connect(function()
    CriRPGLib:Destroy()
end))



function CriRPGLib:Init()
    Add(char.Humanoid.HealthChanged:Connect(function(health: number)
		if health <= 0 then
			self:Destroy()
		end
	end))
	Add(char.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
		local newParent = char
        if newParent then
            if newParent.PrimaryPart == nil and not newParent:FindFirstChild("Humanoid") then
                self:Destroy()
                return
            end
        else
            self:Destroy()
        end
	end))


    self:_InitAttrs()
    self:_SpawnToLastLocation()

    for funcId: string, func: (self) -> nil in CriRPGLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            task.spawn(func, self)
        end
    end

    self:_AutoEquipItems()


    char:SetAttribute("_CharDataInited", true)
    char:AddTag("PlayerCharEntity")
end



function CriRPGLib:Destroy()
    Empty()
end



--// Private methods


function CriRPGLib:_SpawnToLastLocation()
    local lastLocation = plr:GetAttribute("LastSeen") :: string
    local map = workspace.Maps:FindFirstChild(lastLocation, true) :: Folder

    local baseSpawn = workspace.Maps:FindFirstChildWhichIsA("SpawnLocation", true)

    char:PivotTo(baseSpawn.CFrame * CFrame.new(0, 5.99, 0))

    if not map then return end
    local spawnPoints = map:FindFirstChild("SpawnPoints") :: Configuration

    if not spawnPoints then return end
    local rSpawnPoint = spawnPoints:GetChildren()[math.random(1, #spawnPoints:GetChildren())]


    char:PivotTo(rSpawnPoint.CFrame * CFrame.new(0, 5.99, 0))
end


function CriRPGLib:_InitAttrs()
    for attr: string, val: any in table.clone(CharTemplate) do
        if typeof(val) == "table" then
            local folder = Instance.new("Folder")
            folder.Name = attr
            folder.Parent = char
            continue
        end
        if val == "_OBJECT" then
            local objVal = Instance.new("ObjectValue")
            objVal.Name = attr
            objVal.Value = nil
            objVal.Parent = char
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

        ServerLib:EquipItem(plr, item:GetAttribute("HarukaUniqueId"))
    end
    for _, item: IntConstrainedValue in plr.Items:GetChildren() do
        local itemInfo = ItemLib:GetItemInfo(item.Name)
        if not itemInfo then continue end

        if itemInfo.Type == "Passive" then
            ServerLib:EquipItem(plr, item:GetAttribute("HarukaUniqueId"))
        end
    end
end





function CriRPGLib:_ListenLightTracker()
    local light = Instance.new("PointLight")
    light.Range = 32
    light.Brightness = 3
    light.Color = Color3.fromHex('#f1c40f')
    light.Shadows = false
    light.Parent = char.PrimaryPart

    Add(HarukaLib:Hydrate(char, {
        ["Attr-CanYellowLight"] = function(state: boolean)
            light.Enabled = state or false
        end
    }))
end


function CriRPGLib:_ListenClassTracker()
	local function _equipWeapon()
		for _, weapon: Model in char:GetChildren() do
			if weapon:HasTag("ClassWeapon") then weapon:Destroy() end
		end

        local combatState = char:GetAttribute("IsInCombat") or false
        local class = plr:GetAttribute("Class") or "Burst"
        local targetFolder = if combatState then "Combat" else "Overworld"
        local weaponId = plr.EquippingItems.Weapon1.Value :: string

        if not ReplicatedStorage.Packages.ClassWeapons:FindFirstChild(class) then return end
        if not ReplicatedStorage.Packages.ClassWeapons[class]:FindFirstChild(weaponId) then return end
        if not ReplicatedStorage.Packages.ClassWeapons[class][weaponId]:FindFirstChild(targetFolder) then return end


		for _, weapon: Model in ReplicatedStorage.Packages.ClassWeapons[class][weaponId][targetFolder]:GetChildren() do
			weapon = weapon:Clone()
			weapon:AddTag("ClassWeapon")

			ServerLib:WeldWeapon(weapon, char)
		end
	end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-IsInCombat"] = _equipWeapon
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-Class"] = _equipWeapon
    }))
    Add(HarukaLib:Hydrate(plr.EquippingItems.Weapon1, {
        ["Prop-Value"] = _equipWeapon
    }))

    _equipWeapon()
end



function CriRPGLib:_ListenOrbTracker()

    local plr = plr :: Player
    local orbResContainer = ReplicatedStorage.Packages.ClassAttacks :: Folder

    local orbSymbolContainer = Instance.new("Folder")
    orbSymbolContainer.Name = "OrbSymbols_"..char:GetAttribute("HarukaUniqueId")
    orbSymbolContainer.Parent = ServerStorage.OrbSymbolContainer
    Add(orbSymbolContainer)


    local orbSpawnAdd, orbSpawnEmpty = HarukaLib.Bin()
    local function _spawnOrb_done(orbName: string, extraProps: {
        Offset: Vector3,
        ForceLocation: CFrame
    })
        local enemy = char.TargetingEnemy.Value :: Model

        extraProps = extraProps or {}

        if ServerLib:IsCharValid(enemy) and char.Humanoid.Health > 0 then
            local orb = orbResContainer:FindFirstChild(orbName, true) :: Model
            if not orb then
                warn("Invalid Orb Id: "..orbName)
                return
            end

            local orbUniqueId = HttpService:GenerateGUID(false)
            local orbPos = extraProps.ForceLocation or ServerLib:GenerateOrbPos(char:GetAttribute("CombatLocation"))
            local orbFadeTime = char:GetAttribute("OrbFadeTime") or 12 :: number

            if orbName == "BuffOrb" or orbName == "HealOrb" then
                orbFadeTime = 8
            end
            if extraProps.Offset then
                orbPos *= CFrame.new(extraProps.Offset)
            end

            local symbol = Instance.new("CFrameValue")
            symbol.Name = orbUniqueId
            symbol.Value = orbPos

            symbol:SetAttribute("OrbStyle", orb:GetAttribute("Style"))
            symbol:SetAttribute("OrbSubStyle", orb:GetAttribute("SubStyle"))
            symbol:SetAttribute("OrbId", orb.Name)
            symbol:SetAttribute("Owner", char.Name)

            symbol.Parent = orbSymbolContainer
            Maid:AddItem(symbol, orbFadeTime + 5)


            Events.PlaceOrb.Fire(plr, {
                OrbId = orb.Name,
                OrbUniqueId = orbUniqueId,
                OrbDuration = orbFadeTime,
                OrbLocationPos = orbPos.Position
            })
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
    local function _spawnBuffOrb()
        local resultOrb, _, _ = HarukaLib:RollLoot({
            ["HealOrb"] = 22,
            ["None"] = 23 + 55
        })
        if resultOrb == "HealOrb" then _spawnOrb_done("HealOrb") end
    end
    local function orbSpawnHandler(state: boolean)
        if state then
            orbSpawnEmpty()

            local orbSpawnTimesAtStart = char:GetAttribute("OrbSpawnTimesAtStart") or 1
            local orbSpawnTime = char:GetAttribute("OrbSpawnTime") or 3

            orbSpawnAdd(task.delay(1, function()
                for _ = 1, orbSpawnTimesAtStart do _spawnOrb() end
            end))
            orbSpawnAdd(HarukaLib.Clock(orbSpawnTime, function()
                if char:GetAttribute("IsInCombat") then _spawnOrb() end
            end))
            orbSpawnAdd(HarukaLib.Clock(8, function()
                if char:GetAttribute("IsInCombat") then _spawnBuffOrb() end
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
        Offset: Vector3,
        ForceLocation: CFrame
    })
        if charId ~= char.Name then return end

        _spawnOrb_done(orbName, extraProps)
    end))

    orbSpawnEmpty()
end



function CriRPGLib:_ListenSkillProjectileTracker()
    local projectileContainer = Instance.new("Folder")
    projectileContainer.Name = "SkillProjectiles_"..char:GetAttribute("HarukaUniqueId")
    projectileContainer.Parent = ServerStorage.SkillProjectileContainer
    Add(projectileContainer)


    Add(ServerBindables.RToCreateProjectileSymbol:Connect(function(charId: string, props: {
        ProjectileId: string,
        ProjectileType: "OneTime" | "OverTime",
        Duration: number,
        ProjectileUniqueId: string,
        DMGType: string,
        DoTType: string
    })
        if charId ~= char.Name then return end


        local symbol = Instance.new("StringValue")
        symbol.Name = props.ProjectileUniqueId
        symbol.Value = props.ProjectileId

        symbol:SetAttribute("DMGType", props.DMGType)
        symbol:SetAttribute("ProjectileType", props.ProjectileType)
        symbol:SetAttribute("Owner", charId)
        symbol:SetAttribute("DoTType", props.DoTType)

        symbol.Parent = projectileContainer
        Maid:AddItem(symbol, props.Duration)
    end))
end


function CriRPGLib:_ListenPlayerLevelTracker()
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-EXP"] = function(exp: number)
            local level = plr:GetAttribute("Level") :: number
            if not level then return end

            local totalLevelShouldGive = 0
            local maxEXPGained = 0

            while exp >= maxEXPGained do
                maxEXPGained += FormulaBook.PlayerLevelCurveCal({
                    Level = level + totalLevelShouldGive
                })

                if exp >= maxEXPGained then
                    totalLevelShouldGive += 1
                else
                    maxEXPGained -= FormulaBook.PlayerLevelCurveCal({
                        Level = level + totalLevelShouldGive
                    })
                    break
                end
                RunService.Stepped:Wait()
            end
            if totalLevelShouldGive > 0 then
                if plr:GetAttribute("Level") + totalLevelShouldGive > FormulaBook.PLAYER_MAX_LEVEL then
                    totalLevelShouldGive = FormulaBook.PLAYER_MAX_LEVEL - plr:GetAttribute("Level")

                    Events.CreateNotify.Fire(plr, "You've reached the maximum level!")
                end
                if totalLevelShouldGive <= 0 then
                    plr:SetAttribute("EXP", 0)
                    return
                end

                HarukaLib:AddAttr(plr, "Level", totalLevelShouldGive)
                HarukaLib:AddAttr(plr, "EXP", -maxEXPGained)
                HarukaLib:AddAttr(plr, "PerkPoints", FormulaBook.PLAYER_POINT_PER_LEVEL * totalLevelShouldGive)

                Events.PlaySound.Fire(plr, SoundService.SFXs.LevelUp)

                ServerLib:ShowText(char, "LEVEL UP!", Color3.fromHex('#ffeaa7'))


                local levelUpEffect = ReplicatedStorage.Packages.Effects.LevelUpEffect.Attachment:Clone() :: Attachment
		        levelUpEffect.Parent = char.PrimaryPart
		        Debris:AddItem(levelUpEffect, 1)


                char:SetAttribute("Shield", char:GetAttribute("MaxShield"))
                char.Humanoid.Health = char.Humanoid.MaxHealth
            end
        end,
        ["Attr-Level"] = function(level: number)
            if level == nil then return end


            if level > FormulaBook.PLAYER_MAX_LEVEL then
                plr:SetAttribute("Level", FormulaBook.PLAYER_MAX_LEVEL)

                Events.CreateNotify.Fire(plr, "You've reached the maximum level!")
            end
        end
    }))
end




function CriRPGLib:_ListenStatsTracker()
    --- class base
    local function _updateClassBase(class: string)
        if not class then return end

        for attr: string, val: any in table.clone(CharTemplate) do
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

        local final = finalSpeed * speedExBuff + speedBuff

        char.Humanoid.WalkSpeed = final
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-SpeedEx"] = _updateSpeed,
        ["Attr-SpeedExPower"] = _updateSpeed,
        ["Attr-IsInCombat"] = _updateSpeed
    }))



    local function _updateJump()
        local jumpBuff = char:GetAttribute("JumpPowerEx") :: number
        local jumpExBuff = char:GetAttribute("JumpPowerExPower") :: number
        local baseJump = char:GetAttribute("BaseJumpPower") :: number

        local final = baseJump * jumpExBuff + jumpBuff

        char.Humanoid.JumpPower = final
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-JumpEx"] = _updateJump,
        ["Attr-JumpExPower"] = _updateJump
    }))



    local function _updateMinDMG()
        local baseMinDMG = char:GetAttribute("BaseMinDMG") :: number
        local minDMGBuff = char:GetAttribute("MinDMGEx") :: number
        local minDMGExBuff = char:GetAttribute("MinDMGExPower") :: number

        baseMinDMG = FormulaBook.PlayerDMGCurveCal({
            BaseDMG = baseMinDMG,
            DMGPoints = plr:GetAttribute("STRPoints")
        })

        char:SetAttribute("MinDMG", math.ceil(baseMinDMG * minDMGExBuff + minDMGBuff))
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

        char:SetAttribute("MaxDMG", math.ceil(baseMaxDMG * maxDMGExBuff + maxDMGBuff))
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

        char:SetAttribute("Magic", math.ceil(baseMagic * magicExBuff + magicBuff))
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


        char.Humanoid.MaxHealth = math.ceil(FormulaBook.PlayerHealthCurveCal({
            BaseHealth = baseHealth,
            HealthPoints = plr:GetAttribute("VITPoints")

        }) * healthExBuff + healthBuff)


        if DateTime.now().UnixTimestamp - char:GetAttribute("SpawnClock") < 5 then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
        if char.Humanoid.Health > char.Humanoid.MaxHealth then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
    end
    Add(HarukaLib:Hydrate(char, {
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


        baseShield = FormulaBook.PlayerShieldCurveCal({
            BaseShield = baseShield,
            Level = plr:GetAttribute("Level"),
        })

        char:SetAttribute("MaxShield", math.ceil(baseShield * shieldExBuff + shieldBuff))


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
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-Level"] = _updateShield,
    }))



    local function _hpCheck()
        if char.Humanoid.Health > char.Humanoid.MaxHealth then
            char.Humanoid.Health = char.Humanoid.MaxHealth
        end
    end
    Add(HarukaLib:Hydrate(char.Humanoid, {
        ["Prop-Health"] = _hpCheck
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
        ["Attr-Shield"] = _shieldCheck
    }))



    local function _updateMana()
        local baseMana = char:GetAttribute("BaseMaxMana") :: number
        local mpBuff = char:GetAttribute("MaxManaEx") :: number
        local mpExBuff = char:GetAttribute("MaxManaExPower") :: number


        baseMana = FormulaBook.PlayerManaCurveCal({
            BaseMana = baseMana,
            ManaPoints = plr:GetAttribute("INTPoints")
        })

        char:SetAttribute("MaxMana", math.ceil(baseMana * mpExBuff + mpBuff))

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
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-ManaPoints"] = _updateMana,
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
        ["Attr-Mana"] = _manaCheck
    }))


    local function _updateCriChance()
        local baseCritChance = char:GetAttribute("BaseCriChance") :: number
        local critChanceBuff = char:GetAttribute("CriChanceEx") :: number
        local critChanceExBuff = char:GetAttribute("CriChanceExPower") :: number

        local final = FormulaBook.PlayerCriChanceCurveCal({
            BaseCritChance = baseCritChance,
            DexPoints = plr:GetAttribute("DEXPoints")
        })

        char:SetAttribute("CriChance", math.floor(final * critChanceExBuff + critChanceBuff))
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseCriChance"] = _updateCriChance,
        ["Attr-CriChanceEx"] = _updateCriChance,
        ["Attr-CriChanceExPower"] = _updateCriChance,
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-DEXPoints"] = _updateCriChance,
    }))


    local function _updateDodgeChance()
        local baseDodgeChance = char:GetAttribute("BaseDodgeChance") :: number
        local dodgeChanceBuff = char:GetAttribute("DodgeChanceEx") :: number
        local dodgeChanceExBuff = char:GetAttribute("DodgeChanceExPower") :: number

        local final = FormulaBook.PlayerDodgeChanceCurveCal({
            BaseDodgeChance = baseDodgeChance,
            DexPoints = plr:GetAttribute("DEXPoints")
        })

        char:SetAttribute("DodgeChance", math.floor(final * dodgeChanceExBuff + dodgeChanceBuff))
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-BaseDodgeChance"] = _updateDodgeChance,
        ["Attr-DodgeChanceEx"] = _updateDodgeChance,
        ["Attr-DodgeChanceExPower"] = _updateDodgeChance,
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-DEXPoints"] = _updateDodgeChance,
    }))







    --// track rest stats
    local blackList = {
        "BaseMagic", "BaseMinDMG", "BaseMaxDMG", "BaseSpeed", "BaseSpeedCombat",
        "BaseJumpPower", "BaseMaxShield", "BaseMaxMana",
        "BaseCriChance", "BaseDodgeChance"
    }
    for stat: string, _ in table.clone(CharTemplate) do
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

            char:SetAttribute(statWithoutBase, math.ceil(base * exPower + ex))
        end
        Add(HarukaLib:Hydrate(char, {
            ["Attr-"..stat] = __track,
            ["Attr-"..statWithoutBase.."Ex"] = __track,
            ["Attr-"..statWithoutBase.."ExPower"] = __track
        }))
    end
end



function CriRPGLib:_ListenStatLimitTracker()
    local totalBin = {}


    local function __trackWhichStat(statAttr: string, withoutSub: boolean?)
        local attr = statAttr
        if not withoutSub then
            attr = string.sub(statAttr, 5)
        end
        if char:GetAttribute(statAttr) == nil then
            warn("Invalid base stat: "..statAttr)
            return
        end
        if CharLimitsTemplate[attr.."Min"] == nil or CharLimitsTemplate[attr.."Max"] == nil then
            warn("Invalid limit stat: "..attr)
            return
        end

        local function __track()
            local base = char:GetAttribute(statAttr) :: any
            local limitMin = CharLimitsTemplate[attr.."Min"] :: number
            local limitMax = CharLimitsTemplate[attr.."Max"] :: number


            if base < limitMin then
                char:SetAttribute(statAttr, limitMin)
            end
            if base > limitMax then
                char:SetAttribute(statAttr, limitMax)
            end
        end
        totalBin["Attr-"..statAttr] = __track
    end


    local blackList = { "BaseSpeed", "BaseJumpPower", "BaseSpeedCombat" }
    for attr: string, _ in char:GetAttributes() do
        if table.find(blackList, attr) then continue end
        if string.find(attr, "Base") then
            __trackWhichStat(attr)
            __trackWhichStat(string.sub(attr, 5), true)
        end
    end

    Add(HarukaLib:Hydrate(char, totalBin))
end


function CriRPGLib:_ListenHealTracker()
    local healAdd, healEmpty = HarukaLib.Bin()
    Add(healEmpty)


    local function _healthRecover()
        healEmpty()

        char:SetAttribute("IsHPRecovering", false)


        healAdd(task.spawn(function()
            local waitTime = char:GetAttribute("HealthRegenWaitTime") or 15

            wait(waitTime)
            while wait(0.35) do
                if char.Humanoid.Health <= 0
                    or char.Humanoid.Health >= char.Humanoid.MaxHealth then

                    char:SetAttribute("IsHPRecovering", false)
                    break
                end

                char:SetAttribute("IsHPRecovering", true)
                char.Humanoid.Health += math.ceil(char.Humanoid.MaxHealth * 0.01)
            end
        end))
    end
    Add(ServerBindables.PlayerGotHit:Connect(function(charId: string, _, part: string)
        if charId ~= char.Name then return end
        if part == "Health" then _healthRecover() end
    end))
    Add(HarukaLib:Hydrate(char.Humanoid, {
        ["Prop-MaxHealth"] = _healthRecover
    }))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-VITPoints"] = _healthRecover,
    }))
end


function CriRPGLib:_ListenShieldRepairTracker()


    local repairAdd, repairEmpty = HarukaLib.Bin()
    Add(repairEmpty)


    local function _shieldRecover()
        repairEmpty()

        char:SetAttribute("IsShieldRepairing", false)


        repairAdd(task.spawn(function()
            local waitTime = char:GetAttribute("ShieldRegenWaitTime") or 10

            wait(waitTime)
            while wait(0.15) do
                if char:GetAttribute("Shield") >= char:GetAttribute("MaxShield") then
                    char:SetAttribute("IsShieldRepairing", false)
                    break
                end

                char:SetAttribute("IsShieldRepairing", true)
                HarukaLib:AddAttr(char, "Shield", math.ceil(char:GetAttribute("MaxShield") * 0.01))
            end
        end))
    end
    Add(HarukaLib:Hydrate(char, {
        ["Attr-MaxShield"] = _shieldRecover,
    }))
    Add(ServerBindables.PlayerGotHit:Connect(function(charId: string, _, part: string)
        if charId ~= char.Name then return end
        if part == "Shield" then _shieldRecover() end
    end))
    Add(HarukaLib:Hydrate(plr, {
        ["Attr-Level"] = _shieldRecover
    }))
end


function CriRPGLib:_ListenClassChangeTracker()
    Add(HarukaLib:Hydrate(plr.EquippingItems.Weapon1, {
        ["Prop-Value"] = function(weapon: string)
            weapon = weapon or ""

            if not ItemLib:GetItemInfo(weapon) then return end

            local class = ItemLib:GetItemInfo(weapon).StatInfoDesync.ForClass :: string
            plr:SetAttribute("Class", class)
        end
    }))
end


function CriRPGLib:_ListenPassiveAutoEquipTracker()
    Add(plr.Items.ChildAdded:Connect(function(item: IntConstrainedValue)
        local itemInfo = ItemLib:GetItemInfo(item.Name)
        if not itemInfo then return end

        if itemInfo.Type == "Passive" then
            ServerLib:EquipItem(plr, item:GetAttribute("HarukaUniqueId"))
        end
    end))
end


function CriRPGLib:_ListenPlayerAutoPerkEquipTracker()
    local perkContainer = Instance.new("Folder")
    perkContainer.Name = "Perks"
    perkContainer.Parent = char
    Add(perkContainer)

    local points = { "STR", "INT", "VIT", "DEX" }
    for _, pointId: string in points do
        local folder = Instance.new("Folder")
        folder.Name = pointId
        folder.Parent = perkContainer
    end


    local function _listenToPerk(id: string, point: number)
        local passed = {}
        for _, perkInfo in PerkBook[id] do
            if point >= perkInfo.Req then
                table.insert(passed, perkInfo.Id)
            end
        end
        for _, perk: BoolValue in perkContainer[id]:GetChildren() do
            if not table.find(passed, perk.Name) then
                if PerkLib[perk.Name] then
                    PerkLib[perk.Name](char, -1)
                end
                perk:Destroy()
            end
        end
        for _, perkId: string in passed do
            if perkContainer[id]:FindFirstChild(perkId) then continue end

            local perk = Instance.new("BoolValue")
            perk.Name = perkId
            perk.Value = true
            perk.Parent = perkContainer[id]

            if PerkLib[perk.Name] then
                PerkLib[perk.Name](char, 1)
            end
        end
    end


    Add(HarukaLib:Hydrate(plr, {
        ["Attr-STRPoints"] = function(point: number)
            if point == nil then return end

            --// TODO: perks
            --_listenToPerk("STR", point)
        end
    }))
end


CriRPGLib:Init()


Add(char.TargetingList.ChildAdded:Connect(function(child: ObjectValue)
	ServerBindables.PlayerTargetingListChanged:Fire(char.Name, child.Value)
end))
Add(HarukaLib.Clock(5, function()
    if not char:GetAttribute("IsInCombat") then return end


	for _, obj: ObjectValue in char.TargetingList:GetChildren() do
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
		ServerBindables.PlayerCombatEnded:Fire(char.Name)
	end
end))
Add(ServerBindables.PlayerCombatEnded:Connect(function(charId: string)
	if charId == char.Name then
		char.TargetingEnemy.Value = nil

		char:SetAttribute("CombatLocation", nil)
		char:SetAttribute("IsInCombat", false)


		local cooldown = Instance.new("BoolValue")
		cooldown.Name = "CombatCooldown"
		cooldown.Value = true
		cooldown.Parent = char
		Debris:AddItem(cooldown, 1)
	end
end))
