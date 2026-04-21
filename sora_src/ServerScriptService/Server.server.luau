local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Managers = ServerScriptService.Managers
local Attributes = ReplicatedStorage.Constants.Attributes

local Initializer = require(ReplicatedStorage.Shared.API.Initializer)
local LoadingAttributes = require(Attributes.Loading)

Initializer.initComponents(Managers:GetChildren())

:andThen(
    function(result: string)
        print("Successfully initialised server side.")
        Workspace:SetAttribute(LoadingAttributes.serverInited, true)
    end
)

:catch(function(errorMessage: string)
    Workspace:SetAttribute(LoadingAttributes.serverInited, false)
    print(`Ruh roh, server init failed!!! {errorMessage}`)
end)