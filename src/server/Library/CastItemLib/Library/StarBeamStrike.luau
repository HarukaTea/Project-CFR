--!nocheck
--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local ClassAttackLib = require(SSS.HarukaServer.Library.ClassAttackLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)


local Types = require(script.Parent.Parent.Types)


local wait = task.wait


return function(self: Types.CastItemTable, player: Player, char: Model, extraInfo: {}) : number?
    local CastItemLib = self

    local check = CastItemLib._preCheck({
        ReqCombat = true,
        ReqEnemy = true
    }, {
        ItemId = "StarBeamStrike",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    local uniqueId = HttpService:GenerateGUID(false)
    local castTime = ClassAttackLib._CalCastingTime(char, 3)


    Events.OpenCastTimeBar.Fire(player, {
        Duration = castTime
    })
    Events.PlaySound.Fire(player, SoundService.SFXs.SpellReadyToCast)


    Promise.delay(castTime):andThen(function()
        ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
            ProjectileId = "StarBeamStrike",
            Duration = 6,
            ProjectileType = "OverTime",
            ProjectileUniqueId = uniqueId,
            DMGType = "Magic",
            DoTType = "Burn",
            DMGBonus = 2,
            IsClassUlt = false
        })
        Events.PlaySound.Fire(player, SoundService.SFXs.SpellCasted)
        Events.PlayAnimation.Fire(player, {
            AnimId = "MagicCasted1"
        })
        Events.FaceToTargetingEnemy.Fire(player)


        Events.PlayClassSPScene.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "StarBeamStrike",
            Caster = char,
            ProjectileUniqueId = uniqueId,
        })
    end)
end