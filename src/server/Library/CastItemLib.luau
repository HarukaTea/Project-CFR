--!nocheck

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local ItemLib = require(RepS.HarukaShared.Library.ItemLib)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local StatusLib = require(SSS.HarukaServer.Library.StatusLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local CastItemLib = {}

local wait = task.wait

--// Helper functions

local function _preCheck(props: {
    ReqCombat: boolean,
    ReqEnemy: boolean,
}, data: {
    ItemId: string,
    Player: Player,
    Char: Model
}) : boolean

    local player, char = data.Player, data.Char


    if not player or not char then
        return false
    end
    if not ServerLib:IsCharValid(char) then
        return false
    end
    if not ItemLib:GetItemInfo(data.ItemId) then
        Events.CreateNotify.Fire(player, "[Error] Invalid Item Id")
        return false
    end
    if props.ReqCombat then
        if not char:GetAttribute("IsInCombat") then
            Events.CreateNotify.Fire(player, "You need to be in combat mode to use this item!")
            return false
        end
    end
    if props.ReqEnemy then
        if not char.TargetingEnemy.Value then
            Events.CreateNotify.Fire(player, "You need to have a target monster to use this item!")
            return false
        end

        local enemy = char.TargetingEnemy.Value :: Model
        if not ServerLib:IsCharValid(enemy) then
            Events.CreateNotify.Fire(player, "[Error] Invalid Target Entity")
            return false
        end
    end

    return true
end
local function _eatSoundFunc(char: Model, func: () -> nil)
    local eatSound = SoundService.SFXs.EatSound :: Sound
    ServerLib:PlayWorldSound(eatSound, char.PrimaryPart.Position)


    task.delay(eatSound.TimeLength / 2, func)
end
local function _drinkSoundFunc(char: Model, func: () -> nil)
    local drinkSound = SoundService.SFXs.DrinkSound :: Sound
    ServerLib:PlayWorldSound(drinkSound, char.PrimaryPart.Position)


    task.delay(drinkSound.TimeLength / 2, func)
end


--// Actives


CastItemLib.HealthyApple = function(player: Player, char: Model) : number?
    local check = _preCheck({
        ReqCombat = false,
        ReqEnemy = false
    }, {
        ItemId = "HealthyApple",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    _eatSoundFunc(char, function()
        local amount = StatusLib:HealPercentage(char, 5)

        ServerLib:ShowNumber(char, amount, Color3.fromHex('#7bed9f'))
    end)
end


CastItemLib.GoldenApple = function(player: Player, char: Model) : number?
    local check = _preCheck({
        ReqCombat = false,
        ReqEnemy = false
    }, {
        ItemId = "GoldenApple",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    _eatSoundFunc(char, function()
        local amount = StatusLib:HealPercentage(char, 15)
        ServerLib:ShowNumber(char, amount, Color3.fromHex('#7bed9f'))

        StatusLib:DMGBoost(char, {
            DMGPower = 0.5,
            Duration = 6
        })
    end)
end


CastItemLib.HealthPotion = function(player: Player, char: Model) : number?
    local check = _preCheck({
        ReqCombat = false,
        ReqEnemy = false
    }, {
        ItemId = "HealthPotion",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    _drinkSoundFunc(char, function()
        local amount = StatusLib:HealPercentage(char, 20)

        ServerLib:ShowNumber(char, amount, Color3.fromHex('#7bed9f'))
    end)
end


CastItemLib.PowerPotion = function(player: Player, char: Model) : number?
    local check = _preCheck({
        ReqCombat = false,
        ReqEnemy = false
    }, {
        ItemId = "PowerPotion",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    _drinkSoundFunc(char, function()
        StatusLib:DMGBoost(char, {
            DMGPower = 0.75,
            Duration = 8
        })
    end)
end


CastItemLib.MagicPotion = function(player: Player, char: Model) : number?
    local check = _preCheck({
        ReqCombat = false,
        ReqEnemy = false
    }, {
        ItemId = "MagicPotion",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    _drinkSoundFunc(char, function()
        StatusLib:NormalBoostForEntity("Magic", char, {
            Power = 0.75,
            Duration = 8
        })

        Events.PlayStatPoweredScreenFX.Fire(player)
    end)
end


CastItemLib.ManaPotion = function(player: Player, char: Model) : number?
    local check = _preCheck({
        ReqCombat = false,
        ReqEnemy = false
    }, {
        ItemId = "ManaPotion",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    _drinkSoundFunc(char, function()
        HarukaLib:AddAttr(char, "Mana", math.floor(char:GetAttribute("MaxMana") * 0.35))

        local restoreEff = RepS.Packages.Effects.Restoring:Clone() :: BasePart
        restoreEff.Parent = char

        Debris:AddItem(restoreEff, 1.5)
    end)
end


CastItemLib.EndurancePotion = function(player: Player, char: Model) : number?
    local check = _preCheck({
        ReqCombat = false,
        ReqEnemy = false
    }, {
        ItemId = "EndurancePotion",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    _drinkSoundFunc(char, function()
        HarukaLib:AddAttr(char, "Shield", math.floor(char:GetAttribute("MaxShield") * 0.5))

        local repairingEff = RepS.Packages.Effects.Repairing:Clone() :: BasePart
        repairingEff.Parent = char

        Debris:AddItem(repairingEff, 1.5)
    end)
end


CastItemLib.FireballSpell = function(player: Player, char: Model, extraInfo: {
    CostManaFunc: () -> nil,
}) : number?
    local check = _preCheck({
        ReqCombat = true,
        ReqEnemy = true
    }, {
        ItemId = "FireballSpell",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    extraInfo.CostManaFunc()


    local uniqueId = HttpService:GenerateGUID(false)


    Events.OpenCastTimeBar.Fire(player, {
        Duration = 1
    })
    Events.PlaySound.Fire(player, SoundService.SFXs.SpellReadyToCast)


    Promise.delay(1):andThen(function()
        ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
            ProjectileId = "FireballSpell",
            Duration = 3,
            ProjectileType = "OneTime",
            ProjectileUniqueId = uniqueId,
            DMGType = "Magic",
            DoTType = "Burn"
        })
        Events.PlaySound.Fire(player, SoundService.SFXs.SpellCasted)
        Events.PlayAnimation.Fire(player, {
            AnimId = "MagicCasted1"
        })
        Events.FaceToTargetingEnemy.Fire(player)


        Events.PlayClassSPScene.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "FireballSpell",
            Caster = char,
            ProjectileUniqueId = uniqueId,
        })
    end)
end


CastItemLib.Agility = function(player: Player, char: Model, extraInfo: {
    CostManaFunc: () -> nil,
}) : number?
    local check = _preCheck({
        ReqCombat = false,
        ReqEnemy = false
    }, {
        ItemId = "Agility",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    Events.PlaySound.Fire(player, SoundService.SFXs.SpellCasted)

    StatusLib:NormalBoostForEntity("Speed", char, {
        Power = 0.5,
        Duration = 6
    })


    local eff = RepS.Packages.Effects.Status.Speeding:FindFirstChildOfClass("ParticleEmitter"):Clone() :: ParticleEmitter
    eff.Parent = char.PrimaryPart
    Debris:AddItem(eff, 6)


    Promise.delay(5):andThen(function()
        eff.Enabled = false
    end):catch(function() end)
end


CastItemLib.ExtraJump = function(player: Player, char: Model, extraInfo: {
    CostManaFunc: () -> nil,
}) : number?
    local check = _preCheck({
        ReqCombat = false,
        ReqEnemy = false
    }, {
        ItemId = "ExtraJump",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    Events.Spell_ExtraJumpSupport.Fire(player)
end



return CastItemLib
