
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local ClassAttackLib = require(SSS.HarukaServer.Library.ClassAttackLib)
local StatusLib = require(SSS.HarukaServer.Library.StatusLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local Promise = require(RepS.HarukaShared.Shared.Promise)


local Types = require(script.Parent.Parent.Types)


local wait = task.wait


return function (self: Types.CastItemLib)
    local CastItemLib = self


    CastItemLib.FireballSpell = function(player: Player, char: Model, extraInfo: {}) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = true,
            ReqEnemy = true
        }, {
            ItemId = "FireballSpell",
            Player = player,
            Char = char
        })
        if not check then return 0 end


        local uniqueId = HttpService:GenerateGUID(false)
        local castTime = ClassAttackLib._CalCastingTime(char, 1)


        Events.OpenCastTimeBar_S.Fire(player, castTime)
        Events.PlaySound_S.Fire(player, SoundService.SFXs.SpellReadyToCast)


        Promise.delay(castTime):andThen(function()
            ServerBindables.RToCreateProjectileSymbol:Fire(char.Name, {
                ProjectileId = "FireballSpell",
                Duration = 3,
                ProjectileType = "OneTime",
                ProjectileUniqueId = uniqueId,
                DMGType = "Magic",
                DoTType = "Burn",
                DMGBonus = 1,
                IsClassUlt = false
            })
            Events.PlaySound_S.Fire(player, SoundService.SFXs.SpellCasted)
            Events.PlayAnimation_S.Fire(player, {
                AnimId = "MagicCasted1"
            })
            Events.FaceTargetingEnemy_S.Fire(player)


            Events.PlayVFXScene_S.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
                SceneId = "FireballSpell",
                Caster = char,
                ProjectileUniqueId = uniqueId,
            })
        end)

        return nil
    end


    CastItemLib.Agility = function(player: Player, char: Model, extraInfo: {}) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "Agility",
            Player = player,
            Char = char
        })
        if not check then return 0 end


        Events.PlaySound_S.Fire(player, SoundService.SFXs.SpellCasted)

        StatusLib.NormalBoostForEntity("Speed", char, {
            Power = 0.5,
            Duration = 6
        })


        local eff = RepS.Packages.Effects.Status.Speeding:FindFirstChildOfClass("ParticleEmitter"):Clone() :: ParticleEmitter
        eff.Parent = char.PrimaryPart
        Debris:AddItem(eff, 6)


        Promise.delay(5):andThen(function()
            eff.Enabled = false
        end):catch(function() end)

        return nil
    end


    CastItemLib.ExtraJump = function(player: Player, char: Model, extraInfo: {}) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "ExtraJump",
            Player = player,
            Char = char
        })
        if not check then return 0 end

        Events.Spell_ExtraJumpSupport.Fire(player)

        Events.PlayVFXScene_S.FireList(ServerLib.GetNearbyPlayers(char.PrimaryPart.Position), {
            SceneId = "ChainJump",
            Caster = char,
            ProjectileUniqueId = "nil"
        })

        return nil
    end
end