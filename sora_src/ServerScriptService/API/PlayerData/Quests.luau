local ServerStorage = game:GetService("ServerStorage")

local ServerTyping = ServerStorage.Constants.Typing

local DataAccessorTyping = require(ServerTyping.DataAccessor)

local dataAccessor = {} :: DataAccessorTyping.API
local inited: boolean = false
local api = {}

function api.init(accessor: DataAccessorTyping.API)
    if inited then
        return
    end

    dataAccessor = accessor
    inited = true
end

return table.freeze(api)