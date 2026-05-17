-- All scripts should load this module instead of the individual cosmetics to ensure integrity.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Typing = ReplicatedStorage.Constants.Typing

local CosmeticsTyping = require(Typing.Cosmetics)

local t = require(ReplicatedStorage.Packages.t)

local isModule = t.instanceIsA("ModuleScript")

type CosmeticData = CosmeticsTyping.CosmeticData

local cosmetics = {} :: { [string]: CosmeticData }
local api = {}

function api.hasCosmeticId(id: string): boolean
    return cosmetics[id] ~= nil
end

function api.getCosmeticData(id: string): CosmeticData?
    if not api.hasCosmeticId(id) then
        return
    end

    return cosmetics[id]
end

-- INITIALISATION --

for module: ModuleScript in script:GetChildren() do
    local moduleName = module.Name

    if not isModule(module) then
        warn(`'{moduleName}' is not a ModuleScript in Cosmetics folder.`)
        continue
    end

    local moduleInfo: CosmeticData = require(module)
    local valid, message = CosmeticsTyping.cosmeticDataT(moduleInfo)

    if not valid then
        warn(`A cosmetic module script called '{moduleName}' does not have a valid info: {message}`)
        continue
    end

    cosmetics[moduleInfo.id] = moduleInfo
end

return table.freeze(api)