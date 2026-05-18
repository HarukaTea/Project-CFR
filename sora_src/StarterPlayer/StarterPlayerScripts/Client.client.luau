local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player: Player = game:GetService("Players").LocalPlayer
local PlayerScripts: StarterPlayerScripts = player.PlayerScripts

local Network = ReplicatedStorage:WaitForChild("Network")
local Managers: Folder = PlayerScripts:WaitForChild("Managers")

local LoadingEnum = require(ReplicatedStorage.Constants.Enums.Loading)

local Initializer = require(ReplicatedStorage.Shared.API.Initializer)

local Lync = require(ReplicatedStorage.Packages.Lync)

local Promise = require(ReplicatedStorage.Utils.Promise)
local DebugNetwork = require(Network.Debugging)


local function isServerReady(): boolean
    return Workspace:GetAttribute(LoadingEnum.serverInited) == true
end

local function serverDebugReceived(data: DebugNetwork.LogPayload)
    local level = data.level
    local header = data.header
    local footer = data.footer
    local message = data.message
    local scriptName = data.sender

    if level == "info" then
        print(`Server sent an info from '{scriptName}': {message}.`)
    elseif level == "warning" then
        warn(`Server sent a warning from '{scriptName}': {message}.`)
    else
        error(`Server sent an error from '{scriptName}': {message}.`)
    end
end


-- INITIALISATION

-- task: get vide here

Promise.new(function(resolve, reject, onCancel)
    require(Network)
    Lync.start()
    return Initializer.initComponents(Managers:GetChildren())
end)

:andThen(function(...)
    DebugNetwork.logOccurred:on(serverDebugReceived)
end)

:finally(function(status: "Cancelled" | "Rejected" | "Resolved" | "Started")

end)

:catch(function(...)
    error(`You have received a client error. {...}`)
end)
