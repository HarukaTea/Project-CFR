local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InitTyping = require(ReplicatedStorage.Constants.Typing.Initializer)
local Table = require(ReplicatedStorage.Utils.Table)
local Promise = require(ReplicatedStorage.Utils.Promise)
local t = require(ReplicatedStorage.Packages.t)

type Module = InitTyping.Module

local api = {}

type PromiseT = Promise.Promise
type EnvironmentType = "Server" | "Client"

local isModuleScript = t.instanceIsA("ModuleScript")

function api.initComponents(children: {Instance})
    return Promise.each(children, function(value: ModuleScript, _: number)
        local instanceName: string = value.Name
        local isValidInstance, message = isModuleScript(value)

        return Promise.new(function(resolve, reject, onCancel)
            if not isValidInstance then
                print(`{instanceName} is not a module script. {message}`)
                return resolve()
            end

            local module: Module = require(value)

            if not Table.includesKey(module, "start") then
                print(`Rejecting module '{instanceName}.'`)
                return reject(
                    string.format(`Failed to initialise module '{instanceName}': {
                        "Module does not have a callable called 'start'"
                    }`)
                )
            end

            local output = module.start()

            if output.isSuccess == true then
                resolve()
            else
                reject(`Failed to initialise module '{instanceName}': {output.message}`)
            end
        end)
    end)
end

return table.freeze(api)