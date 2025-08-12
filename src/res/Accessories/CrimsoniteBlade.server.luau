local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local ServerLib = require(ServerScriptService.HarukaServer.Library.ServerLib)
local DoTLib = require(ServerScriptService.HarukaServer.Services.DoTLib)


local AccessoryUniversal = require(ReplicatedStorage.HarukaRes.Accessories.AccessoryUniversal)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")


Add(HarukaLib.Clock(1, function()
    if not ServerLib.IsCharValid(char) then return end
    if not char:GetAttribute("IsInCombat") then return end

    char.Humanoid:TakeDamage(math.ceil(char.Humanoid.MaxHealth * 0.01))
end))


local event = Instance.new("BindableEvent")
event.Name = "EnemyGotHit"
event.Parent = script


Add(AccessoryUniversal.RegisterEnemyOnHit(event, char, function(targeting, attacker, dmgProps)
    if dmgProps.AttackType ~= "ClassAttacks" then return end

    local result = HarukaLib:RollLoot({
        ["Debuff"] = 3,
        ["NoEffect"] = 100 - 3
    })
    if result == "Debuff" then
        local debuffObj = DoTLib.new({
            Target = targeting,
            Type = "Poison",
            Duration = 5,
            Creator = char,
            Power = 1,
        })
        debuffObj:Activate()
    end
end))

AccessoryUniversal.RegisterPlayerDiedEmpty(script, char.PlayerDied, Empty)
