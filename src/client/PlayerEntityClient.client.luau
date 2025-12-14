
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

repeat task.wait() until workspace:GetAttribute("Haruka_GameEntered")


local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)


local player = Players.LocalPlayer


type PlayerLibClass = {
    Funcs: { [string]: () -> nil },

    Init: (self: PlayerLibClass) -> nil
}


local PlayerLib = {} :: PlayerLibClass
PlayerLib.Funcs = {}


function PlayerLib:Init()
    for _, func in self.Funcs do
        func()
    end
end


table.insert(PlayerLib.Funcs, function()
    for _, module in ReplicatedStorage.HarukaShared.UIAtlas.UI:GetChildren() do
        if string.find(module.Name, ".spec") then continue end
        if not string.find(module.Name, "_local") then continue end

        Promise.try(require(module), player):catch(function(err)
            warn(tostring(err))
        end)
    end
end)


PlayerLib:Init()

workspace:SetAttribute("Haruka_PlayerClientInited", true)