--!nocheck

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local RepS = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local ClassBook = require(RepS.HarukaShared.Library.ClassBook)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local StatusLib = require(SSS.HarukaServer.Library.StatusLib)
local DoTLib = require(SSS.HarukaServer.Services.DoTLib)

local wait = task.wait

local ClassAttackLib = {}

--// Helper functions

local function _getCharAndTargeting(plr: Player)
    return plr.Character, plr.Character.TargetingEnemy.Value
end
local function _charAndTargetingCheck(char: Model, targeting: Model)
    if char == nil or targeting == nil then return false end
    if not ServerLib.IsCharValid(char) then return false end
    if not ServerLib.IsCharValid(targeting) then return false end

    return true
end

--// Universal

ClassAttackLib.HEAL_ATTACK = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    StatusLib:Heal(char, math.ceil(char.Humanoid.MaxHealth * 0.12))
end


--// Class-specific

ClassAttackLib.Chain = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)

    HarukaLib:AddAttr(char, "ChainCombo", 1)

    local combo = char:GetAttribute("ChainCombo") :: number
    if combo >= 2 then
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib._CalDMG("DMG", char) * combo),
            DMGType = "Physical",
            Attacker = "ClassAttacks"
        })

        local comboEff = RepS.Packages.Effects.ComboEffect.Attachment:Clone() :: Attachment
		comboEff.Parent = targeting.PrimaryPart
		Debris:AddItem(comboEff, 1)

        ServerLib.ShowText(char, "COMBO!", ClassBook.Chain.Color)
    else
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib._CalDMG("DMG", char),
            DMGType = "Physical",
            Attacker = "ClassAttacks"
        })
    end
end
ClassAttackLib.Chain_Ult_None = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local uniqueId = HttpService:GenerateGUID(false)


    ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
        ProjectileId = "ChainSlash",
        Duration = 10,
        ProjectileUniqueId = uniqueId,
        ProjectileType = "OverTime",
        DMGType = "DMG",
        DoTType = "Burn",
        DMGBonus = 1
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.PlayAnimation.Fire(plr, {
        AnimId = "BurstSpinAttack"
    })
    Events.PlayClassSPScene.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "ChainSlash",
        Caster = char,
        ProjectileUniqueId = uniqueId
    })


    ClassAttackLib._FireClassUltCasted(char, {
        ClassId = "Chain",
        ClassVariant = "None",
        DMGType = "Physical",
        Target = targeting
    })
end
ClassAttackLib.Chain_Ult_Combo = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local uniqueId = HttpService:GenerateGUID(false)
    local castTime = ClassAttackLib._CalCastingTime(char, 1)


    Events.OpenCastTimeBar.Fire(plr, {
        Duration = castTime
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    wait(castTime)
    ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
        ProjectileId = "ChainSwordAstral",
        ProjectileType = "OverTime",
        Duration = 4,
        ProjectileUniqueId = uniqueId,
        DMGType = "DMG",
        DoTType = "None",
        DMGBonus = 1.5
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.PlayAnimation.Fire(plr, {
        AnimId = "MagicCasted1"
    })
    Events.FaceToTargetingEnemy.Fire(plr)


    Events.PlayClassSPScene.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "ChainSwordAstral",
        Caster = char,
        ProjectileUniqueId = uniqueId
    })


    ClassAttackLib._FireClassUltCasted(char, {
        ClassId = "Chain",
        ClassVariant = "Combo",
        DMGType = "Physical",
        Target = targeting
    })
end
ClassAttackLib.HEAL_ATTACK_Chain = ClassAttackLib.HEAL_ATTACK




ClassAttackLib.Burst = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    ClassAttackLib._AddClassUltCharge(plr, 20)

    ServerBindables.RToSpawnOrb:Fire(char.Name, "ArrowOrb")

    local result, _, _ = HarukaLib:RollLoot({
        Extra = 20,
        None = 80
    })
    if result == "Extra" then
        ServerBindables.RToSpawnOrb:Fire(char.Name, "ArrowOrb")
    end

    local arrows = char:GetAttribute("BurstArrow") :: number

    if arrows == nil or arrows <= 0 then
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib._CalDMG("DMG", char),
            DMGType = "Physical",
            Attacker = "ClassAttacks"
        })
    else
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib._CalDMG("DMG", char),
            DMGType = "Physical",
            Attacker = "ClassAttacks"
        })
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib._CalDMG("DMG", char) * arrows),
            DMGType = "Physical",
            Attacker = "ClassAttacks"
        })

        ServerLib.ShowText(char, "BURST!", ClassBook.Burst.Color)

        char:SetAttribute("BurstArrow", 0)
    end
end
ClassAttackLib.Burst_Ult_None = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Name = "ExtraUpBV"
    linearVelocity.Attachment0 = char.PrimaryPart.AlignMoverAttachment
    linearVelocity.ForceLimitsEnabled = false
    linearVelocity.VectorVelocity = char.PrimaryPart.CFrame.LookVector + Vector3.yAxis * 50 * 1.8
    linearVelocity.Parent = char.PrimaryPart
    Debris:AddItem(linearVelocity, 0.05)


    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.PlayClassSPScene.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "ChainJump",
        Caster = char,
        ProjectileUniqueId = "nil"
    })
    Events.PlayAnimation.Fire(plr, {
        AnimId = "BurstSpinAttack"
    })
    Events.PlayClassSPScene.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "BurstArrowsSplit",
        Caster = char,
        ProjectileUniqueId = "nil"
    })


    ClassAttackLib._FireClassUltCasted(char, {
        ClassId = "Burst",
        ClassVariant = "None",
        DMGType = "Physical",
        Target = targeting
    })

    Promise.delay(0.9):andThen(function()
        for _ = 1, 3 do
            ClassAttackLib._DealDamageToEnemy(char, targeting, {
                DMG = ClassAttackLib._CalDMG("DMG", char),
                DMGType = "Physical",
                Attacker = "SkillProjectile"
            })
            wait(0.05)
        end
    end):catch(function() end)
end
ClassAttackLib.Burst_Ult_Stack = ClassAttackLib.Burst_Ult_None
ClassAttackLib.Burst_BurstArrow = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    local afterArrow = char:GetAttribute("BurstArrow") or 0

    afterArrow = math.clamp(afterArrow + 1, 0, 10)
    char:SetAttribute("BurstArrow", afterArrow)
end
ClassAttackLib.HEAL_ATTACK_Burst = ClassAttackLib.HEAL_ATTACK



ClassAttackLib.Reverberation = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end

    ClassAttackLib._AddClassUltCharge(plr, 15)

    local resonateNum = math.random(1, 9)
    if char:FindFirstChild("ReverberationEcho") then
        local notOdd = { 2, 4, 6, 8 }
        resonateNum = notOdd[math.random(1, #notOdd)]
    end
    Events.CLASS_RollNewResonateNumForPlayer.Fire(plr, {
        ResonateNum = resonateNum
    })


    ClassAttackLib._DealDamageToEnemy(char, targeting, {
        DMG = ClassAttackLib._CalDMG(ClassBook.Reverberation.Type, char),
        DMGType = "Physical",
        Attacker = "ClassAttacks"
    })

    local thatResonateNum = targeting:GetAttribute("ReverResonateNum_"..plr.UserId) :: number
    if thatResonateNum and resonateNum == thatResonateNum then
        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib._CalDMG("DMG", char, {
                ForceMaxDMG = true
            }) * 3),
            DMGType = "Physical",
            Attacker = "ClassAttacks"
        })

        ServerLib.ShowText(char, "ECHOED!", Color3.fromHex('#81ecec'))
    end
end
ClassAttackLib.Reverberation_Ult_None = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.PlayAnimation.Fire(plr, {
        AnimId = "BurstSpinAttack"
    })
    Events.PlayClassSPScene.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "BlueEchoUlt",
        Caster = char,
        ProjectileUniqueId = "nil"
    })


    ClassAttackLib._FireClassUltCasted(char, {
        ClassId = "Reverberation",
        ClassVariant = "None",
        DMGType = "Physical",
        Target = targeting
    })


    Promise.delay(0.7):andThen(function()
        for _ = 1, 5 do
            char, targeting = _getCharAndTargeting(plr)
            if not _charAndTargetingCheck(char, targeting) then break end


            ClassAttackLib._DealDamageToEnemy(char, targeting, {
                DMG = ClassAttackLib._CalDMG("DMG", char, {
                    ForceMaxDMG = true
                }),
                DMGType = "Physical",
                Attacker = "SkillProjectile"
            })
            wait(0.5)
        end
    end):catch(function() end)
end
ClassAttackLib.Reverberation_Echo = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    StatusLib:CreateCustomEffect("Reverberation", char, {
        Duration = 6
    })

    local eff = Instance.new("BoolValue")
    eff.Name = "ReverberationEcho"
    eff.Value = true
    eff.Parent = char
    Debris:AddItem(eff, 6)
end
ClassAttackLib.HEAL_ATTACK_Reverberation = ClassAttackLib.HEAL_ATTACK



ClassAttackLib.Flow = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    ClassAttackLib._AddClassUltCharge(plr, 15)

    local heat = char:GetAttribute("FlowHeat") :: number
    local nextHeat = math.clamp(heat + 35, 0, 100)

    char:SetAttribute("FlowHeat", nextHeat)


    ClassAttackLib._DealDamageToEnemy(char, targeting, {
        DMG = ClassAttackLib._CalDMG("Magic", char),
        DMGType = "Magic",
        Attacker = "ClassAttacks"
    })
    if nextHeat >= 100 then
        char:SetAttribute("FlowHeat", 0)

        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib._CalDMG("Magic", char) * 3),
            DMGType = "Magic",
            Attacker = "ClassAttacks"
        })

        local burnObj = DoTLib.new({
            Target = targeting,
            Type = "Burn",
            Duration = 8,
            Creator = char,
            Power = 1,
        })
        burnObj:Activate()


        ServerLib.ShowText(char, "FLOW!", ClassBook.Flow.Color)
    end
end
ClassAttackLib.Flow_Ult_None = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local uniqueId = HttpService:GenerateGUID(false)
    local castTime = ClassAttackLib._CalCastingTime(char, 1)


    Events.OpenCastTimeBar.Fire(plr, {
        Duration = castTime
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    wait(castTime)
    ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
        ProjectileId = "FlowAyakaUlt",
        ProjectileType = "OneTime",
        Duration = 3,
        ProjectileUniqueId = uniqueId,
        DMGType = "Magic",
        DoTType = "None",
        DMGBonus = 1
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.PlayAnimation.Fire(plr, {
        AnimId = "MagicCasted1"
    })
    Events.FaceToTargetingEnemy.Fire(plr)

    Events.PlayClassSPScene.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "FlowAyakaUlt",
        Caster = char,
        ProjectileUniqueId = uniqueId
    })


    ClassAttackLib._FireClassUltCasted(char, {
        ClassId = "Flow",
        ClassVariant = "None",
        DMGType = "Magical",
        Target = targeting
    })
end
ClassAttackLib.Flow_Ult_Focus = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local uniqueId = HttpService:GenerateGUID(false)
    local castTime = ClassAttackLib._CalCastingTime(char, 3)

    local uniqueId2 = HttpService:GenerateGUID(false)


    Events.OpenCastTimeBar.Fire(plr, {
        Duration = castTime
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    wait(castTime)
    ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
        ProjectileId = "FlowGanyuUlt",
        ProjectileType = "OverTime",
        Duration = 8,
        ProjectileUniqueId = uniqueId,
        DMGType = "Magic",
        DoTType = "Burn",
        DMGBonus = 3
    })
    ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
        ProjectileId = "FlowLightningBlast",
        ProjectileType = "OneTime",
        Duration = 3,
        ProjectileUniqueId = uniqueId2,
        DMGType = "Magic",
        DoTType = "Burn",
        DMGBonus = 3
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.PlayAnimation.Fire(plr, {
        AnimId = "MagicCasted1"
    })
    Events.FaceToTargetingEnemy.Fire(plr)

    Events.PlayClassSPScene.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "FlowGanyuUlt",
        Caster = char,
        ProjectileUniqueId = uniqueId
    })
    Events.PlayClassSPScene.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "FlowLightningBlast",
        Caster = char,
        ProjectileUniqueId = uniqueId2
    })


    ClassAttackLib._FireClassUltCasted(char, {
        ClassId = "Flow",
        ClassVariant = "Focus",
        DMGType = "Magical",
        Target = targeting
    })
end
ClassAttackLib.HEAL_ATTACK_Flow = ClassAttackLib.HEAL_ATTACK



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

})
    for _, event: BindableEvent in char:GetChildren() do
        if event:IsA("BindableEvent") and event.Name == "PlayerClassUltCasted" then
            event:Fire(char, props)
        end
    end
end


function ClassAttackLib._CalDMG(dmgType: string, char: Model, props: {
    ForceMaxDMG: boolean?,
    ForceDMG: number?,
}) : number

    props = props or {}

    local isCrit = false
    local result, _, _ = HarukaLib:RollLoot({
        ["Crit"] = char:GetAttribute("CriChance"),
        ["NoEffect"] = 100 - char:GetAttribute("CriChance")
    })
    isCrit = result == "Crit"

    if isCrit then
        ServerLib.ShowText(char, "CRITICAL!", Color3.fromHex('#ffeaa7'))
    end


    if props.ForceDMG then
        local finalDMG = props.ForceDMG

        if isCrit then
            finalDMG = math.ceil(finalDMG * (100 + char:GetAttribute("CriDMG")) / 100)
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
            rDMG = math.ceil(maxDMG * (100 + char:GetAttribute("CriDMG")) / 100)
        end

        return rDMG
    elseif dmgType == "Magic" then
        local magic = char:GetAttribute("Magic")

        if isCrit then
            magic = math.ceil(magic * (100 + char:GetAttribute("CriDMG")) / 100)
        end

        return magic
    end

    return 0
end


function ClassAttackLib._AddClassUltCharge(plr: Player, amount: number)
    local char = plr.Character

    HarukaLib:AddAttr(char, "ClassUltProgress", math.ceil(amount * char:GetAttribute("ClassUltCharge") / 100))
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

        ServerLib.ShowText(targeting, "ATTACK RESIST!", Color3.fromHex('#ffffff'))
    end
    if dmgProps.DMG <= 0 then
        ServerLib.ShowText(targeting, "MISS!", Color3.fromHex('#ffffff'))
        ServerLib.ApplyHitStatus(targeting)
        return
    end

    --// perk bonus
    if dmgProps.Attacker == "ClassAttacks" then
        local bonus = char:GetAttribute("ClassAttackBonusDMG") or 100
        dmgProps.DMG = math.ceil(dmgProps.DMG * bonus / 100)
    end

    --// blood spellbook bonus
    if dmgProps.Attacker == "ClassAttacks" and char:FindFirstChild("BloodSpellbook") then
        dmgProps.DMG = math.ceil(dmgProps.DMG * 1.5)
    end

    targeting.Humanoid:TakeDamage(dmgProps.DMG)
    for _, event: BindableEvent in char:GetDescendants() do
        if event:IsA("BindableEvent") then
            if event.Name == "EnemyGotHit" then
                event:Fire(targeting, char, dmgProps)
            end
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



shared.ClassAttackLib = ClassAttackLib


return ClassAttackLib

