-- no need to require this if you're not going to check if there's a class
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local StringFormat = require(ReplicatedStorage.Utils.StringFormat)

local classNames = {} :: { string }
local api = {}

function api.hasClass(name: string): boolean
    return table.find(classNames, StringFormat.toCamelCase(name)) ~= nil
end

--- INITIALISATION ---

local isModuleScript = t.instanceIsA("ModuleScript")

for _, module: ModuleScript in script:GetChildren() do
    if not isModuleScript(module) then
        warn(`{module.Name} is not a ModuleScript in ReplicatedStorage/Constants/Classes. Excluding it from the available class list.`)
        continue
    end

    table.insert(classNames, StringFormat.toCamelCase(module.Name))
end

return table.freeze(api)