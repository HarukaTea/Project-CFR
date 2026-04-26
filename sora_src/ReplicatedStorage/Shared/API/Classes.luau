local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassesFolder = ReplicatedStorage.Constants.Classes
local Typing = ReplicatedStorage.Constants.Typing

local ClassTyping = require(Typing.Class)
local Promise = require(ReplicatedStorage.Utils.Promise)
local t = require(ReplicatedStorage.Packages.t)

type ClassData = ClassTyping.ClassData

local CLASSES_PATH: string = "ReplicatedStorage/Constants/Classes"

-- key is the class name
local classes = {} :: { [string]: ClassData }
local api = {}

local isModuleScript = t.instanceIsA("ModuleScript")
local isTypedCorrectly = ClassTyping.ClassDataT

--- Retrieves the class details if it exists. Generally recommended to follow the naming convention to avoid the usage of string formatting.
function api.getClass(name: string): ClassData?
    return classes[name]
end

--[[ Initialisation ]]

Promise.each(ClassesFolder:GetChildren(), function(module: ModuleScript, index: number)
    local moduleName: string =  module.Name
    return Promise.new(function(resolve, reject, onCancel)
        if not isModuleScript(module) then
            warn(`Instance called '{moduleName}' is not a valid ModuleScript in {CLASSES_PATH}`)
            return resolve()
        end

        --- Check if this is real first
        local details = require(module) :: ClassData
        local isValid, errMsg = isTypedCorrectly(details)

        if not isValid then
            return reject(`Class Module called '{moduleName}' is not a valid class data in {CLASSES_PATH}. {errMsg}`)
        end

        table.insert(classes, details)
        resolve()
    end)
end)

-- we don't need to send this to the client since it's shared
:catch(function(errorMsg: string)
    warn(errorMsg)
end)

return table.freeze(api)
