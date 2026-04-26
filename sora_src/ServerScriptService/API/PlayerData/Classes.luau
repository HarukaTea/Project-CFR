local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Promise = require(ReplicatedStorage.Utils.Promise)
local DataAccessor = require(ServerStorage.Constants.Typing.DataAccessor)

local ERR_SAVE_SLOT_NOT_FOUND = "Could not find player '%s' save slot to %s."

local dataAccessor = {} :: DataAccessor.API
local inited: boolean = false
local api = {}

function api.init(accessor: DataAccessor.API)
    if inited then
        return
    end

    dataAccessor = accessor
    inited = true
end




return table.freeze(api)