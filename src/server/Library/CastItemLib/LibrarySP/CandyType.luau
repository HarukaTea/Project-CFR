--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local StatusLib = require(SSS.HarukaServer.Library.StatusLib)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)

local wait = task.wait


return function (self: table)
    local CastItemLib = self

    CastItemLib.HalloweenCandy = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "HalloweenCandy",
            Player = player,
            Char = char
        })
        if not check then return 0 end


        CastItemLib._eatSoundFunc(char, function()
            local amount = StatusLib:HealPercentage(char, 10)
            HarukaLib:AddAttr(char, "LuckEx", 20)

            ServerLib:ShowNumber(char, amount, Color3.fromHex('#7bed9f'))
        end)
    end


    CastItemLib.CookedSteak = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "CookedSteak",
            Player = player,
            Char = char
        })
        if not check then return 0 end


        CastItemLib._eatSoundFunc(char, function()
            local amount = StatusLib:HealPercentage(char, 15)

            ServerLib:ShowNumber(char, amount, Color3.fromHex('#7bed9f'))
        end)
    end


    CastItemLib.ShrimpDish = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "ShrimpDish",
            Player = player,
            Char = char
        })
        if not check then return 0 end


        CastItemLib._eatSoundFunc(char, function()
            local amount = StatusLib:HealPercentage(char, 20)

            ServerLib:ShowNumber(char, amount, Color3.fromHex('#7bed9f'))
        end)
    end
end
