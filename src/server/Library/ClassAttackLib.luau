
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


export type ClassAttackLibClass = {
    [string]: (plr: Player, symbolAttrs: Dict) -> nil,

    _CalCastingTime: (char: Model, baseTime: number) -> number,
    _CalDMG: (dmgType: "DMG" | "Magic", char: Model, props: {
        ForceMaxDMG: boolean?,
        ForceDMG: number?,
    }?) -> number,
    _AddClassUltCharge: (plr: Player, amount: number) -> nil,
    _FireClassUltCasted: (char: Model, props: {
        ClassId: string,
        DMGType: "DMG" | "Magic",
        Target: Model
    }) -> nil,
    _DealDamageToEnemy: (char: Model, target: Model, dmgProps: {
        DMG: number,
        DMGType: "DMG" | "Magic",
        Attacker: string
    }) -> nil,
    _DamageDealMiddler: (char: Model, target: Model, dmgProps: {
        DMG: number,
        DMGType: "DMG" | "Magic",
        Attacker: string
    }) -> nil,


    _getCharAndTargeting: (plr: Player) -> (Model?, Model?),
    _charAndTargetingCheck: (char: Model, targeting: Model) -> boolean,
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
ClassAttackLib._getCharAndTargeting = _getCharAndTargeting
ClassAttackLib._charAndTargetingCheck = _charAndTargetingCheck


local function _castUltPromiseUtil(func1: () -> nil, func2: () -> nil)
    func1()
    Promise.delay(1):andThen(func2):catch(function() end)
end


--// Universal

ClassAttackLib.HEAL_ATTACK = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    StatusLib:Heal(char, math.ceil(char.Humanoid.MaxHealth * 0.12))
end


--// Class-specific

ClassAttackLib.Chain = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    ClassAttackLib._AddClassUltCharge(plr, 15)

    HarukaLib:AddAttr(char, "ChainCombo", 1)


    local combo = char:GetAttribute("ChainCombo") :: number

    if combo >= 2 then
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib._CalDMG("DMG", char) * combo),
            DMGType = "DMG",
            Attacker = "ClassAttacks"
        })

        local comboEff = RepS.Packages.Effects.ComboEffect.Attachment:Clone() :: Attachment
		comboEff.Parent = targeting.PrimaryPart
		Debris:AddItem(comboEff, 1)

        ServerLib.ShowText(char, "COMBO!", ClassBook.Chain.Color)
    else
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib._CalDMG("DMG", char),
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
        ClassAttackLib._FireClassUltCasted(char, {
            ClassId = "Chain",
            DMGType = "DMG",
            Target = targeting
        })


        local uniqueId = HttpService:GenerateGUID(false)

        ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
            ProjectileId = "ChainSlash",
            Duration = 10,
            ProjectileUniqueId = uniqueId,
            ProjectileType = "OverTime",
            DMGType = "DMG",
            DoTType = "Burn",
            DMGBonus = 1,
            IsClassUlt = true
        })
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.PlayClassAnim_S.Fire(plr, "BurstSpinAttack")
        Events.PlayVFXScene_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "ChainSlash",
            Caster = char,
            ProjectileUniqueId = uniqueId
        })
    end)
end
ClassAttackLib.HEAL_ATTACK_Chain = ClassAttackLib.HEAL_ATTACK




ClassAttackLib.Burst = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)


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
		ClassAttackLib._DealDamageToEnemy(char, targeting, {
			DMG = ClassAttackLib._CalDMG("DMG", char),
			DMGType = "DMG",
			Attacker = "ClassAttacks"
		})
		return
	end

	local baseDMG = ClassAttackLib._CalDMG("DMG", char)
	local totalDMG = math.ceil(baseDMG * (1 + 1 * arrowCount + 2 * piercingCount))

	ClassAttackLib._DealDamageToEnemy(char, targeting, {
		DMG = totalDMG,
		DMGType = "DMG",
		Attacker = "ClassAttacks"
	})
	ServerLib:ShowText(char, "BURST SHOT!", ClassBook.Burst.Color)


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
        ClassAttackLib._FireClassUltCasted(char, {
            ClassId = "Burst",
            DMGType = "DMG",
            Target = targeting
        })


        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.FaceTargetingEnemy_S.Fire(plr)


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
        linearVelocity.Attachment0 = char.PrimaryPart.AlignMoverAttachment
        linearVelocity.ForceLimitsEnabled = false
        linearVelocity.VectorVelocity = char.PrimaryPart.CFrame.LookVector + Vector3.yAxis * 50 * 1.8
        linearVelocity.Parent = char.PrimaryPart
        Debris:AddItem(linearVelocity, 0.05)


        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.PlayVFXScene_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "ChainJump",
            Caster = char,
            ProjectileUniqueId = "nil"
        })
        Events.PlayClassAnim_S.Fire(plr, "BurstSpinAttack")
        Events.PlayVFXScene_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "BurstArrowsSplit",
            Caster = char,
            ProjectileUniqueId = "nil"
        })

        Promise.delay(0.9):andThen(function()
            for _ = 1, 3 do
                ClassAttackLib._DealDamageToEnemy(char, targeting, {
                    DMG = ClassAttackLib._CalDMG("DMG", char),
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
ClassAttackLib.HEAL_ATTACK_Burst = ClassAttackLib.HEAL_ATTACK



ClassAttackLib.Flow = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)


    local marked = char:GetAttribute("FlowMark") or 0
    marked += 1
    marked = math.clamp(marked, 0, 3)
    char:SetAttribute("FlowMark", marked)


    if marked < 3 then
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            Attacker = "ClassAttacks",
            DMG = ClassAttackLib._CalDMG("Magic", char),
            DMGType = "Magic"
        })
    else
        char:SetAttribute("FlowMark", 0)

        local dmg = ClassAttackLib._CalDMG("Magic", char)

        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            Attacker = "ClassAttacks",
            DMG = math.ceil(dmg * 4),
            DMGType = "Magic"
        })
    end
end
ClassAttackLib.Flow_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end



    _castUltPromiseUtil(function()
        ServerBindables.RToCastSpell:Fire(plr, char, "FireballSpell", {
            IsClassUlt = true
        })

    end, function()
        ClassAttackLib._FireClassUltCasted(char, {
            ClassId = "Flow",
            DMGType = "Magic",
            Target = targeting
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
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.PlayClassAnim_S.Fire(plr, "MagicCasted1")
        Events.FaceTargetingEnemy_S.Fire(plr)

        Events.PlayVFXScene_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "FlowAyakaUlt",
            Caster = char,
            ProjectileUniqueId = uniqueId
        })
    end)
end
ClassAttackLib.HEAL_ATTACK_Flow = ClassAttackLib.HEAL_ATTACK





ClassAttackLib.Reverberation = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)

    local dmg = ClassAttackLib._CalDMG("DMG", char)
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

    ClassAttackLib._DealDamageToEnemy(char, targeting, {
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
        ClassAttackLib._FireClassUltCasted(char, {
            ClassId = "Reverberation",
            DMGType = "DMG",
            Target = targeting
        })


        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.FaceTargetingEnemy_S.Fire(plr)


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
        Events.PlayVFXScene_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "BlueEchoUlt",
            Caster = char,
            ProjectileUniqueId = "nil"
        })

        Promise.delay(0.7):andThen(function()
            for _ = 1, 5 do
                char, targeting = _getCharAndTargeting(plr)
                if not _charAndTargetingCheck(char, targeting) then break end


                ClassAttackLib._DealDamageToEnemy(char, targeting, {
                    DMG = ClassAttackLib._CalDMG("DMG", char, {
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
ClassAttackLib.HEAL_ATTACK_Reverberation = ClassAttackLib.HEAL_ATTACK



ClassAttackLib.Furioso = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)

    local diceRoll = HarukaLib:RollLoot({
        ["1"] = 70,
        ["2"] = 25,
        ["3"] = 5,
    })
    if char:FindFirstChild("IsInFuriosoUltPeriod") then
        diceRoll = HarukaLib:RollLoot({
            ["2"] = 50,
            ["3"] = 50
        })
    end
    diceRoll = tonumber(diceRoll)


    local rollCounter = char:GetAttribute("FuriosoRollCounter") or 0
    if diceRoll >= 2 then
        rollCounter += 1
        char:SetAttribute("FuriosoRollCounter", rollCounter)
    end
    if rollCounter >= 4 then
        char:SetAttribute("FuriosoRollCounter", 0)

        diceRoll = 3
        ServerLib:ShowText(char, "FURIOUS!", ClassBook.Furioso.Color)
    end



    Events.Class_FuriosoSupport.Fire(plr, diceRoll)


    for i = 1, diceRoll do
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib._CalDMG("DMG", char),
            DMGType = "DMG",
            Attacker = "ClassAttacks"
        })
    end
end
ClassAttackLib.Furioso_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    _castUltPromiseUtil(function()
        Events.OpenCastTimeBar_S.Fire(plr, 1)
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    end, function()
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.FaceTargetingEnemy_S.Fire(plr)


        local ultPeriodSymbol = Instance.new("BoolValue")
        ultPeriodSymbol.Name = "IsInFuriosoUltPeriod"
        ultPeriodSymbol.Value = true
        ultPeriodSymbol.Parent = char

        Debris:AddItem(ultPeriodSymbol, 7)


        StatusLib:CreateCustomStatus("FuriosoUlt", char, {
            Duration = 7
        })
    end)
end
ClassAttackLib.HEAL_ATTACK_Furioso = ClassAttackLib.HEAL_ATTACK



ClassAttackLib.Execution = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    if math.random(1, 3) == 2 then
        local dmg = ClassAttackLib._CalDMG("DMG", char)
        StatusLib:Heal(char, math.ceil(dmg / 3))
    end



    ClassAttackLib._DealDamageToEnemy(char, targeting, {
        DMG = math.ceil(ClassAttackLib._CalDMG("DMG", char) * 3),
        DMGType = "DMG",
        Attacker = "ClassAttacks"
    })
end
ClassAttackLib.Execution_Ult_None = function(plr: Player, symbolAttrs: Dict)

end
ClassAttackLib.HEAL_ATTACK_Execution = ClassAttackLib.HEAL_ATTACK



--// Private Methods

function ClassAttackLib._CalCastingTime(char: Model, baseTime: number) : number
    baseTime = baseTime or 1

    local intensity = char:GetAttribute("Intensity") or 0
    local reduce = baseTime * (intensity / 100)

    local castingTime = baseTime - reduce
    castingTime = math.ceil(castingTime)
    castingTime = math.max(0, castingTime)

    return castingTime
end


function ClassAttackLib._FireClassUltCasted(char: Model, props: {
    ClassId: string,
    DMGType: "DMG" | "Magic",
    Target: Model
})
    for _, event in char:GetDescendants() do
        if event:IsA("BindableEvent") and event.Name == "PlayerClassUltCasted" then
            event:Fire(char, props)
        end
    end
end


function ClassAttackLib._CalDMG(dmgType: "DMG" | "Magic", char: Model, props: {
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


function ClassAttackLib._AddClassUltCharge(plr: Player, amount: number)
    local char = plr.Character

    HarukaLib:AddAttr(char, "ClassUltProgress", math.ceil(amount * char:GetAttribute("ClassUltCharge") / 100))
end

function ClassAttackLib._DamageDealMiddler(char: Model, targeting: Model, dmgProps: {
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


    --// attack immune
    if targeting:FindFirstChild("AttackImmune") then
        dmgProps.DMG /= 2
        dmgProps.DMG = math.ceil(dmgProps.DMG)

        ServerLib:ShowText(targeting, "ATTACK RESIST!", Color3.fromHex('#ffffff'))
    end


    return dmg
end


function ClassAttackLib._DealDamageToEnemy(char: Model, targeting: Model, dmgProps: {
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
    dmgProps.DMG = ClassAttackLib._DamageDealMiddler(char, targeting, dmgProps)


    local targetingHumanoid = targeting.Humanoid :: Humanoid

    targetingHumanoid:TakeDamage(dmgProps.DMG)
    for _, event in char:GetDescendants() do
        if event:IsA("BindableEvent") and event.Name == "EnemyGotHit" then
            event:Fire(targeting, char, dmgProps)
        end
    end


    Promise.try(function()
        local player = Players:GetPlayerFromCharacter(char)
        if not player then return end

        local class = player:GetAttribute("Class") :: string

        ServerLib:ShowNumber(targeting, dmgProps.DMG, ClassBook[class].Color)
        ServerLib:ApplyHitStatus(targeting)

	end):catch(function(err)
        if RunService:IsStudio() then warn(tostring(err)) end
    end)


    --// apply debuffs
    if dmgProps.Attacker ~= "ClassAttacks" then return end


    local debuffList = { "BurnChance", "PoisonChance", "BleedChance" }
    for _, debuff in debuffList do
        local chance = char:GetAttribute(debuff) or 0

        local result = HarukaLib:RollLoot({
            ["Debuff"] = chance,
            ["NoEffect"] = 100 - chance
        })
        if result == "Debuff" then
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