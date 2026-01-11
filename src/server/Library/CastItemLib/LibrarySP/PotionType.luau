
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local StatusLib = require(SSS.HarukaServer.Library.StatusLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)

local Types = require(script.Parent.Parent.Types)

return function (self: Types.CastItemLib)
    local CastItemLib = self

    CastItemLib.HealthPotion = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "HealthPotion",
            Player = player,
            Char = char
        })
        if not check then return 0 end

        CastItemLib._drinkSoundFunc(char, function()
            local amount = StatusLib:HealPercentage(char, 20)

            ServerLib:ShowNumber(char, amount, Color3.fromHex('#7bed9f'))
        end)

        return nil
    end

    CastItemLib.PowerPotion = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "PowerPotion",
            Player = player,
            Char = char
        })
        if not check then return 0 end

        CastItemLib._drinkSoundFunc(char, function()
            StatusLib:ATKBoost(char, {
                DMGPower = 0.75,
                Duration = 8
            })
        end)

        return nil
    end

    CastItemLib.MagicPotion = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "MagicPotion",
            Player = player,
            Char = char
        })
        if not check then return 0 end

        CastItemLib._drinkSoundFunc(char, function()
            StatusLib:Boost("Magic", char, {
                Power = 0.75,
                Duration = 8
            })

            Events.PlayStatPoweredScreenFX_S.Fire(player)
        end)

        return nil
    end

    CastItemLib.ManaPotion = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "ManaPotion",
            Player = player,
            Char = char
        })
        if not check then return 0 end

        CastItemLib._drinkSoundFunc(char, function()
            StatusLib:RestoreManaPercentage(char, 100)

            Events.PlayStatPoweredScreenFX_S.Fire(player)
        end)

        return nil
    end

    CastItemLib.EndurancePotion = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "EndurancePotion",
            Player = player,
            Char = char
        })
        if not check then return 0 end

        CastItemLib._drinkSoundFunc(char, function()
            local maxShield = char:GetAttribute("MaxShield") :: number

            HarukaLib:AddAttr(char, "Shield", math.ceil(maxShield))

            Events.PlayVFXStatusToPlayer_S.FireList(ServerLib:GetNearbyPlayers(char.PrimaryPart.Position, 150), {
                StatusId = "Repairing",
                Character = char
            })
        end)

        return nil
    end

end