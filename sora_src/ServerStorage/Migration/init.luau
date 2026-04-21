local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TouchInputService = game:GetService("TouchInputService")

local DataTyping = require(ServerStorage.Constants.Typing.PlayerData)
local Typing = require(script.Modern.Typing.Version)

local t = require(ReplicatedStorage.Packages.t)

type PlayerData = DataTyping.PlayerData
type VersionModule = Typing.VersionModule

--[[
    All versions must contain `init(playerData: PlayerData)` method.
]]

local isModuleScript = t.instanceIsA("ModuleScript")

local inited = false
local modernVersions: {[string]: VersionModule}
local migration = {}

migration.separator = "_"

-- local function StringToTableVersion(version: string): {[number]: number}
--     local stripped = string.sub(version, 2) -- remove leading "V"
--     local parts = string.split(stripped, migration.separator)
--     local result = {}
--     for i, part in parts do
--         result[i] = tonumber(part)
--     end
--     return result
-- end

local function initModernVersions()
    for _, instance: ModuleScript | Folder in script.Modern:GetChildren() do
        local isValid, message = isModuleScript(instance)

        if not isValid then
            print(`{instance.Name} is not a ModuleScript in ServerStorage/Migration/Modern. {message}`)
            continue
        end

        modernVersions[instance.Name] = require(instance)
    end
end

--- Returns a string of the version.
--- Example: `V1_0_0`
function migration.versionToString(version: {[number]: number}): string
    return "V" .. table.concat(version, migration.separator)
end

--- Reconciles player's data. It will go through version by version to ensure integrity.
function migration.reconcile(playerData: PlayerData): PlayerData
    if not inited then
        initModernVersions()
        inited = true
    end

    local dataVersion: string = migration.versionToString(playerData.dataVersion)
    local newPlayerData: PlayerData = playerData
    local foundInitialVersion: boolean = false

    for stringVersion: string, module: VersionModule in modernVersions do
        -- If the data version is behind
        if stringVersion ~= dataVersion and not foundInitialVersion then
            continue
        end

        -- If the data version is exactly that version
        if stringVersion == dataVersion and not foundInitialVersion then
            foundInitialVersion = true
            continue
        end

        newPlayerData = module.transform(playerData)
    end

    return newPlayerData
end

return table.freeze(migration)