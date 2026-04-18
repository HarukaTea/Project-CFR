local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Managers = ServerScriptService.Managers

local Initializer = require(ReplicatedStorage.Shared.API.Initializer)

Initializer.initComponents(Managers:GetChildren())

:andThen(
    function(result: string)
        print("Successfully initialised server side.")
        Workspace
    end
)

:catch(function(errorMessage: string)
    error(`Ruh roh, server init failed!!! {errorMessage}`)
end)