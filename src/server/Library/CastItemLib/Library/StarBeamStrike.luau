
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

return function(self: Types.CastItemLib, player: Player, char: Model, extraInfo: Types.Dict) : number?
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
    if not extraInfo.CostManaFunc(char) then return 0 end

    local uniqueId = HttpService:GenerateGUID(false)
    local castTime = ClassAttackLib:CalCastingTime(char, 3)

    Events.OpenCastTimeBar_S.Fire(player, castTime)
    Events.PlaySound_S.Fire(player, SoundService.SFXs.SpellReadyToCast)

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
        Events.PlaySound_S.Fire(player, SoundService.SFXs.SpellCasted)
        Events.PlayClassAnim_S.Fire(player, "MagicCasted1")
        Events.FaceTargetingEnemy_S.Fire(player)

        Events.PlayVFXScene_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "StarBeamStrike",
            Caster = char,
            ProjectileUniqueId = uniqueId,
        })
    end)

    return nil
end