local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local HarukaDoT = require(ServerScriptService.HarukaServer.Shared.HarukaDoT)


local Add, Empty = HarukaLib.Bin()


local char = script:FindFirstAncestorOfClass("Model")



Add(ServerBindables.EnemyGotHit:Connect(function(targeting: Model, attacker: Model)
    if attacker ~= char then return end


    local result = HarukaLib:RollLoot({
        ["Debuff"] = 5,
        ["NoEffect"] = 100 - 5
    })
    if result == "Debuff" then
        local debuffObj = HarukaDoT.new({
            Target = targeting,
            Type = "Bleed",
            Duration = 5,
            Creator = char,
            Power = 1,
        })
        debuffObj:Activate()
    end
end))



script.Destroying:Once(Empty)
char.DestroyBindableEvent.Event:Once(Empty)