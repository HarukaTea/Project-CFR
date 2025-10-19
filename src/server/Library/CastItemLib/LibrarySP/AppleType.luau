--!nolint LocalUnused
--!nolint LocalShadow
--!nolint SameLineStatement
--!nolint ImplicitReturn

local SSS = game:GetService("ServerScriptService")

local StatusLib = require(SSS.HarukaServer.Library.StatusLib)
local ServerLib = require(SSS.HarukaServer.Library.ServerLib)


local Types = require(script.Parent.Parent.Types)

local wait = task.wait


return function (self: Types.CastItemTable)
    local CastItemLib = self

    CastItemLib.HealthyApple = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "HealthyApple",
            Player = player,
            Char = char
        })
        if not check then return 0 end


        CastItemLib._eatSoundFunc(char, function()
            local amount = StatusLib.HealPercentage(char, 5)

            ServerLib.ShowNumber(char, amount, Color3.fromHex('#7bed9f'))
        end)
    end
    CastItemLib.Bread = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "Bread",
            Player = player,
            Char = char
        })
        if not check then return 0 end


        CastItemLib._eatSoundFunc(char, function()
            local amount = StatusLib.HealPercentage(char, 10)

            ServerLib.ShowNumber(char, amount, Color3.fromHex('#7bed9f'))
        end)
    end


    CastItemLib.GoldenApple = function(player: Player, char: Model) : number?
        local check = CastItemLib._preCheck({
            ReqCombat = false,
            ReqEnemy = false
        }, {
            ItemId = "GoldenApple",
            Player = player,
            Char = char
        })
        if not check then return 0 end


        CastItemLib._eatSoundFunc(char, function()
            local amount = StatusLib.HealPercentage(char, 15)
            ServerLib.ShowNumber(char, amount, Color3.fromHex('#7bed9f'))

            StatusLib.DMGBoost(char, {
                DMGPower = 0.5,
                Duration = 6
            })
        end)
    end
end