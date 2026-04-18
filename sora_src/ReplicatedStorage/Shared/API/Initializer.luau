local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InitTyping = require(ReplicatedStorage.Constants.Typing.Initializer)
local Table = require(ReplicatedStorage.Utils.Table)
local Promise = require(ReplicatedStorage.Utils.Promise)
local t = require(ReplicatedStorage.Packages.t)

type Module = InitTyping.Module

local api = {}

type PromiseT = Promise.Promise
type EnvironmentType = "Server" | "Client"

function api.initComponents(children: {Instance})
    return Promise.each(children, function(value: ModuleScript, _: number)
        local instanceName: string = value.Name

        return Promise.new(function(resolve, reject, onCancel)
            if not t.instanceIsA("ModuleScript", value) then
                return resolve()
            end

            local module: Module = require(value)

            if not Table.includesKey(module, "start") then
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