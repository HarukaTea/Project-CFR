
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

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
    _CalDMG: (dmgType: string, char: Model, props: {
        ForceMaxDMG: boolean?,
        ForceDMG: number?,
    }?) -> number,
    _AddClassUltCharge: (plr: Player, amount: number) -> nil,
    _FireClassUltCasted: (char: Model, props: {
        ClassId: string,
        DMGType: string,
        Target: Model
    }) -> nil,
    _DealDamageToEnemy: (char: Model, target: Model, dmgProps: {
        DMG: number,
        DMGType: string,
        Attacker: string
    }) -> nil,
    _DamageDealMiddler: (char: Model, target: Model, dmgProps: {
        DMG: number,
        DMGType: string,
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
    if not ServerLib.IsCharValid(char) then return false end
    if not ServerLib.IsCharValid(targeting) then return false end

    return true
end
ClassAttackLib._getCharAndTargeting = _getCharAndTargeting
ClassAttackLib._charAndTargetingCheck = _charAndTargetingCheck


--// Universal

ClassAttackLib.HEAL_ATTACK = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    StatusLib.Heal(char, math.ceil(char.Humanoid.MaxHealth * 0.12))
end


--// Class-specific

ClassAttackLib.Chain = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)

    HarukaLib:AddAttr(char, "ChainCombo", 1)
    Events.Class_ChainUIUpdateSupport.Fire(plr)


    local isInUltPeriod = char:FindFirstChild("IsInComboUltPeriod") ~= nil
    if isInUltPeriod then
        HarukaLib:AddAttr(char, "ChainCombo", 1)
        Events.Class_ChainUIUpdateSupport.Fire(plr)
    end


    local combo = char:GetAttribute("ChainCombo") :: number

    if combo % 3 == 0 then
        ServerBindables.RToSpawnOrb:Fire(char.Name, "ChainSealOrb")

    elseif combo % 3 == 1 and isInUltPeriod then
        ServerBindables.RToSpawnOrb:Fire(char.Name, "ChainSealOrb")
    end


    if combo <= 1 then
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib._CalDMG("DMG", char),
            DMGType = "Physical",
            Attacker = "ClassAttacks"
        })
        return
    end


    local baseDMG = ClassAttackLib._CalDMG("DMG", char)
	local totalDMG = math.ceil(baseDMG * (1 + 0.75 * combo))


    ClassAttackLib._DealDamageToEnemy(char, targeting, {
        DMG = totalDMG,
        DMGType = "Physical",
        Attacker = "ClassAttacks"
    })

    local comboEff = RepS.Packages.Effects.ComboEffect.Attachment:Clone() :: Attachment
    comboEff.Parent = targeting.PrimaryPart
    Debris:AddItem(comboEff, 1)

    ServerLib.ShowText_S(char, "COMBO!", ClassBook.Chain.Color)
end
ClassAttackLib.Chain_Seal = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local combo = char:GetAttribute("ChainCombo") :: number
    local baseDMG = ClassAttackLib._CalDMG("DMG", char)
	local totalDMG = math.ceil(baseDMG * (1 + combo))


    ClassAttackLib._DealDamageToEnemy(char, targeting, {
        DMG = totalDMG,
        DMGType = "Physical",
        Attacker = "ClassAttacks"
    })


    if not char:FindFirstChild("IsInComboUltPeriod") then
        char:SetAttribute("ChainCombo", 0)
    end
end
ClassAttackLib.Chain_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    Events.OpenCastTimeBar_S.Fire(plr, 1)
    Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellReadyToCast)


    Promise.delay(1):andThen(function()
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.FaceTargetingEnemy_S.Fire(plr)


        local ultPeriodSymbol = Instance.new("BoolValue")
        ultPeriodSymbol.Name = "IsInComboUltPeriod"
        ultPeriodSymbol.Value = true
        ultPeriodSymbol.Parent = char

        Debris:AddItem(ultPeriodSymbol, 6)

        StatusLib.CreateCustomEffect("ComboUlt", char, {
            Duration = 6
        })
    end):catch(function() end)
end
ClassAttackLib.HEAL_ATTACK_Chain = ClassAttackLib.HEAL_ATTACK




ClassAttackLib.Burst = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)


    local now = DateTime.now().UnixTimestamp
	local lastBurst = char:GetAttribute("LastBurstTime") or 0
	local arrowCount = char:GetAttribute("BurstArrow") or 0
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
			DMGType = "Physical",
			Attacker = "ClassAttacks"
		})
		return
	end

	local baseDMG = ClassAttackLib._CalDMG("DMG", char)
	local totalDMG = math.ceil(baseDMG * (1 + 0.75 * consumeNormal + 1.59 * consumePiercing))

	ClassAttackLib._DealDamageToEnemy(char, targeting, {
		DMG = totalDMG,
		DMGType = "Physical",
		Attacker = "ClassAttacks"
	})
	ServerLib.ShowText_S(char, "BURST SHOT!", ClassBook.Burst.Color)


	char:SetAttribute("BurstArrow", math.max(arrowCount - consumeNormal, 0))
	char:SetAttribute("BurstArrowPiercing", math.max(piercingCount - consumePiercing, 0))
	char:SetAttribute("LastBurstTime", now)
end
ClassAttackLib.Burst_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end



    Events.OpenCastTimeBar_S.Fire(plr, 1)
    Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellReadyToCast)


    Promise.delay(1):andThen(function()
        Events.PlaySound_S.Fire(plr, SoundService.SFXs.SpellCasted)
        Events.FaceTargetingEnemy_S.Fire(plr)


        local ultPeriodSymbol = Instance.new("BoolValue")
        ultPeriodSymbol.Name = "IsInBurstUltPeriod"
        ultPeriodSymbol.Value = true
        ultPeriodSymbol.Parent = char

        Debris:AddItem(ultPeriodSymbol, 8)


        StatusLib.CreateCustomEffect("BurstUlt", char, {
            Duration = 8
        })
    end):catch(function() end)
end
ClassAttackLib.Burst_BurstArrow = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    local now = DateTime.now().UnixTimestamp
    local arrowCount = math.clamp( (char:GetAttribute("BurstArrow") or 0) + 1, 0, 12)
    local arrowPiercingCount = char:GetAttribute("BurstArrowPiercing") or 0

    local firstTick = char:GetAttribute("BurstArrowTick1") or 0
    local comboCount = char:GetAttribute("BurstArrowCombo") or 0

    if firstTick == 0 or (now - firstTick) > 3 then
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



ClassAttackLib.Reverberation = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)

    local dmg = ClassAttackLib._CalDMG("DMG", char)

    local orbPitch = symbolAttrs.ReverberationPitch
    char:SetAttribute("ReverberationPitch", orbPitch)

    local targetingPitch = targeting:GetAttribute("ReverberationPitch_"..plr.Name) or 0
    if targetingPitch == orbPitch then
        dmg = math.ceil(dmg * 2.5)

        local echoStackFolder = targeting:FindFirstChild("EchoHolder_"..plr.Name)
        if not echoStackFolder then
            echoStackFolder = Instance.new("Folder")
            echoStackFolder.Name = "EchoHolder_"..plr.Name
            echoStackFolder.Parent = targeting
        end

        local echoStack = #echoStackFolder:GetChildren()
        if echoStack < 3 then
            local echoSymbol = Instance.new("BoolValue")
            echoSymbol.Name = "Echo"
            echoSymbol.Value = true
            echoSymbol.Parent = echoStackFolder

            Debris:AddItem(echoSymbol, 15)
        end
    end


    ClassAttackLib._DealDamageToEnemy(char, targeting, {
        DMG = dmg,
        DMGType = "Physical",
        Attacker = "ClassAttacks"
    })
end
ClassAttackLib.Reverberation_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local enemySymbols = char.TargetingList:GetChildren() :: { ObjectValue }
    local enemies = {} :: { Model }

    for _, symbol in enemySymbols do
        table.insert(enemies, symbol.Value)
    end
    for _, enemy in enemies do
        if not enemy:FindFirstChild("EchoHolder_"..plr.Name) then continue end

        local stack = #enemy["EchoHolder_"..plr.Name]:GetChildren()
        if stack <= 0 then continue end

        enemy["EchoHolder_"..plr.Name]:ClearAllChildren()

        for _ = 1, stack do
            local dmg = ClassAttackLib._CalDMG("DMG", char)

            local note = enemy:GetAttribute("ReverberationPitch_"..plr.Name) or 0
            local pitch = char:GetAttribute("ReverberationPitch") or 10

            if note == pitch then
                dmg = math.ceil(dmg * 2.05)
            end

            ClassAttackLib._DealDamageToEnemy(char, enemy, {
                DMG = dmg,
                DMGType = "Physical",
                Attacker = "EchoStack"
            })
        end
    end
end
ClassAttackLib.Reverberation_Shift = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    local pitch = targeting:GetAttribute("ReverberationPitch_"..plr.Name) or 0
    local afterPitch = pitch + 1

    if afterPitch > 9 then afterPitch = 1 end
    if afterPitch < 1 then afterPitch = 9 end

    targeting:SetAttribute("ReverberationPitch_"..plr.Name, afterPitch)
end
ClassAttackLib.Reverberation_Flat = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local pitch = targeting:GetAttribute("ReverberationPitch_"..plr.Name) or 0
    local afterPitch = pitch - 1

    if afterPitch > 9 then afterPitch = 1 end
    if afterPitch < 1 then afterPitch = 9 end

    targeting:SetAttribute("ReverberationPitch_"..plr.Name, afterPitch)
end
ClassAttackLib.HEAL_ATTACK_Reverberation = ClassAttackLib.HEAL_ATTACK



ClassAttackLib.Flow = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)

    local markHolder = targeting:FindFirstChild("MarkHolder_"..plr.Name)
    if not markHolder then
        markHolder = Instance.new("Folder")
        markHolder.Name = "MarkHolder_"..plr.Name
        markHolder.Parent = targeting
    end

    local markStack = #markHolder:GetChildren()
    if markStack >= 5 then return end


    local markSymbol = Instance.new("BoolValue")
    markSymbol.Name = "Mark"
    markSymbol.Value = true
    markSymbol.Parent = markHolder
    Debris:AddItem(markSymbol, 8)
end
ClassAttackLib.Flow_Catalyst = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    local activateDuringUlt = false

    if char:FindFirstChild("IsInFlowUltPeriod") and not char:FindFirstChild("IsCatalystOrbTouched") then
        local catalystSymbol = Instance.new("BoolValue")
        catalystSymbol.Name = "IsCatalystOrbTouched"
        catalystSymbol.Value = true
        catalystSymbol.Parent = char

        Debris:AddItem(catalystSymbol, 6)

        activateDuringUlt = true
    end


    local enemiesSymbol = char.TargetingList:GetChildren() :: { ObjectValue }
    local enemies = {}
    for _, symbol in enemiesSymbol do
        table.insert(enemies, symbol.Value)
    end

    for _, enemy in enemies do
        local markHolder = enemy:FindFirstChild("MarkHolder_"..plr.Name)
        if not markHolder then continue end

        local markStack = #markHolder:GetChildren()
        if markStack <= 0 then continue end

        local firstMark = markHolder:FindFirstChildOfClass("BoolValue")
        if firstMark then
            firstMark:Destroy()
        end


        --// overload check
        local now = DateTime.now().UnixTimestamp
        local detonationCountAttr = "FlowDetonationCount_"..plr.Name
        local detonationTimeAttr = "FlowDetonationTime_"..plr.Name

        local lastDetTime = enemy:GetAttribute(detonationTimeAttr) or 0
        local detCount = enemy:GetAttribute(detonationCountAttr) or 0

        if (now - lastDetTime) <= 2 then
            detCount += 1
        else
            detCount = 1
        end

        enemy:SetAttribute(detonationCountAttr, detCount)
        enemy:SetAttribute(detonationTimeAttr, now)


        if detCount >= 3 or activateDuringUlt then
            if not activateDuringUlt then
                markHolder:ClearAllChildren()

                enemy:SetAttribute(detonationCountAttr, 0)
                enemy:SetAttribute(detonationTimeAttr, 0)
            end

            local dmg = math.ceil(ClassAttackLib._CalDMG("Magic", char) * 6)

            ClassAttackLib._DealDamageToEnemy(char, enemy, {
                DMG = dmg,
                DMGType = "Magic",
                Attacker = "ClassAttacks"
            })
            ServerLib.ShowText_S(enemy, "OVERLOAD BURST!", Color3.fromRGB(255, 60, 60))
            continue
        end

        --// normal detonation
        local dmg = ClassAttackLib._CalDMG("Magic", char)
        dmg = math.ceil(dmg * (1 + 0.5 * markStack))

        ClassAttackLib._DealDamageToEnemy(char, enemy, {
            DMG = dmg,
            DMGType = "Magic",
            Attacker = "ClassAttacks"
        })
    end
end
ClassAttackLib.Flow_Ult = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local ultPeriodSymbol = Instance.new("BoolValue")
    ultPeriodSymbol.Name = "IsInFlowUltPeriod"
    ultPeriodSymbol.Value = true
    ultPeriodSymbol.Parent = char

    Debris:AddItem(ultPeriodSymbol, 6)


    StatusLib.CreateCustomEffect("FlowUlt", char, {
        Duration = 6
    })
end
ClassAttackLib.HEAL_ATTACK_Flow = ClassAttackLib.HEAL_ATTACK



ClassAttackLib.Execution = function(plr: Player, symbolAttrs: Dict)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    if math.random(1, 3) == 2 then
        local dmg = ClassAttackLib._CalDMG("DMG", char)
        StatusLib.Heal(char, math.ceil(dmg / 3))
    end



    ClassAttackLib._DealDamageToEnemy(char, targeting, {
        DMG = math.ceil(ClassAttackLib._CalDMG("DMG", char) * 3),
        DMGType = "Physical",
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
    DMGType: string,
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
        ServerLib.ShowText_S(char, "CRITICAL!", Color3.fromHex('#ffeaa7'))
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

function ClassAttackLib:_DamageDealMiddler(char: Model, targeting: Model, dmgProps: {
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


    return dmg
end


function ClassAttackLib._DealDamageToEnemy(char: Model, targeting: Model, dmgProps: {
    DMG: number,
    DMGType: string,
    Attacker: string
})
    if not ServerLib.IsCharValid(targeting) then return end

    if targeting:FindFirstChild("AttackImmune") then
        dmgProps.DMG /= 2
        dmgProps.DMG = math.ceil(dmgProps.DMG)

        ServerLib.ShowText_S(targeting, "ATTACK RESIST!", Color3.fromHex('#ffffff'))
    end
    if dmgProps.DMG <= 0 then
        ServerLib.ShowText_S(targeting, "MISS!", Color3.fromHex('#ffffff'))
        ServerLib.ApplyHitStatus(targeting)
        return
    end

    --// middler
    dmgProps.DMG = ClassAttackLib:_DamageDealMiddler(char, targeting, dmgProps)


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

        ServerLib.ShowNumber(targeting, dmgProps.DMG, ClassBook[class].Color)
        ServerLib.ApplyHitStatus(targeting)

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