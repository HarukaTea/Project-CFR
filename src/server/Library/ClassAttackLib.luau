
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local StatusLib = require(SSS.HarukaServer.Library.StatusLib)
local DoTLib = require(SSS.HarukaServer.Services.DoTLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)

type Dict = { [string]: any }

local wait = task.wait

export type ClassAttackLibClass = {
    [string]: (plr: Player, symbolAttrs: Dict) -> nil,

    CalDMG: (self: ClassAttackLibClass, dmgType: "DMG" | "Magic", char: Model, props: {
        ForceMaxDMG: boolean?,
        ForceDMG: number?,
    }?) -> number,
    DealDamageToEnemy: (self: ClassAttackLibClass, char: Model, target: Model, dmgProps: {
        DMG: number,
        DMGType: "DMG" | "Magic",
        Attacker: string
    }) -> nil,
    CalCastingTime: (self: ClassAttackLibClass, char: Model, castingTime: number) -> number,
    CalRESBreak: (self: ClassAttackLibClass, char: Model, amount: number) -> number,

    _AddClassUltCharge: (plr: Player, amount: number) -> nil,
}

local ClassAttackLib = {} :: ClassAttackLibClass

--// Helper functions

local function _getCharAndTargeting(plr: Player) : (Model?, Model?)
    return plr.Character, plr.Character.TargetingEnemy.Value
end
local function _charAndTargetingCheck(char: Model, targeting: Model) : boolean
    if char == nil or targeting == nil then return false end
    if not ServerLib:IsCharValid(char) then return false end
    if not ServerLib:IsCharValid(targeting) then return false end

    return true
end
local function _addClassUltCharge(plr: Player, amount: number)
    StatusLib:ChargeClassUlt(plr.Character, amount)
end
local function _fireClassUltCasted(char: Model, props: {
    ClassId: string,
    DMGType: "DMG" | "Magic",
    Target: Model
})
    for _, event in char:QueryDescendants("BindableEvent#PlayerClassUltCasted") do
        RunService.Heartbeat:Wait()
        event:Fire(char, props)
    end
end
local function _damageDealMiddler(char: Model, targeting: Model, dmgProps: {
    DMG: number,
    DMGType: string,
    Attacker: string
}) : number
    local dmg = dmgProps.DMG

    --// blood spellbook bonus
    if dmgProps.Attacker == "ClassAttacks" and char:GetAttribute("BloodSpellbookBonus") then
        dmg = math.ceil(dmg * 1.3)
    end

    --// class ult dmg bonus
    if dmgProps.Attacker == "ClassUltProjectile" then
        dmg = math.ceil(dmg * (char:GetAttribute("ClassUltDMGBonus") or 100) / 100)
    end

    --// forest dweller dmg bonus
    if char:GetAttribute("ForestDweller3Bonus") then
        dmg = math.ceil(dmg * 1.3)
    end

    --// enemy dmg taken bonus
    local dmgTakenBonus = targeting:GetAttribute("DMGTakenBonus") or 100
    dmg = math.ceil(dmg * dmgTakenBonus / 100)

    --// class level
    local plr = Players:GetPlayerFromCharacter(char)
    local class = plr:GetAttribute("Class") or "Chain"
    local classLevel = plr:GetAttribute("ClassLevel_"..class) or 1

    dmg = math.ceil(dmg * ((100 + classLevel * 2) / 100))

    return dmg
end
ClassAttackLib._AddClassUltCharge = _addClassUltCharge

local function _castUltPromiseUtil(func1: () -> nil, func2: () -> nil)
    func1()
    Promise.delay(1):andThen(func2):catch(function() end)
end
local function _addIFrame(char: Model)
    local iFrameSymbol = Instance.new("BoolValue")
    iFrameSymbol.Name = "IFrameSymbol"
    iFrameSymbol.Value = true
    iFrameSymbol.Parent = char

    Debris:AddItem(iFrameSymbol, 3)

    ServerLib:ShowText(char, "IFRAME!")
end
local function _getNearbyPlayers(char: Model) : { Player }
    return ServerLib:GetNearbyPlayers(char.PrimaryPart.Position)
end
local function _classUltCastedEff(props: {
    Char: Model,
    Targeting: Model,
    Class: string,
    Player: Player
})
    local char = props.Char
    local targeting = props.Targeting
    local class = props.Class
    local plr = props.Player

    _fireClassUltCasted(char, {
        ClassId = class,
        DMGType = ClassBook[class].Type,
        Target = targeting
    })
    _addIFrame(char)

    Events.PlayVFXStatusToPlayer_S.FireList(_getNearbyPlayers(char), {
        Character = char,
        StatusId = "ClassUltEffect"
    })
    Events.PlayStatPoweredScreenFX_S.Fire(plr)
    Events.PlayVFXStatusToPlayer_S.FireList(_getNearbyPlayers(char), {
        Character = char,
        StatusId = "UltHighlight"
    })

    Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.FaceTargetingEnemy_S.Fire(plr)
end
local function _restoreMana(char: Model)
    local mana = char:GetAttribute("Mana") or 0
    local maxMana = char:GetAttribute("MaxMana") or 0

    if mana >= maxMana then return end
    StatusLib:RestoreManaPercentage(char, 20)
end

--// Universal

--// Class-specific

ClassAttackLib.Chain = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _addClassUltCharge(plr, 15)
    _restoreMana(char)

    HarukaLib:AddAttr(char, "ChainCombo", 1)

    Events.PlayVFXStatusToPlayer_S.FireList(_getNearbyPlayers(char), {
        Character = char,
        StatusId = "SwordSlash"
    })

    local combo = char:GetAttribute("ChainCombo") :: number

    if combo >= 2 then
        ClassAttackLib:DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib:CalDMG("DMG", char) * combo),
            DMGType = "DMG",
            Attacker = "ClassAttacks"
        })

        ServerLib.ShowText(char, "COMBO!", ClassBook.Chain.Color)
    else
        ClassAttackLib:DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib:CalDMG("DMG", char),
            DMGType = "DMG",
            Attacker = "ClassAttacks"
        })
    end
end
ClassAttackLib.Chain_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _castUltPromiseUtil(function()
        Events.OpenCastTimeBar_S.Fire(plr, 1)
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    end, function()
        char, targeting = _getCharAndTargeting(plr)

        _classUltCastedEff({
            Char = char,
            Player = plr,
            Targeting = targeting,
            Class = "Chain"
        })

        Events.PlayClassAnim_S.Fire(plr, "ChainUltSlashAttack1")

        local function _slash()
            char, targeting = _getCharAndTargeting(plr)

            Events.PlayVFXStatusToPlayer_S.FireList(_getNearbyPlayers(char), {
                Character = char,
                StatusId = "SwordSlash"
            })
            wait(0.15)
            Events.PlayVFXStatusToPlayer_S.FireList(_getNearbyPlayers(char), {
                Character = char,
                StatusId = "SwordPierce"
            })
            Events.PlaySound_S.Fire(plr, SoundService.SFXs.OrbHit)

            ClassAttackLib:DealDamageToEnemy(char, targeting, {
                Attacker = "ClassUlt",
                DMG = math.ceil(ClassAttackLib:CalDMG("DMG", char) * 1.5),
                DMGType = "DMG"
            })
        end

        Promise.delay(0.17):andThen(_slash):catch(function() end)
        Promise.delay(0.5):andThen(_slash):catch(function() end)
        Promise.delay(1):andThen(_slash):catch(function() end)
        Promise.delay(1.4):andThen(_slash):catch(function() end)

        Promise.delay(2.06):andThen(function()
            _slash()

            Events.PlayVFXScene_S.FireList(_getNearbyPlayers(char), {
                Caster = char,
                ProjectileUniqueId = "1599mkk40",
                SceneId = "ChainUltExplosion"
            })
            Events.PlaySound_S.Fire(plr, SoundService.SFXs.FireExplosionCharge)

            ClassAttackLib:DealDamageToEnemy(char, targeting, {
                Attacker = "ClassUlt",
                DMG = math.ceil(ClassAttackLib:CalDMG("DMG", char) * 2),
                DMGType = "DMG"
            })
        end):catch(function() end)
    end)
end

ClassAttackLib.Burst = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _addClassUltCharge(plr, 15)
    _restoreMana(char)

    Events.PlayVFXScene_S.FireList(_getNearbyPlayers(char), {
        Caster = char,
        ProjectileUniqueId = "1599mkk40",
        SceneId = "BurstArrowShot"
    })

    local now = DateTime.now().UnixTimestamp
	local arrowCount = char:GetAttribute("BurstArrow") or 0
    local lastBurst = char:GetAttribute("LastBurstTime") or 0
	local piercingCount = char:GetAttribute("BurstArrowPiercing") or 0

    local consumeNormal = 0
	local consumePiercing = 0
    if not char:FindFirstChild("IsInBurstUltPeriod") then
        if piercingCount > 0 and arrowCount > 0 then
            consumePiercing = 1
            consumeNormal = 1

        elseif (now - lastBurst) > 2 then
            consumeNormal = math.min(1, arrowCount)
        else
            consumeNormal = math.min(2, arrowCount)
        end
    else
        if piercingCount > 0 and arrowCount > 0 then
            consumePiercing = 1
            consumeNormal = math.clamp(arrowCount, 1, 2)

        elseif (now - lastBurst) > 2 then
            consumeNormal = math.min(1, arrowCount)
            if piercingCount > 0 then
                consumePiercing = 1
            end
        else
            consumeNormal = math.min(3, arrowCount)
        end
    end

    local totalConsumed = consumeNormal + consumePiercing

	if totalConsumed <= 0 then
		ClassAttackLib:DealDamageToEnemy(char, targeting, {
			DMG = ClassAttackLib:CalDMG("DMG", char),
			DMGType = "DMG",
			Attacker = "ClassAttacks"
		})
		return
	end

	local baseDMG = ClassAttackLib:CalDMG("DMG", char)
	local totalDMG = math.ceil(baseDMG * (1 + 1 * arrowCount + 2 * piercingCount))

	ClassAttackLib:DealDamageToEnemy(char, targeting, {
		DMG = totalDMG,
		DMGType = "DMG",
		Attacker = "ClassAttacks"
	})

    char:SetAttribute("BurstArrow", math.max(arrowCount - consumeNormal, 0))
	char:SetAttribute("BurstArrowPiercing", math.max(piercingCount - consumePiercing, 0))
	char:SetAttribute("LastBurstTime", now)
end
ClassAttackLib.Burst_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _castUltPromiseUtil(function()
        Events.OpenCastTimeBar_S.Fire(plr, 1)
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    end, function()
        char, targeting = _getCharAndTargeting(plr)

        _classUltCastedEff({
            Char = char,
            Player = plr,
            Targeting = targeting,
            Class = "Burst"
        })

        local ultPeriodSymbol = Instance.new("BoolValue")
        ultPeriodSymbol.Name = "IsInBurstUltPeriod"
        ultPeriodSymbol.Value = true
        ultPeriodSymbol.Parent = char
        Debris:AddItem(ultPeriodSymbol, 8)

        StatusLib:CreateCustomStatus("BurstUlt", char, {
            Duration = 8
        })

        local linearVelocity = Instance.new("LinearVelocity")
        linearVelocity.Name = "ExtraUpBV"
        linearVelocity.Attachment0 = char.PrimaryPart.CF_RootNode
        linearVelocity.ForceLimitsEnabled = false
        linearVelocity.VectorVelocity = char.PrimaryPart.CFrame.LookVector + Vector3.yAxis * 50 * 1.8
        linearVelocity.Parent = char.PrimaryPart
        Debris:AddItem(linearVelocity, 0.05)

        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.PlayVFXScene_S.FireList(_getNearbyPlayers(char), {
            SceneId = "ChainJump",
            Caster = char,
            ProjectileUniqueId = "nil"
        })
        Events.PlayClassAnim_S.Fire(plr, "BurstSpinAttack")
        Events.PlayVFXScene_S.FireList(_getNearbyPlayers(char), {
            SceneId = "BurstArrowsSplit",
            Caster = char,
            ProjectileUniqueId = "nil"
        })

        Promise.delay(0.9):andThen(function()
            char, targeting = _getCharAndTargeting(plr)

            for _ = 1, 3 do
                ClassAttackLib:DealDamageToEnemy(char, targeting, {
                    DMG = ClassAttackLib:CalDMG("DMG", char),
                    DMGType = "DMG",
                    Attacker = "SkillProjectile"
                })
                task.wait(0.05)
            end
        end):catch(function() end)
    end)
end
ClassAttackLib.Burst_BurstArrow = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    local isUlt = char:FindFirstChild("IsInBurstUltPeriod") ~= nil
    local gain = if isUlt then 2 else 1

    local now = DateTime.now().UnixTimestamp
    local arrowCount = math.clamp( (char:GetAttribute("BurstArrow") or 0) + gain, 0, 12)
    local arrowPiercingCount = char:GetAttribute("BurstArrowPiercing") or 0

    local firstTick = char:GetAttribute("BurstArrowTick1") or 0
    local comboCount = char:GetAttribute("BurstArrowCombo") or 0

    if firstTick == 0 or (now - firstTick) > 5 then
        firstTick = now
        comboCount = 1
    else
        comboCount += 1
    end

    if comboCount >= 3 then
        arrowPiercingCount = math.clamp(arrowPiercingCount + 1, 0, 4)
        firstTick = 0
        comboCount = 0
    end

    char:SetAttribute("BurstArrow", arrowCount)
    char:SetAttribute("BurstArrowPiercing", arrowPiercingCount)
    char:SetAttribute("BurstArrowTick1", firstTick)
    char:SetAttribute("BurstArrowCombo", comboCount)
end

ClassAttackLib.Flow = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _addClassUltCharge(plr, 15)
    _restoreMana(char)

    Events.PlayVFXScene_S.FireList(_getNearbyPlayers(char), {
        Caster = char,
        ProjectileUniqueId = "1599mkk40",
        SceneId = "FlowballShot"
    })

    local marked = char:GetAttribute("FlowMark") or 0
    marked += 1
    marked = math.clamp(marked, 0, 3)
    char:SetAttribute("FlowMark", marked)

    if marked < 3 then
        ClassAttackLib:DealDamageToEnemy(char, targeting, {
            Attacker = "ClassAttacks",
            DMG = ClassAttackLib:CalDMG("Magic", char),
            DMGType = "Magic"
        })
    else
        char:SetAttribute("FlowMark", 0)

        local dmg = ClassAttackLib:CalDMG("Magic", char)

        ClassAttackLib:DealDamageToEnemy(char, targeting, {
            Attacker = "ClassAttacks",
            DMG = math.ceil(dmg * 4),
            DMGType = "Magic"
        })

        local burnDebuff = DoTLib.new({
            Target = targeting,
            Type = "Burn",
            Creator = char,
            Power = 1,
            Duration = 8
        })
        burnDebuff:Activate()
    end
end
ClassAttackLib.Flow_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _castUltPromiseUtil(function()
        Events.OpenCastTimeBar_S.Fire(plr, 1)
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    end, function()
        char, targeting = _getCharAndTargeting(plr)

        _classUltCastedEff({
            Char = char,
            Player = plr,
            Targeting = targeting,
            Class = "Flow"
        })

        local uniqueId = HttpService:GenerateGUID(false)

        ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
            ProjectileId = "FireballSpell",
            Duration = 3,
            ProjectileType = "OneTime",
            ProjectileUniqueId = uniqueId,
            DMGType = "Magic",
            DoTType = "Burn",
            DMGBonus = 1,
            IsClassUlt = true
        })
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.PlayClassAnim_S.Fire(plr, "MagicCasted1")
        Events.FaceTargetingEnemy_S.Fire(plr)

        Events.PlayVFXScene_S.FireList(_getNearbyPlayers(char), {
            SceneId = "FireballSpell",
            Caster = char,
            ProjectileUniqueId = uniqueId,
        })

        local uniqueId = HttpService:GenerateGUID(false)

        ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
            ProjectileId = "FlowAyakaUlt",
            ProjectileType = "OneTime",
            Duration = 3,
            ProjectileUniqueId = uniqueId,
            DMGType = "Magic",
            DoTType = "None",
            DMGBonus = 1,
            IsClassUlt = true
        })
        Events.PlayVFXScene_S.FireList(_getNearbyPlayers(char), {
            SceneId = "FlowAyakaUlt",
            Caster = char,
            ProjectileUniqueId = uniqueId
        })
    end)
end

ClassAttackLib.Reverberation = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _addClassUltCharge(plr, 15)
    _restoreMana(char)

    Events.PlayVFXStatusToPlayer_S.FireList(_getNearbyPlayers(char), {
        Character = char,
        StatusId = "SwordSlash"
    })

    local dmg = ClassAttackLib:CalDMG("DMG", char)
    local RNG = Random.new()

    local orbPitch = RNG:NextInteger(1, 5)
    local orbPitch2 = 0
    if char:FindFirstChild("IsInReverberationUltPeriod") then
        orbPitch2 = RNG:NextInteger(1, 5)

        Events.Class_ReverberationSupport.Fire(plr, orbPitch2)
    end

    Events.Class_ReverberationSupport.Fire(plr, orbPitch)

    local targetingPitch = targeting:GetAttribute("ReverberationPitch_"..plr.Name) or 0
    if targetingPitch == orbPitch or targetingPitch == orbPitch2 then
        dmg = math.ceil(dmg * 2)

        ServerLib:ShowText(targeting, "ECHO!", ClassBook.Reverberation.Color)
    end

    ClassAttackLib:DealDamageToEnemy(char, targeting, {
        DMG = dmg,
        DMGType = "DMG",
        Attacker = "ClassAttacks"
    })
end
ClassAttackLib.Reverberation_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _castUltPromiseUtil(function()
        Events.OpenCastTimeBar_S.Fire(plr, 1)
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    end, function()
        char, targeting = _getCharAndTargeting(plr)

        _classUltCastedEff({
            Char = char,
            Player = plr,
            Targeting = targeting,
            Class = "Reverberation"
        })

        local ultPeriodSymbol = Instance.new("BoolValue")
        ultPeriodSymbol.Name = "IsInReverberationUltPeriod"
        ultPeriodSymbol.Value = true
        ultPeriodSymbol.Parent = char
        Debris:AddItem(ultPeriodSymbol, 8)

        StatusLib:CreateCustomStatus("ReverberationUlt", char, {
            Duration = 8
        })

        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.PlayClassAnim_S.Fire(plr, "BurstSpinAttack")
        Events.PlayVFXScene_S.FireList(_getNearbyPlayers(char), {
            SceneId = "BlueEchoUlt",
            Caster = char,
            ProjectileUniqueId = "nil"
        })

        Promise.delay(0.7):andThen(function()
            char, targeting = _getCharAndTargeting(plr)

            for _ = 1, 5 do
                char, targeting = _getCharAndTargeting(plr)
                if not _charAndTargetingCheck(char, targeting) then break end

                ClassAttackLib:DealDamageToEnemy(char, targeting, {
                    DMG = ClassAttackLib:CalDMG("DMG", char, {
                        ForceMaxDMG = true
                    }),
                    DMGType = "DMG",
                    Attacker = "SkillProjectile"
                })
                task.wait(0.5)
            end
        end):catch(function() end)
    end)
end

ClassAttackLib.Furioso = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _addClassUltCharge(plr, 10)
    _restoreMana(char)

    Events.PlayVFXStatusToPlayer_S.FireList(_getNearbyPlayers(char), {
        Character = char,
        StatusId = "SwordSlash"
    })

    local function _performAttack_Durandal()
        for _, entitySymbol: ObjectValue in char.TargetingList:GetChildren() do
            local entity = entitySymbol.Value :: Model
            if not ServerLib:IsCharValid(entity) then continue end

            ClassAttackLib:DealDamageToEnemy(char, entity, {
                Attacker = "ClassAttacks",
                DMG = math.ceil(ClassAttackLib:CalDMG("DMG", char) * 0.5),
                DMGType = "DMG"
            })
        end
    end
    local function _performAttack_OldBoys()
        ClassAttackLib:DealDamageToEnemy(char, targeting, {
            Attacker = "ClassAttacks",
            DMG = ClassAttackLib:CalDMG("DMG", char),
            DMGType = "DMG"
        })
    end
    local function _performAttack_Allas()
        ClassAttackLib:DealDamageToEnemy(char, targeting, {
            Attacker = "ClassAttacks",
            DMG = math.ceil(ClassAttackLib:CalDMG("DMG", char) * 1.5),
            DMGType = "DMG"
        })
    end
    local function _performAttack_Ranga()
        ClassAttackLib:DealDamageToEnemy(char, targeting, {
            Attacker = "ClassAttacks",
            DMG = math.ceil(ClassAttackLib:CalDMG("DMG", char) * 0.7),
            DMGType = "DMG"
        })

        local bleedDoTObj = DoTLib.new({
            Target = targeting,
            Type = "Bleed",
            Creator = char,
            Power = 1,
            Duration = 2
        })
        bleedDoTObj:Activate()
    end

    local isUltMode = char:FindFirstChild("IsInFuriosoUltPeriod") ~= nil
    if isUltMode then
        _performAttack_Durandal()
        _performAttack_OldBoys()
        _performAttack_Allas()
        _performAttack_Ranga()

        HarukaLib:AddAttr(char, "FuriosoCombo", 1)
        char:SetAttribute("FuriosoStage", 5)
    else
        local currentCombo = char:GetAttribute("FuriosoStage") or 0
        currentCombo += 1
        if currentCombo > 4 then
            currentCombo = 1
        end
        currentCombo = math.clamp(currentCombo, 1, 4)

        char:SetAttribute("FuriosoStage", currentCombo)

        if currentCombo == 1 then _performAttack_Durandal()
        elseif currentCombo == 2 then _performAttack_OldBoys()
        elseif currentCombo == 3 then _performAttack_Allas()
        elseif currentCombo == 4 then _performAttack_Ranga()
        end
    end
end
ClassAttackLib.Furioso_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    _castUltPromiseUtil(function()
        Events.OpenCastTimeBar_S.Fire(plr, 1)
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    end, function()
        char, targeting = _getCharAndTargeting(plr)

        _classUltCastedEff({
            Char = char,
            Player = plr,
            Targeting = targeting,
            Class = "Furioso"
        })

        local ultPeriodSymbol = Instance.new("BoolValue")
        ultPeriodSymbol.Name = "IsInFuriosoUltPeriod"
        ultPeriodSymbol.Value = true
        ultPeriodSymbol.Parent = char
        Debris:AddItem(ultPeriodSymbol, 5)

        StatusLib:CreateCustomStatus("FuriosoUlt", char, {
            Duration = 5
        })
        StatusLib:Boost("OrbSpawnTime", char, {
            Duration = 5,
            Ex = -2,
            Power = 0
        })

        char:SetAttribute("FuriosoCombo", 0)
        Promise.delay(5):andThen(function()
            local gained = char:GetAttribute("FuriosoCombo") or 0

            char:SetAttribute("FuriosoCombo", 0)
            if gained < 3 then return end

            char, targeting = _getCharAndTargeting(plr)

            Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)

            Events.PlayClassAnim_S.Fire(plr, "FuriosoAttack2")
            Events.PlayVFXStatusToPlayer_S.FireList(_getNearbyPlayers(char), {
                Character = char,
                StatusId = "FuriosoSlash"
            })
            Events.PlayVFXStatusToPlayer_S.Fire(plr, {
                Character = char,
                StatusId = "ImpactFrame"
            })
            Events.PlayVFXStatusToPlayer_S.Fire(plr, {
                Character = char,
                StatusId = "ShakeCameraBump"
            })

            ServerLib:ShowText(char, "FURIOUS!")

            ClassAttackLib:DealDamageToEnemy(char, targeting, {
                DMG = math.ceil(ClassAttackLib:CalDMG("DMG", char) * 3),
                DMGType = "DMG",
                Attacker = "ClassUlt"
            })
        end):catch(function() end)
    end)
end

ClassAttackLib.Execution = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    if math.random(1, 3) == 2 then
        local dmg = ClassAttackLib:CalDMG("DMG", char)
        StatusLib:Heal(char, math.ceil(dmg / 3))
    end

    ClassAttackLib:DealDamageToEnemy(char, targeting, {
        DMG = math.ceil(ClassAttackLib:CalDMG("DMG", char) * 3),
        DMGType = "DMG",
        Attacker = "ClassAttacks"
    })
end
ClassAttackLib.Execution_Ult = function(plr: Player, symbolAttrs: Dict)

end

--// Private Methods

function ClassAttackLib:CalCastingTime(char: Model, castingTime: number) : number
    local intensity = char:GetAttribute("Intensity") or 0
    local reduceTime = (castingTime * (intensity / 100))

    castingTime -= reduceTime
    castingTime = math.max(1, castingTime)

    return castingTime
end

function ClassAttackLib:CalRESBreak(char: Model, amount: number) : number
    local resBreak = char:GetAttribute("RESBreak") or 100

    amount = amount * (resBreak / 100)
    amount = math.ceil(amount)

    return amount
end

function ClassAttackLib:CalDMG(dmgType: "DMG" | "Magic", char: Model, props: {
    ForceMaxDMG: boolean?,
    ForceDMG: number?,
}?) : number

    local props = props or {}

    local isCrit = false
    local criChance = char:GetAttribute("CriChance") or 1

    criChance = math.min(criChance, 100)

    if criChance >= 100 then
        isCrit = true
    else
        local result, _, _ = HarukaLib:RollLoot({
            ["Crit"] = criChance,
            ["NoEffect"] = 100 - criChance
        })
        isCrit = result == "Crit"
    end
    if isCrit then
        ServerLib:ShowText(char, "CRITICAL!", Color3.fromHex('#ffeaa7'))
    end

    if props.ForceDMG then
        local finalDMG = props.ForceDMG

        if isCrit then
            local criDMGStat = char:GetAttribute("CriDMG") :: number

            finalDMG = math.ceil(finalDMG * (100 + criDMGStat) / 100)
        end
        return finalDMG
    end
    if dmgType == "DMG" then
        local minDMG, maxDMG = char:GetAttribute("MinDMG"), char:GetAttribute("MaxDMG")
        if minDMG > maxDMG then
            maxDMG, minDMG = minDMG, maxDMG
        end
        if props.ForceMaxDMG then
            minDMG = math.max(minDMG, maxDMG)
            maxDMG = math.max(minDMG, maxDMG)
        end
        local rDMG = math.random(minDMG, maxDMG)

        if isCrit then
            local criDMGStat = char:GetAttribute("CriDMG") :: number

            rDMG = math.ceil(maxDMG * (100 + criDMGStat) / 100)
        end

        return rDMG
    elseif dmgType == "Magic" then
        local magic = char:GetAttribute("Magic")

        if isCrit then
            local criDMGStat = char:GetAttribute("CriDMG") :: number

            magic = math.ceil(magic * (100 + criDMGStat) / 100)
        end

        return magic
    end

    return 0
end

function ClassAttackLib:DealDamageToEnemy(char: Model, targeting: Model, dmgProps: {
    DMG: number,
    DMGType: string,
    Attacker: string
})
    if not ServerLib:IsCharValid(targeting) then return end
    if dmgProps.DMG <= 0 then
        ServerLib:ShowText(targeting, "MISS!", Color3.fromHex('#ffffff'))
        ServerLib:ApplyHitStatus(targeting)
        return
    end

    --// middler
    dmgProps.DMG = _damageDealMiddler(char, targeting, dmgProps)

    --- random ticks
    for _ = 1, math.random(1, 5) do
        RunService.Heartbeat:Wait()
    end

    local targetingHumanoid = targeting.Humanoid :: Humanoid
    targetingHumanoid:TakeDamage(dmgProps.DMG)

    --- resistence bar
    if targeting:HasTag("BossEnemyEntity")
        and not targeting:GetAttribute("IsInRESBreakStage") then

        local breakAmount = ClassAttackLib:CalRESBreak(char, 15)
        HarukaLib:AddAttr(targeting, "BreakProgress", breakAmount)

        local curProgress = targeting:GetAttribute("BreakProgress") or 0
        local maxProgress = targeting:GetAttribute("TotalBreakProgress") or 100
        if curProgress >= maxProgress then
            targeting:SetAttribute("IsInRESBreakStage", true)

            HarukaLib:AddAttr(targeting, "DMGTakenBonusExPower", 1)

            local BREAK_DURATION = 6
            Promise.new(function()
                local numVal = Instance.new("NumberValue")
                numVal.Value = targeting:GetAttribute("TotalBreakProgress") + 50
                numVal.Parent = targeting

                local tweenInfo = TweenInfo.new(BREAK_DURATION)

                HarukaLib:CreateTween(numVal, tweenInfo, {
                    Value = 0
                }):Play()
                HarukaLib:Hydrate(numVal, {
                    ["Prop-Value"] = function(val: number)
                        targeting:SetAttribute("BreakProgress", val)
                    end
                })

            end):catch(function() end)

            ServerLib:ShowText(targeting, "STUNNED!")

            local symbol = Instance.new("BoolValue")
            symbol.Name = "ShockingSymbol"
            symbol.Value = true
            symbol.Parent = targeting
            Debris:AddItem(symbol, BREAK_DURATION)

            Promise.delay(BREAK_DURATION):andThen(function()
                targeting:SetAttribute("IsInRESBreakStage", false)
                targeting:SetAttribute("BreakProgress", 0)
                HarukaLib:AddAttr(targeting, "DMGTakenBonusExPower", -1)

                if symbol then symbol:Destroy() end

            end):catch(function() end)
        end
    end

    Promise.try(function()
        local player = Players:GetPlayerFromCharacter(char)
        if not player then return end

        local class = player:GetAttribute("Class") :: string

        ServerLib:ShowNumber(targeting, dmgProps.DMG, ClassBook[class].Color)
        ServerLib:ApplyHitStatus(targeting)

	end):catch(function() end)

    for _, event in char:QueryDescendants("BindableEvent#EnemyGotHit") do
        RunService.Heartbeat:Wait()
        event:Fire(targeting, char, dmgProps)
    end

    --// apply debuffs
    if dmgProps.Attacker ~= "ClassAttacks" then return end

    local debuffList = { "BurnChance", "PoisonChance", "BleedChance" }
    for _, debuff in debuffList do
        RunService.Heartbeat:Wait()
        local chance = char:GetAttribute(debuff) or 0

        local result = HarukaLib:RollLoot({
            ["Debuff"] = chance,
            ["NoEffect"] = 100 - chance
        })
        if result == "Debuff" then
            for _ = 1, math.random(1, 5) do
                RunService.Heartbeat:Wait()
            end

            local id = string.match(debuff, "^(.-)Chance")
            local debuffObj = DoTLib.new({
                Target = targeting,
                Type = id,
                Duration = 5,
                Creator = char,
                Power = 1,
            })
            debuffObj:Activate()
        end
    end
end

return ClassAttackLib