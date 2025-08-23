--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")


local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local StatusLib = require(SSS.HarukaServer.Library.StatusLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)


local Types = require(script.Parent.Parent.Types)


local wait = task.wait


return function (self: Types.CastItemTable)
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

            ServerLib.ShowNumber(char, amount, Color3.fromHex('#7bed9f'))
        end)
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
            StatusLib:DMGBoost(char, {
                DMGPower = 0.75,
                Duration = 8
            })
        end)
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
            StatusLib:NormalBoostForEntity("Magic", char, {
                Power = 0.75,
                Duration = 8
            })

            Events.PlayStatPoweredScreenFX.Fire(player)
        end)
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
            HarukaLib:AddAttr(char, "Shield", math.floor(char:GetAttribute("MaxShield") * 0.5))

            local repairingEff = RepS.Packages.Effects.Repairing:Clone() :: BasePart
            repairingEff.Parent = char

            Debris:AddItem(repairingEff, 1.5)
        end)
    end

end