local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player: Player = game:GetService("Players").LocalPlayer
local playerScripts: StarterPlayerScripts = player.PlayerScripts

local Initializer = require(ReplicatedStorage.Shared.API.Initializer)

Initializer.initComponents(playerScripts:GetChildren())

:andThen(
    function(returnedValue: any)
        print("Client side is working just fine")
    end, function(errorMessage: string)
        error(`Ruh roh, error!!! {errorMessage}`)
    end
)