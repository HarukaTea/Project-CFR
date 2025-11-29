
local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local ClassAttackLib = require(SSS.HarukaServer.Library.ClassAttackLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local DoTLib = require(SSS.HarukaServer.Services.DoTLib)


local Types = require(script.Parent.Parent.Types)


local wait = task.wait


return function(self: Types.CastItemLib, player: Player, char: Model, extraInfo: Types.Dict) : number?
    local CastItemLib = self

    local check = CastItemLib._preCheck({
        ReqCombat = true,
        ReqEnemy = true
    }, {
        ItemId = "ArcaneMark",
        Player = player,
        Char = char
    })
    if not check then return 0 end


    local uniqueId = HttpService:GenerateGUID(false)
    local castTime = ClassAttackLib._CalCastingTime(char, 2)


    Events.OpenCastTimeBar_S.Fire(player, castTime)
    Events.PlaySound_S.Fire(player, SoundService.SFXs.SpellReadyToCast)


    Promise.delay(castTime):andThen(function()
        Events.PlaySound_S.Fire(player, SoundService.SFXs.SpellCasted)
        Events.PlayClassAnim_S.Fire(player, "MagicCasted1")
        Events.FaceTargetingEnemy_S.Fire(player)


        Events.PlayVFXScene_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "ArcaneMarkRune",
            Caster = char,
            ProjectileUniqueId = uniqueId,
        })

        wait(0.5)
        local targeting = char.TargetingEnemy.Value :: Model


        ClassAttackLib._DealDamageToEnemy(char, targeting, {
            DMG = math.ceil(ClassAttackLib._CalDMG("Magic", char, {
                ForceMaxDMG = true
            }) * 2),
            DMGType = "Magic",
            Attacker = "SkillProjectile"
        })


        local result = HarukaLib:RollLoot({
            ["Debuff"] = 5,
            ["NoEffect"] = 100 - 5
        })
        if result == "Debuff" then
            local debuffObj = DoTLib.new({
                Target = targeting,
                Type = "Burn",
                Duration = 5,
                Creator = char,
                Power = 1,
            })
            debuffObj:Activate()
        end
    end)

    return nil
end