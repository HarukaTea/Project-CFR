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
local HarukaDoT = require(SSS.HarukaServer.Shared.HarukaDoT)

local wait = task.wait

local ClassAttackLib = {}

--// Helper functions

local function _getCharAndTargeting(plr: Player)
    return plr.Character, plr.Character.TargetingEnemy.Value
end
local function _charAndTargetingCheck(char: Model, targeting: Model)
    if char == nil or targeting == nil then return false end
    if not ServerLib:IsCharValid(char) then return false end
    if not ServerLib:IsCharValid(targeting) then return false end

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

    ClassAttackLib:_AddClassUltCharge(plr, 15)
    ClassAttackLib:_RestoreManaByOrb(char)


    HarukaLib:AddAttr(char, "ChainCombo", 1)

    local combo = char:GetAttribute("ChainCombo") :: number
    if combo >= 2 then
        ClassAttackLib:_DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib:_CalDMG("DMG", char) * combo),
        })
    else
        ClassAttackLib:_DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib:_CalDMG("DMG", char),
        })
    end
end
ClassAttackLib.Chain_Ult = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local uniqueId = HttpService:GenerateGUID(false)


    ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
        ProjectileId = "ChainSlash",
        Duration = 10,
        ProjectileUniqueId = uniqueId,
        ProjectileType = "OverTime",
        DMGType = "DMG"
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.PlayAnimation.Fire(plr, {
        AnimId = "BurstSpinAttack"
    })
    Events.PlayClassSPScene.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "ChainSlash",
        Caster = char,
        ProjectileUniqueId = uniqueId
    })
end
ClassAttackLib.HEAL_ATTACK_Chain = ClassAttackLib.HEAL_ATTACK




ClassAttackLib.Burst = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    ClassAttackLib:_AddClassUltCharge(plr, 20)
    ClassAttackLib:_RestoreManaByOrb(char)


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
        ClassAttackLib:_DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib:_CalDMG("DMG", char),
        })
    else
        ClassAttackLib:_DealDamageToEnemy(char, targeting, {
            DMG = ClassAttackLib:_CalDMG("DMG", char),
        })
        ClassAttackLib:_DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib:_CalDMG("DMG", char) * arrows),
        })

        char:SetAttribute("BurstArrow", 0)
    end
end
ClassAttackLib.Burst_Ult = function(plr: Player)
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
    Events.PlayClassSPScene.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "ChainJump",
        Caster = char,
        ProjectileUniqueId = "nil"
    })
    Events.PlayAnimation.Fire(plr, {
        AnimId = "BurstSpinAttack"
    })
    Events.PlayClassSPScene.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "BurstArrowsSplit",
        Caster = char,
        ProjectileUniqueId = "nil"
    })

    Promise.delay(0.9):andThen(function()
        for _ = 1, 3 do
            ClassAttackLib:_DealDamageToEnemy(char, targeting, {
                DMG = ClassAttackLib:_CalDMG("DMG", char)
            })
            wait(0.05)
        end
    end):catch(function() end)
end
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

    ClassAttackLib:_AddClassUltCharge(plr, 15)
    ClassAttackLib:_RestoreManaByOrb(char)

    local resonateNum = math.random(1, 9)
    if char:FindFirstChild("ReverberationEcho") then
        local notOdd = { 2, 4, 6, 8 }
        resonateNum = notOdd[math.random(1, #notOdd)]
    end
    Events.CLASS_RollNewResonateNumForPlayer.Fire(plr, {
        ResonateNum = resonateNum
    })


    ClassAttackLib:_DealDamageToEnemy(char, targeting, {
        DMG = ClassAttackLib:_CalDMG(ClassBook.Reverberation.Type, char),
    })

    local thatResonateNum = targeting:GetAttribute("ReverResonateNum_"..plr.UserId) :: number
    if thatResonateNum and resonateNum == thatResonateNum then
        ClassAttackLib:_DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib:_CalDMG("DMG", char, {
                ForceMaxDMG = true
            }) * 3),
        })

        ServerLib:ShowText(char, "ECHOED!", Color3.fromHex('#81ecec'))
    end
end
ClassAttackLib.Reverberation_Ult = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.PlayAnimation.Fire(plr, {
        AnimId = "BurstSpinAttack"
    })
    Events.PlayClassSPScene.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "BlueEchoUlt",
        Caster = char,
        ProjectileUniqueId = "nil"
    })


    Promise.delay(0.7):andThen(function()
        for _ = 1, 5 do
            char, targeting = _getCharAndTargeting(plr)
            if not _charAndTargetingCheck(char, targeting) then break end


            ClassAttackLib:_DealDamageToEnemy(char, targeting, {
                DMG = ClassAttackLib:_CalDMG("DMG", char, {
                    ForceMaxDMG = true
                })
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


    ClassAttackLib:_AddClassUltCharge(plr, 15)
    ClassAttackLib:_RestoreManaByOrb(char)


    local heat = char:GetAttribute("FlowHeat") :: number
    local nextHeat = math.clamp(heat + 35, 0, 100)

    char:SetAttribute("FlowHeat", nextHeat)


    ClassAttackLib:_DealDamageToEnemy(char, targeting, {
        DMG = ClassAttackLib:_CalDMG("Magic", char),
    })
    if nextHeat >= 100 then
        char:SetAttribute("FlowHeat", 0)

        ClassAttackLib:_DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib:_CalDMG("Magic", char) * 3),
        })
    end
end
ClassAttackLib.Flow_Ult = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    local uniqueId = HttpService:GenerateGUID(false)


    Events.OpenCastTimeBar.Fire(plr, {
        Duration = 1
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellReadyToCast)

    wait(1)
    ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
        ProjectileId = "FlowAyakaUlt",
        ProjectileType = "OneTime",
        Duration = 3,
        ProjectileUniqueId = uniqueId,
        DMGType = "Magic"
    })
    Events.PlaySound.Fire(plr, SoundService.SFXs.SpellCasted)
    Events.PlayAnimation.Fire(plr, {
        AnimId = "MagicCasted1"
    })
    Events.FaceToTargetingEnemy.Fire(plr)

    Events.PlayClassSPScene.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
        SceneId = "FlowAyakaUlt",
        Caster = char,
        ProjectileUniqueId = uniqueId
    })
end
ClassAttackLib.HEAL_ATTACK_Flow = ClassAttackLib.HEAL_ATTACK



ClassAttackLib.Rise = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end


    ClassAttackLib:_AddClassUltCharge(plr, 15)
    ClassAttackLib:_RestoreManaByOrb(char)


    ClassAttackLib:_DealDamageToEnemy(char, targeting, {
        DMG = ClassAttackLib:_CalDMG("DMG", char),
    })
    ClassAttackLib:_DealDamageToEnemy(char, targeting, {
        DMG = ClassAttackLib:_CalDMG("Magic", char),
    })
end
ClassAttackLib.Rise_Ult = function(plr: Player)
    local char, targeting = _getCharAndTargeting(plr)
    if not _charAndTargetingCheck(char, targeting) then return end



end
ClassAttackLib.HEAL_ATTACK_Rise = ClassAttackLib.HEAL_ATTACK



--// Private Methods


function ClassAttackLib:_CalDMG(dmgType: string, char: Model, props: {
    ForceMaxDMG: boolean?
}) : number

    props = props or {}

    local isCrit = false
    local result, _, _ = HarukaLib:RollLoot({
        ["Crit"] = char:GetAttribute("CriChance"),
        ["NoEffect"] = 100 - char:GetAttribute("CriChance")
    })
    isCrit = result == "Crit"

    if isCrit then
        ServerLib:ShowText(char, "CRITICAL!", Color3.fromHex('#ffeaa7'))
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

        local random = Random.new()
        local rDMG = random:NextInteger(minDMG, maxDMG)

        random = nil
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


function ClassAttackLib:_RestoreManaByOrb(char: Model)
    if char:GetAttribute("Mana") < char:GetAttribute("MaxMana") then
        StatusLib:RestoreManaPercentage(char, char:GetAttribute("ManaRegen"))
    end
end

function ClassAttackLib:_AddClassUltCharge(plr: Player, amount: number)
    local char = plr.Character

    HarukaLib:AddAttr(char, "ClassUltProgress", math.ceil(amount * char:GetAttribute("ClassUltCharge") / 100))
end


function ClassAttackLib:_DealDamageToEnemy(char: Model, targeting: Model, dmgProps: {
    DMG: number,
})
    targeting.Humanoid:TakeDamage(dmgProps.DMG)
    ServerBindables.EnemyGotHit:Fire(targeting, char, {
        DMG = dmgProps.DMG,
    })


    Promise.try(function()
        local player = Players:GetPlayerFromCharacter(char)
        if not player then return end

        local class = player:GetAttribute("Class") :: string

        ServerLib:ShowNumber(targeting, dmgProps.DMG, ClassBook[class].Color)
        ServerLib:ApplyHitStatus(targeting)

	end):catch(function(err)
        if RunService:IsStudio() then warn(tostring(err)) end
    end)
end


return ClassAttackLib

